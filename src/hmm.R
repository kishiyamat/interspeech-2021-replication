library(R6)
library(rlang)
library(dplyr)

unique_seq <- function(seq) {
  return(rle(seq)$values)
}

B <- R6Class("Emission", list(
  src = NULL,
  mu = NA,
  sd = NA,
  initialize = function(src, mu, sd) {
    self$src <- src
    self$mu <- mu
    self$sd <- sd
  },
  rep = function(n) {
    return(rep(self$src, n))
  },
  pdf = function(tgt) {
    return(dnorm(tgt, self$mu, self$sd))
  },
  rvs = function(n) {
    return(rnorm(n, self$mu, self$sd))
  },
  print = function(...) {
    B_cat <- self$src
    B_mu <- as.character(self$mu)
    B_sd <- as.character(self$sd)
    cat("p(X|", B_cat, ") ~ Norm(mu=", B_mu, ", sd=", B_sd, ")\n", sep = "")
  }
))

HMM <- R6Class("HiddenMarkovModel",
  public = list(
    n_parallel = NA, algorithm = NA,
    states = NA,
    K = NA, # {1, 2, ... n_states} in K # TODO: だったらn_statesでよくない?
    priors = NA,
    A = NA,
    B = NA,
    # viterbiで利用
    delta = NA,
    psi = NA, # 一つ前はどれが尤もらしいか
    beta = NA,
    # 実験のノート
    note = NA,
    initialize = function(states, priors, A, B, n_parallel = 2, algorithm = "viterbi", note = NA) {
      self$states <- states
      self$K <- length(states)
      self$priors <- self$validated_pi(priors)
      self$A <- self$validated_A(A) # TODO: 参照渡しを避ける
      self$B <- self$validated_B(B)
      # parameter for experiment
      self$n_parallel <- n_parallel
      self$algorithm <- self$validated_algorithm(algorithm)
      # note
      self$note <- note
      invisible(self)
    },
    a_i = function(tgt) {
      # returns P(tgt|src)
      return(self$A[, tgt])
    },
    b_i = function(o) {
      return(sapply(self$B, function(B_i) B_i$pdf(o)))
    },
    decode = function(obs) {
      # listを使えばifがなくなる
      if (self$algorithm == "naive_bayes") {
        return(private$naive_bayes(obs))
      }
      if (self$algorithm == "viterbi") {
        return(private$viterbi(obs))
      }
      if (self$algorithm == "baum_welch") {
        return(private$baum_welch(obs))
      }
      stop("KeyEorrr")
    },
    print = function(...) {
      cat("HMM:\n")

      cat("pi: \n")
      (self$priors)
      cat("\n")

      cat("A: \n")
      print(self$A)
      cat("\n")

      cat("B: \n")
      sapply(self$B, print)
    },
    validated_pi = function(priors) {
      stopifnot(names(priors) == self$states)
      stopifnot(near(1, sum(priors)))
      return(priors)
    },
    validated_A = function(A) {
      stopifnot(ncol(A) == nrow(A))
      stopifnot(near(1, rowSums(A)))
      stopifnot(colnames(A) == self$states)
      stopifnot(rownames(A) == self$states)
      # TODO: 参照渡しを避ける
      return(A)
    },
    validated_B = function(B) {
      stopifnot(names(B) == self$states)
      stopifnot(sapply(B, function(b) b$src) == self$states)
      B <- sapply(B, function(elm) elm$clone(deep = TRUE))
      return(B)
    },
    validated_algorithm = function(algorithm) {
      valid_list <- c("viterbi", "baum_welch", "naive_bayes")
      stopifnot(algorithm %in% valid_list)
      return(algorithm)
    },
    keep_n_best = function(arr, n_best) {
      n_kill <- length(arr) - n_best
      bad_candidates <- sort(arr)[1:n_kill]
      for (bad in bad_candidates) { # for にして動的に探索しないとidxがおなじになりうる
        arr[which(arr == bad)[1]] <- NA # 複数個ある時に[1]にしないとだめ
      }
      arr[which(is.na(arr))] <- 0 # NAではmaxが使えないので0に変更
      return(arr)
    }
  ),
  private = list(
    viterbi = function(obs) {
      O_T <- length(obs)
      zeros <- rep(0, self$K * O_T)
      self$delta <- matrix(data = zeros, ncol = O_T, nrow = self$K, dimnames = list(c(self$states), c(1:O_T)))
      self$psi <- matrix(data = zeros, ncol = O_T, nrow = self$K, dimnames = list(c(self$states), c(1:O_T)))
      self$beta <- sapply(obs, function(o_i) self$b_i(o_i))
      self$delta[, 1] <- c(self$priors * self$beta[, 1])
      for (t in 2:O_T) {
        self$delta[, t - 1] <- self$keep_n_best(self$delta[, t - 1], self$n_parallel) # ここで潰す
        for (s_j in self$states) {
          delta_t_i <- self$delta[, t - 1]
          a_j_i <- unlist(self$A[, s_j])
          deltati_aji <- delta_t_i * a_j_i
          self$delta[s_j, t] <- max(deltati_aji) * self$beta[s_j, t]
          self$psi[s_j, t] <- which(deltati_aji == max(deltati_aji))[1] # 複数ある場合は最初.どれでもいい
        }
      }
      delta_O_T <- self$delta[, O_T]
      P_star_O_T <- which(delta_O_T == max(delta_O_T))
      P_star <- rep(NA, O_T)
      P_star[O_T] <- P_star_O_T
      for (t in O_T:2) {
        P_star[t - 1] <- self$psi[P_star[t], t]
      }
      return(self$states[P_star])
    },
    baum_welch = function(obs) {
      stop("NotImplementedError")
    },
    naive_bayes = function(obs) {
      # Priorsをかけてるからnaive bayesであってる。
      O_T <- length(obs)
      posterior <- sapply(obs, function(o_i) self$b_i(o_i) * self$priors)
      P_star <- apply(posterior, 2, function(p) which(p == max(p))) # ノイズに振り回されるはず
      return(self$states[P_star])
    }
  )
)

# Reference
# https://adv-r.hadley.nz/r6.html
# https://www.youtube.com/watch?v=s9dU3sFeE40&ab_channel=djp3
# https://cran.r-project.org/web/packages/depmixS4/vignettes/depmixS4.pdf
