# magnetによるマップのデータ
scale <- function(x) x / (max(x) - min(x))
magnet <- function(x) scale(tan(x))
mod <- function(x, var, shift) x * var + shift

stimulus <- seq(-1, 1, 0.1)
perception <- magnet(stimulus)

n <- length(perception)
stimulus_perception_map <- data.frame(
  stage = factor(rep(c("Stimulus", "Perception"), each = n)),
  value = c(stimulus, perception),
  mapping = c(1:n, 1:n)
)

df_stimulus_perception <- data.frame(Stimulus = stimulus, Perception = perception)

stimulus_perception_map_data = function() return(stimulus_perception_map)
df_stimulus_perception_data = function() return(df_stimulus_perception)

# aとbのサンプルデータ
set.seed(1234)
n <- 100
mean_sd_a <- c(0, 1)
a_samples = rnorm(n, mean = mean_sd_a[1], sd = mean_sd_a[2])
mean_sd_b <- c(3, 1)
b_samples =   rnorm(n, mean = mean_sd_b[1], sd = mean_sd_b[2])
sample_df_a_and_b <- data.frame(class = factor(rep(c("A", "B"), each = n)),
  value = c(a_samples, b_samples)
)

get_sample_df_a_and_b = function() return(sample_df_a_and_b)

# discrimination curve
d <- 0.01
X <- seq(-2.5, 5.5, d)
n_X <- length(X)
NeighA <- 1000 * dnorm(X, mean_sd_a[1], mean_sd_a[2])
NeighB <- 100 * dnorm(X, mean_sd_b[1], mean_sd_b[2])
SimA <- NeighA / (NeighA + NeighB)
SimB <- NeighB / (NeighA + NeighB)
SimA_deriv <- approxfun(X[-1], diff(SimA) / diff(X))
SimB_deriv <- approxfun(X[-1], diff(SimB) / diff(X))
discr <- (abs(SimA_deriv(X)) + abs(SimB_deriv(X))) / 2 * (4 / 3)

n_factor <- 3
df_sAB_discr <- data.frame(X = rep(X, n_factor),
                           class = factor(rep(c("sA", "sB", "discr"), each = n_X)),
                           value = c(SimA, SimB, discr))

get_df_sAB_discr = function() return(df_sAB_discr)
