#' Plot Equity Curve
#'
#' @description
#' Visualize portfolio equity over time. Works with backtest results from
#' tradeengine or any data frame with equity/value column.
#'
#' @param data Data frame or backtest_result object with equity column
#' @param title Chart title (default: "Equity Curve")
#' @param benchmark Optional benchmark data to overlay
#' @param drawdown_panel Show drawdown below (default: TRUE)
#' @param log_scale Use logarithmic y-axis (default: FALSE)
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot or patchwork object
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeengine)
#' results <- backtest(strategy, initial_capital = 10000)
#' plot_equity_curve(results)
#' plot_equity_curve(results, drawdown_panel = FALSE, log_scale = TRUE)
#' }
plot_equity_curve <- function(data,
                              title = "Equity Curve",
                              benchmark = NULL,
                              drawdown_panel = TRUE,
                              log_scale = FALSE,
                              theme_dark = FALSE) {
  
  # Handle backtest_results objects (from tradeengine::backtest)
  if (inherits(data, "backtest_results")) {
    plot_data <- data$equity_curve
  } else if (inherits(data, "backtest_result")) {
    plot_data <- data$equity
  } else {
    plot_data <- data
  }
  
  # Detect equity column
  equity_col <- detect_equity_column(plot_data)
  if (is.null(equity_col)) {
    stop("No equity/value column found. Expected 'equity', 'value', or 'portfolio_value'")
  }
  
  # Prepare data
  plot_data <- plot_data %>%
    dplyr::mutate(equity = .data[[equity_col]])
  
  # Calculate returns for coloring
  plot_data <- plot_data %>%
    dplyr::mutate(
      returns = (.data$equity / dplyr::lag(.data$equity) - 1),
      direction = ifelse(.data$returns >= 0, "positive", "negative")
    )
  
  # Main equity plot
  p_equity <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$datetime, y = .data$equity)) +
    ggplot2::geom_line(color = "#1976d2", linewidth = 1) +
    ggplot2::geom_area(fill = "#1976d2", alpha = 0.1) +
    ggplot2::labs(
      title = title,
      x = NULL,
      y = "Equity"
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::dollar_format(),
      trans = if (log_scale) "log10" else "identity"
    ) +
    theme_trading(dark = theme_dark)
  
  # Add benchmark if provided
  if (!is.null(benchmark)) {
    benchmark_col <- detect_equity_column(benchmark)
    if (!is.null(benchmark_col)) {
      p_equity <- p_equity +
        ggplot2::geom_line(
          data = benchmark,
          ggplot2::aes(x = .data$datetime, y = .data[[benchmark_col]]),
          color = "#ef5350",
          linewidth = 0.8,
          linetype = "dashed"
        )
    }
  }
  
  # Add drawdown panel if requested
  if (drawdown_panel) {
    drawdown_data <- calculate_drawdown(plot_data$equity)
    plot_data$drawdown <- drawdown_data
    
    p_drawdown <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$datetime, y = .data$drawdown)) +
      ggplot2::geom_area(fill = "#ef5350", alpha = 0.3) +
      ggplot2::geom_line(color = "#ef5350", linewidth = 0.8) +
      ggplot2::labs(x = "Date", y = "Drawdown") +
      ggplot2::scale_y_continuous(labels = scales::percent_format()) +
      theme_trading(dark = theme_dark) +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
    
    # Combine
    p_combined <- p_equity / p_drawdown + 
      patchwork::plot_layout(heights = c(0.7, 0.3))
    
    return(p_combined)
  }
  
  return(p_equity)
}

