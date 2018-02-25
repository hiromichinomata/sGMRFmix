#' @import zeallot
NULL

#' Sparse Gaussian Markov Random Field Mixtures
#'
#' @export
sGMRFmix <- function(x, K, rho, m0 = rep(0, M), lambda0 = 1,
                     pi_threshold = 1/K/100, max_iter = 400, tol = 1e-2,
                     verbose = TRUE) {
  if (!is.data.frame(x)) {
    x <- as.data.frame(x)
  }
  M <- ncol(x)
  if (verbose) message("################## sparseGaussMix #######################")
  c(pi2, m, A) %<-% sparseGaussMix(x, K = K, rho = rho, m0 = m0,
                                   lambda0 = lambda0, max_iter = max_iter,
                                   tol = tol, verbose = verbose)
  pi <- pi2 # Work around for bug of zeallot
  if (verbose) message("\n################## Finished #############################")
  if (verbose) message("################## GMRFmix ##############################")
  ind <- pi >= pi_threshold
  c(pi, m, A) %<-% list(pi[ind], m[ind], A[ind])
  theta <- GMRFmix(x, pi = pi, m = m, A = A,
                   max_iter = max_iter, tol = tol, verbose = verbose)
  if (verbose) message("\n################## Finished #############################")
  result <- list(x = x, pi = pi, m = m, A = A, theta = theta)
  class(result) <- "sGMRFmix"
  result
}
