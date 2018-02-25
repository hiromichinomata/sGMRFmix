#' Plot multivariate data
#'
#' @import ggplot2
#' @importFrom tidyr gather
#'
#' @export
plot_multivariate_data <- function(df) {
  df <- transform(df, time = seq_len(nrow(df)))
  df <- gather(df, "variable", "value", -time)
  ggplot(df, aes_string("time", "value")) + geom_line() +
    facet_wrap(~ variable, ncol = 1, strip.position = "left") +
    xlab("") + ylab("")
}
