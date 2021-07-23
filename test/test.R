library(testthat)
source("../src/hmm.R") # test HMM

# TEST DATA
# categories, priors, A, B
categories <- unname(unlist(read.table(file = "../data/categories.txt")))
priors <- unname(unlist(read.table(file = "../data/pi.txt")))
names(priors) <- categories

A_cv <- as.matrix(read.table(file = "../data/alpha.txt"))
A_cc <- as.matrix(read.table(file = "../data/alpha_cc.txt"))

B_params <- as.matrix(read.table(file = "../data/b_params.txt", header = TRUE, sep = " "))
B_list <- lapply(categories, function(cat) B$new(src = cat, mu = B_params[cat, "mu"], sd = B_params[cat, "sd"]))
names(B_list) <- categories

bad_pi_params <- unname(read.table(file = "../data/bad_pi.txt"))
O <- unname(unlist(read.table(file = "../data/O.txt")))
test_Z_hat <- unname(unlist(read.table(file = "../data/Z_hat.txt")))
test_Z_hat_cc <- unname(unlist(read.table(file = "../data/Z_hat_cc.txt")))

test_that("init_ill", {
  bad_states_seq <- c("o", "e", "u", "b", "z")
  expect_error(pi$new(tgts = bad_states_seq, prob = pi_params_ill))
  bad_algorithm <- "viiterbi"
  expect_error(HMM$new(states = categories, priors = priors, A = A_cv, B = B_list, algorithm = bad_algorithm))
})

test_that("viterbi", {
  hmm <- HMM$new(states = categories, priors = priors, A = A_cv, B = B_list, n_parallel = 5)
  Z_hat_cv <- hmm$decode(O)
  expect_equal(Z_hat_cv, test_Z_hat)
  Z_hat_cc <- HMM$new(states = categories, priors = priors, A = A_cc, B = B_list, n_parallel = 5)$decode(O)
  expect_equal(Z_hat_cc, test_Z_hat_cc)
})

test_that("naive_bayes", {
  Z_hat_cv_nb <- HMM$
    new(states = categories, priors = priors, A = A_cv, B = B_list, n_parallel = 0, algorithm = "naive_bayes")$
    decode(O)
  expect_false("ebuzo" == paste(unique_seq(Z_hat_cv_nb), collapse = ""))
})

test_that("unique seq", {
  expect_equal(c("e", "b", "u", "z", "o"), unique_seq(c("e", "e", "b", "b", "u", "z", "z", "o", "o")))
})
