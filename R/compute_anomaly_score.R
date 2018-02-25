#' @export
compute_anomaly_score <- function(obj, x, ...) {
  UseMethod("compute_anomaly_score")
}

#' @importFrom stats dnorm
#'
#' @export
compute_anomaly_score.sGMRFmix <- function(obj, x, ...) {
  c(m, A, theta) %<-% with(obj, list(m, A, theta))
  c(N, M) %<-% dim(x)
  K <- length(m)

  x <- as.matrix(x)
  w <- compute_variance(A)
  u <- compute_mean(x, m, A, w)
  anomaly_score <- matrix(nrow = N, ncol = M)
  for (i in 1:M) {
    c(g, .) %<-% compute_gating_function(x, theta, u, w, i)
    tmp <- lapply(1:K, function(k) {
      g[, k] * dnorm(x[,i], mean = u[[k]][,i], sd = w[[k]][i])
    })
    anomaly_score[,i] <- -log(rowSums(do.call(cbind, tmp)))
  }

  anomaly_score <- as.data.frame(anomaly_score)
  colnames(anomaly_score) <- colnames(x)
  anomaly_score
}
