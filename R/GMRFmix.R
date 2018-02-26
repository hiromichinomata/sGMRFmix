#' Gaussian Markov random field mixtures
#'
#' @importFrom utils txtProgressBar setTxtProgressBar
#'
#' @export
GMRFmix <- function(x, pi, m, A, alpha = rep(1, K), max_iter = 400,
                    tol = 1e-2, verbose = TRUE) {
  c(N, M) %<-% dim(x)
  if (verbose) progress_bar <- txtProgressBar(0, M, style=3)
  K <- length(pi)

  w <- compute_variance(A)
  u <- compute_mean(x, m, A, w)

  theta_mat <- matrix(nrow = M, ncol = K)
  h_mat <- matrix(nrow = N, ncol = M)
  for (i in 1:M) {
    Nk <- pi * N
    loglik <- -Inf
    n_iter <- 1
    while (TRUE) {
      # Eq. 15 (Sec. 3.2)
      a <- alpha + Nk
      a_bar <- sum(a)

      # Eq. 16 (Sec. 3.2)
      theta <- exp(digamma(a) - digamma(a_bar))

      c(g, mat) %<-% compute_gating_function(x, theta, u, w, i)

      # Eq. 18 (Sec. 3.2)
      Nk <- colSums(g)

      last_loglik <- loglik
      # Eq. 10 (Sec. 3.2)
      alpha_bar <- sum(alpha)
      loglik <- sum(log(apply(mat, 1, function(row) max(row)))) -
        lgamma(alpha_bar) +
        sum(lgamma(alpha) + (alpha - 1) * log(theta))

      loglik_gap <- abs(last_loglik - loglik)
      if (loglik_gap < tol) {
        theta_mat[i, ] <- theta
        h_mat[, i] <- apply(mat, 1, function(row) which.max(row))
        break
      }

      n_iter <- n_iter + 1
      if (n_iter > max_iter) {
        message <- sprintf("did not converge after %d iteration: gap: %f",
                           max_iter, loglik_gap)
        warning(message)
        theta_mat[i, ] <- theta
        h_mat[, i] <- apply(mat, 1, function(row) which.max(row))
        break
      }
    }
    if (verbose) setTxtProgressBar(progress_bar, i)
  }
  H <- as.data.frame(h_mat)
  colnames(H) <- colnames(x)

  list(theta = theta_mat, H = H)
}