#' Plot Drawdown Chart
#'
#' @description
#' Visualize underwater equity chart showing drawdowns from peak.
#'
#' @param data Data frame or backtest_result with equity column
#' @param title Chart title (default: "Drawdown Analysis")
#' @param highlight_max Highlight maximum drawdown (default: TRUE)
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
plot_drawdown <- function(data,
                         title = "Drawdown Analysis",
                         highlight_max = TRUE,
                         theme_dark = FALSE) {
  
  # Handle backtest_results objects (from tradeengine::backtest)
  if (inherits(data, "backtest_results")) {
    plot_data <- data$equity_curve
  } else if (inherits(data, "backtest_result")) {
    plot_data <- data$equity
  } else {
    plot_data <- data
  }
  
  # Detect equity column
  equity_col <- detect_equity_column(plot_data)
  if (is.null(equity_col)) {
    stop("No equity column found")
  }
  
  # Calculate drawdown
  drawdown <- calculate_drawdown(plot_data[[equity_col]])
  plot_data$drawdown <- drawdown
  
  p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$datetime, y = .data$drawdown)) +
    ggplot2::geom_area(fill = "#ef5350", alpha = 0.3) +
    ggplot2::geom_line(color = "#ef5350", linewidth = 1) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    ggplot2::labs(
      title = title,
      x = "Date",
      y = "Drawdown from Peak"
    ) +
    ggplot2::scale_y_continuous(labels = scales::percent_format()) +
    theme_trading(dark = theme_dark)
  
  # Highlight maximum drawdown
  if (highlight_max) {
    max_dd_idx <- which.min(plot_data$drawdown)
    max_dd_point <- plot_data[max_dd_idx, ]
    
    p <- p +
      ggplot2::geom_point(
        data = max_dd_point,
        ggplot2::aes(x = .data$datetime, y = .data$drawdown),
        color = "#ef5350",
        size = 3
      ) +
      ggplot2::annotate(
        "text",
        x = max_dd_point$datetime,
        y = max_dd_point$drawdown,
        label = paste0("Max DD: ", scales::percent(max_dd_point$drawdown, accuracy = 0.1)),
        vjust = -1,
        hjust = 0.5,
        color = "#ef5350",
        fontface = "bold"
      )
  }
  
  p
}

#' Plot Underwater Chart
#'
#' @description
#' Alternative visualization of drawdowns (alias for plot_drawdown).
#'
#' @inheritParams plot_drawdown
#' @return A ggplot object
#' @export
plot_underwater <- function(data, title = "Underwater Equity Chart", 
                           highlight_max = TRUE, theme_dark = FALSE) {
  plot_drawdown(data, title = title, highlight_max = highlight_max, theme_dark = theme_dark)
}

#' Plot Returns Distribution
#'
#' @description
#' Histogram and density plot of returns distribution.
#'
#' @param data Data frame with returns column or backtest_result
#' @param returns_col Name of returns column (default: auto-detect)
#' @param bins Number of histogram bins (default: 50)
#' @param title Chart title (default: "Returns Distribution")
#' @param show_normal Show normal distribution overlay (default: TRUE)
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
plot_returns_distribution <- function(data,
                                     returns_col = NULL,
                                     bins = 50,
                                     title = "Returns Distribution",
                                     show_normal = TRUE,
                                     theme_dark = FALSE) {
  
  # Handle backtest_result
  if (inherits(data, "backtest_result")) {
    if ("equity" %in% names(data)) {
      equity <- data$equity$equity
      returns <- diff(log(equity))
    } else {
      stop("Cannot extract returns from backtest_result")
    }
    plot_data <- data.frame(returns = returns)
  } else {
    if (is.null(returns_col)) {
      returns_col <- detect_returns_column(data)
      if (is.null(returns_col)) {
        stop("No returns column found")
      }
    }
    plot_data <- data.frame(returns = data[[returns_col]])
  }
  
  # Remove NAs
  plot_data <- plot_data %>% dplyr::filter(!is.na(.data$returns))
  
  # Calculate statistics
  mean_ret <- mean(plot_data$returns)
  sd_ret <- sd(plot_data$returns)
  
  p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$returns)) +
    ggplot2::geom_histogram(
      ggplot2::aes(y = ggplot2::after_stat(density)),
      bins = bins,
      fill = "#1976d2",
      alpha = 0.6,
      color = "white"
    ) +
    ggplot2::geom_density(color = "#1976d2", linewidth = 1.2) +
    ggplot2::geom_vline(xintercept = mean_ret, linetype = "dashed", 
                       color = "#26a69a", linewidth = 1) +
    ggplot2::labs(
      title = title,
      subtitle = sprintf("Mean: %.2f%%, Std Dev: %.2f%%", mean_ret * 100, sd_ret * 100),
      x = "Returns",
      y = "Density"
    ) +
    ggplot2::scale_x_continuous(labels = scales::percent_format()) +
    theme_trading(dark = theme_dark)
  
  # Add normal distribution overlay
  if (show_normal) {
    normal_data <- data.frame(
      x = seq(min(plot_data$returns), max(plot_data$returns), length.out = 100)
    )
    normal_data$y <- dnorm(normal_data$x, mean = mean_ret, sd = sd_ret)
    
    p <- p +
      ggplot2::geom_line(
        data = normal_data,
        ggplot2::aes(x = .data$x, y = .data$y),
        color = "#ef5350",
        linetype = "dashed",
        linewidth = 1
      )
  }
  
  p
}

