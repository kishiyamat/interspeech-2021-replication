library(R6)

Experiment <- R6Class("Experiment",
  public=list(
    note = NA,
    log_dir = NA,
    params = NA,
    model=NA,
    obs=NA,
    evidence=NA,
    Z_true = NA,
    prediction=NA,
    param_names = c("sd", "n_parallel", "algorithm", "lang", "u_duration"),
    lang_names = c("jpn", "fr", "jpn-u", "bpt-i"),
    # init
    initialize = function(params, log_dir="./log") {
      self$params = params
      stopifnot(setequal(names(params), self$param_names))
      stopifnot(params$lang %in% self$lang_names)
      self$log_dir <- log_dir
      self$model <- self$make_model(params)  # 実験サイクルごとにモデルを作って外部の影響をなくす
      self$obs <- self$make_obs(params)  # 先にモデルを作らないとデータは作れない(sdの値に依存)
      self$evidence <- 'ebuzo'  # epenthesis ならこっちだけでいい
    },
    make_model = function(params){
      categories <- unname(unlist(read.table(file = "data/categories.txt")))
      priors <- unname(unlist(read.table(file = "data/pi.txt")))
      names(priors) = categories
      # SET LANGUAGE
      if (params$lang=='jpn') A_mat <- as.matrix(read.table(file = "data/alpha.txt"))
      if (params$lang=='fr')  A_mat <- as.matrix(read.table(file = "data/alpha_cc.txt"))
      # SET STANDARD DEVIATION
      B_params <- as.matrix(read.table(file = "data/b_params.txt", header = TRUE, sep = " "))
      B_params[,'sd'] = params$sd
      B_list <- lapply(categories, function(cat) B$new(src = cat, mu = B_params[cat, "mu"], sd = B_params[cat, "sd"]))
      names(B_list) = categories
      # SET N_PARALLEL and ALGORITHM
      model_experiment = HMM$new(states = categories,
                                 priors = priors,
                                 A = A_mat,
                                 B = B_list,
                                 n_parallel = params$n_parallel,
                                 algorithm = params$algorithm)
      return(model_experiment)
    },
    make_obs = function(params){
      # TODO: 実験内容に結合しているので疎に変更
      self$Z_true <- c(rep("e", 2), rep("b", 2), rep("u", params$u_duration), rep("z", 2), rep("o", 2))
      return(sapply(self$Z_true, function(elm) self$model$B[[elm]]$rvs(1)))
    },
    run = function() {
      Z_hat = self$model$decode(self$obs)
      unique_Z_hat = unique_seq(Z_hat)
      self$prediction = paste(unique_Z_hat, collapse = "")
    },
    save = function(tgt) {
      return(NA)
    },
    print = function(...) {
    }
  )
)