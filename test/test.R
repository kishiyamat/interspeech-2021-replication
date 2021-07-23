library(testthat)
source("data/hmm.R")
source("data/test_data.R")

test_that("init_ill", {
  bad_states_seq <- c("o", "e", "u", "b", "z")
  expect_error(pi$new(tgts = bad_states_seq, prob = pi_params_ill))
  bad_algorithm <- "viiterbi"
  expect_error(HMM$new(states = categories, priors = priors, A = A_cv, B = B_list, algorithm = bad_algorithm))
})

test_that("viterbi", {
  hmm <- HMM$new(states = categories, priors = priors, A = A_cv, B = B_list, n_parallel = 5)
  Z_hat_cv = hmm$decode(O)
  expect_equal(Z_hat_cv, test_Z_hat)
  Z_hat_cc <- HMM$new(states = categories, priors = priors, A = A_cc, B = B_list, n_parallel = 5)$decode(O)
  expect_equal(Z_hat_cc, test_Z_hat_cc)
})

test_that("naive_bayes", {
  Z_hat_cv_nb <- HMM$
    new(states = categories, priors = priors, A = A_cv, B = B_list, n_parallel = 0, algorithm = "naive_bayes")$
    decode(O)
  expect_false("ebuzo"==paste(unique_seq(Z_hat_cv_nb), collapse = ""))
})

test_that("unique seq", {
  expect_equal(c("e", "b", "u", "z", "o"), unique_seq(test_Z_hat))
})