#' Plot Monthly Returns Heatmap
#'
#' @description
#' Calendar heatmap showing monthly returns.
#'
#' @param data Data frame with datetime and returns/equity
#' @param title Chart title (default: "Monthly Returns")
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
plot_monthly_returns <- function(data,
                                title = "Monthly Returns Heatmap",
                                theme_dark = FALSE) {
  
  # Detect equity or returns column
  equity_col <- detect_equity_column(data)
  if (is.null(equity_col)) {
    stop("No equity column found")
  }
  
  # Calculate monthly returns
  monthly_data <- data %>%
    dplyr::mutate(
      year = lubridate::year(.data$datetime),
      month = lubridate::month(.data$datetime, label = TRUE, abbr = TRUE)
    ) %>%
    dplyr::group_by(.data$year, .data$month) %>%
    dplyr::summarise(
      start_equity = dplyr::first(.data[[equity_col]]),
      end_equity = dplyr::last(.data[[equity_col]]),
      .groups = "drop"
    ) %>%
    dplyr::mutate(
      monthly_return = (.data$end_equity / .data$start_equity) - 1
    )
  
  ggplot2::ggplot(monthly_data, ggplot2::aes(x = .data$month, y = factor(.data$year))) +
    ggplot2::geom_tile(ggplot2::aes(fill = .data$monthly_return), color = "white", linewidth = 1) +
    ggplot2::geom_text(
      ggplot2::aes(label = scales::percent(.data$monthly_return, accuracy = 0.1)),
      size = 3
    ) +
    ggplot2::scale_fill_gradient2(
      low = "#ef5350",
      mid = "white",
      high = "#26a69a",
      midpoint = 0,
      labels = scales::percent_format(),
      name = "Return"
    ) +
    ggplot2::labs(
      title = title,
      x = "Month",
      y = "Year"
    ) +
    theme_trading(dark = theme_dark) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 0),
      panel.grid = ggplot2::element_blank()
    )
}

#' Helper: Calculate Drawdown
#' @keywords internal
calculate_drawdown <- function(equity) {
  cummax_equity <- cummax(equity)
  drawdown <- (equity - cummax_equity) / cummax_equity
  return(drawdown)
}

#' Helper: Detect Equity Column
#' @keywords internal
detect_equity_column <- function(data) {
  possible_names <- c("equity", "value", "portfolio_value", "portfolio_equity", "total_value")
  for (name in possible_names) {
    if (name %in% names(data)) {
      return(name)
    }
  }
  return(NULL)
}

#' Helper: Detect Returns Column
#' @keywords internal
detect_returns_column <- function(data) {
  possible_names <- c("returns", "return", "daily_returns", "pct_return", "pnl_pct")
  for (name in possible_names) {
    if (name %in% names(data)) {
      return(name)
    }
  }
  return(NULL)
}
