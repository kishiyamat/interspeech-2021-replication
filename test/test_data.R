# categories, priors, A, B
categories <- unname(unlist(read.table(file = "data/categories.txt")))
priors <- unname(unlist(read.table(file = "data/pi.txt")))
names(priors) = categories

A_cv <- as.matrix(read.table(file = "data/alpha.txt"))
A_cc <- as.matrix(read.table(file = "data/alpha_cc.txt"))

B_params <- as.matrix(read.table(file = "data/b_params.txt", header = TRUE, sep = " "))
B_list <- lapply(categories, function(cat) B$new(src = cat, mu = B_params[cat, "mu"], sd = B_params[cat, "sd"]))
names(B_list) = categories

bad_pi_params <- unname(read.table(file = "data/bad_pi.txt"))
O <- unname(unlist(read.table(file = "data/O.txt")))
test_Z_hat <- unname(unlist(read.table(file = "data/Z_hat.txt")))
test_Z_hat_cc <- unname(unlist(read.table(file = "data/Z_hat_cc.txt")))