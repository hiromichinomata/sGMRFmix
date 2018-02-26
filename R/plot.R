#' Plot multivariate data
#'
#' @import ggplot2
#' @importFrom tidyr gather
#'
#' @export
plot_multivariate_data <- function(df, label = NULL, point_size = 1) {
  M <- ncol(df)
  names <- colnames(df)
  if (!is.data.frame(df)) {
    df <- as.data.frame(df)
  }
  df <- transform(df, time = seq_len(nrow(df)))
  df <- gather(df, "variable", "value", -time)

  if (is.null(label)) {
    ggplot(df, aes_string("time", "value")) + geom_line() +
      facet_wrap(~ variable, ncol = 1, strip.position = "left") +
      xlab("") + ylab("")
  } else {
    if (is.numeric(label) == 1) {
      label <- data.frame(rep(list(label), M))
    }
    if (!is.data.frame(label)) {
      label <- as.data.frame(label)
    }
    colnames(label) <- names
    label <- transform(label, time = seq_len(nrow(label)))
    label <- gather(label, "variable", "label", -time)
    if (is.logical(label[["label"]])) {
      label <- transform(label, label = !label)
    } else {
      label <- transform(label, label = as.factor(label))
    }
    df2 <- merge(df, label, by=c("time", "variable"))
    ggplot(df2, aes_string("time", "value")) +
      geom_point(aes_string(color = "label"), size = point_size) +
      facet_wrap(~ variable, ncol = 1, strip.position = "left") +
      scale_color_discrete(guide = FALSE) +
      xlab("") + ylab("")
  }
}
