#' @import zeallot
NULL

#' Sparse Gaussian Markov Random Field Mixtures
#'
#' @export
sGMRFmix <- function(x, K, rho, m0 = rep(0, M), lambda0 = 1,
                     pi_threshold = 1/K/100, max_iter = 500, tol = 1e-1,
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
  if (verbose) message("\n################## GMRFmix ##############################")
  ind <- pi >= pi_threshold
  c(pi, m, A) %<-% list(pi[ind], m[ind], A[ind])
  c(theta, H) %<-% GMRFmix(x, pi = pi, m = m, A = A,
                           max_iter = max_iter, tol = tol, verbose = verbose)
  if (verbose) message("\n################## Finished #############################")
  mode <- apply(H, 1, function(row) {
    t <- table(row)
    as.integer(names(t)[which.max(t)])
  })
  result <- list(x = x, pi = pi, m = m, A = A, theta = theta, H = H, mode = mode,
                 Kest = length(pi), K = K, rho = rho, m0 = m0, lambda0 = lambda0,
                 pi_threshold = pi_threshold)
  class(result) <- "sGMRFmix"

  cl <- match.call()
  result$call <- cl

  result
}
