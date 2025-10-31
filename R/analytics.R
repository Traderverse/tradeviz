#' Plot Correlation Heatmap
#'
#' @description
#' Create correlation matrix heatmap for multiple assets or indicators.
#'
#' @param data Wide-format data frame with columns to correlate, or market data with symbol column
#' @param method Correlation method: "pearson", "spearman", or "kendall" (default: "pearson")
#' @param title Chart title (default: "Correlation Matrix")
#' @param show_values Show correlation values on tiles (default: TRUE)
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
#'
#' @examples
#' \dontrun{
#' # Multiple assets
#' prices %>%
#'   select(datetime, symbol, close) %>%
#'   pivot_wider(names_from = symbol, values_from = close) %>%
#'   plot_correlation()
#' }
plot_correlation <- function(data,
                            method = "pearson",
                            title = "Correlation Matrix",
                            show_values = TRUE,
                            theme_dark = FALSE) {
  
  # If data has symbol column, pivot to wide format
  if ("symbol" %in% names(data) && "close" %in% names(data)) {
    data_wide <- data %>%
      dplyr::select(.data$datetime, .data$symbol, .data$close) %>%
      tidyr::pivot_wider(names_from = .data$symbol, values_from = .data$close)
    
    # Remove datetime column for correlation
    data_wide <- data_wide %>% dplyr::select(-.data$datetime)
  } else {
    data_wide <- data %>% dplyr::select(where(is.numeric))
  }
  
  # Calculate correlation
  cor_matrix <- cor(data_wide, use = "pairwise.complete.obs", method = method)
  
  # Convert to long format for plotting
  cor_data <- as.data.frame(cor_matrix) %>%
    tibble::rownames_to_column("Var1") %>%
    tidyr::pivot_longer(-.data$Var1, names_to = "Var2", values_to = "correlation")
  
  p <- ggplot2::ggplot(cor_data, ggplot2::aes(x = .data$Var1, y = .data$Var2, fill = .data$correlation)) +
    ggplot2::geom_tile(color = "white", linewidth = 0.5) +
    ggplot2::scale_fill_gradient2(
      low = "#ef5350",
      mid = "white",
      high = "#26a69a",
      midpoint = 0,
      limits = c(-1, 1),
      name = "Correlation"
    ) +
    ggplot2::labs(
      title = title,
      x = NULL,
      y = NULL
    ) +
    theme_trading(dark = theme_dark) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      panel.grid = ggplot2::element_blank()
    )
  
  if (show_values) {
    p <- p +
      ggplot2::geom_text(
        ggplot2::aes(label = sprintf("%.2f", .data$correlation)),
        size = 3
      )
  }
  
  p
}

#' Plot Generic Heatmap
#'
#' @description
#' Create a heatmap from any matrix-like data.
#'
#' @param data Data frame with three columns: x, y, value
#' @param x Column name for x-axis
#' @param y Column name for y-axis
#' @param value Column name for color values
#' @param title Chart title
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
plot_heatmap <- function(data, x, y, value, title = "Heatmap", theme_dark = FALSE) {
  
  ggplot2::ggplot(data, ggplot2::aes(x = .data[[x]], y = .data[[y]], fill = .data[[value]])) +
    ggplot2::geom_tile(color = "white", linewidth = 0.5) +
    ggplot2::scale_fill_viridis_c(name = value) +
    ggplot2::labs(title = title, x = x, y = y) +
    theme_trading(dark = theme_dark) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      panel.grid = ggplot2::element_blank()
    )
}

#' Plot Rolling Metric
#'
#' @description
#' Plot any rolling metric over time (e.g., rolling Sharpe, volatility).
#'
#' @param data Data frame with datetime and metric columns
#' @param metric Column name for metric to plot
#' @param title Chart title (default: auto-generated)
#' @param smooth Add smoothing line (default: FALSE)
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
plot_rolling <- function(data,
                        metric,
                        title = NULL,
                        smooth = FALSE,
                        theme_dark = FALSE) {
  
  if (!metric %in% names(data)) {
    stop("Column '", metric, "' not found in data")
  }
  
  if (is.null(title)) {
    title <- paste("Rolling", metric)
  }
  
  p <- ggplot2::ggplot(data, ggplot2::aes(x = .data$datetime, y = .data[[metric]])) +
    ggplot2::geom_line(color = "#1976d2", linewidth = 1) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    ggplot2::labs(title = title, x = "Date", y = metric) +
    theme_trading(dark = theme_dark)
  
  if (smooth) {
    p <- p + ggplot2::geom_smooth(se = FALSE, color = "#ef5350", linewidth = 0.8)
  }
  
  p
}

#' Plot Rolling Sharpe Ratio
#'
#' @description
#' Calculate and plot rolling Sharpe ratio.
#'
#' @param data Data frame with returns column
#' @param window Rolling window size (default: 60)
#' @param returns_col Name of returns column (default: auto-detect)
#' @param title Chart title (default: "Rolling Sharpe Ratio")
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
plot_rolling_sharpe <- function(data,
                                window = 60,
                                returns_col = NULL,
                                title = "Rolling Sharpe Ratio",
                                theme_dark = FALSE) {
  
  if (is.null(returns_col)) {
    returns_col <- detect_returns_column(data)
    if (is.null(returns_col)) {
      stop("No returns column found")
    }
  }
  
  # Calculate rolling Sharpe
  data_calc <- data %>%
    dplyr::mutate(
      rolling_mean = zoo::rollmean(.data[[returns_col]], k = window, fill = NA, align = "right"),
      rolling_sd = zoo::rollapply(.data[[returns_col]], width = window, FUN = sd, fill = NA, align = "right"),
      rolling_sharpe = .data$rolling_mean / .data$rolling_sd * sqrt(252)  # Annualized
    )
  
  ggplot2::ggplot(data_calc, ggplot2::aes(x = .data$datetime, y = .data$rolling_sharpe)) +
    ggplot2::geom_line(color = "#1976d2", linewidth = 1) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    ggplot2::geom_hline(yintercept = 1, linetype = "dotted", color = "#26a69a", linewidth = 0.8) +
    ggplot2::labs(
      title = title,
      subtitle = sprintf("Window: %d periods", window),
      x = "Date",
      y = "Sharpe Ratio"
    ) +
    theme_trading(dark = theme_dark)
}

#' Plot Rolling Correlation
#'
#' @description
#' Plot rolling correlation between two series.
#'
#' @param data Data frame with two columns to correlate
#' @param x First column name
#' @param y Second column name
#' @param window Rolling window size (default: 60)
#' @param title Chart title (default: auto-generated)
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
plot_rolling_correlation <- function(data,
                                    x,
                                    y,
                                    window = 60,
                                    title = NULL,
                                    theme_dark = FALSE) {
  
  if (!all(c(x, y) %in% names(data))) {
    stop("Columns not found: ", paste(setdiff(c(x, y), names(data)), collapse = ", "))
  }
  
  if (is.null(title)) {
    title <- paste("Rolling Correlation:", x, "vs", y)
  }
  
  # Calculate rolling correlation
  data_calc <- data %>%
    dplyr::mutate(
      rolling_cor = zoo::rollapply(
        data.frame(.data[[x]], .data[[y]]),
        width = window,
        FUN = function(z) cor(z[,1], z[,2], use = "pairwise.complete.obs"),
        by.column = FALSE,
        fill = NA,
        align = "right"
      )
    )
  
  ggplot2::ggplot(data_calc, ggplot2::aes(x = .data$datetime, y = .data$rolling_cor)) +
    ggplot2::geom_line(color = "#1976d2", linewidth = 1) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    ggplot2::geom_hline(yintercept = c(-0.5, 0.5), linetype = "dotted", 
                       color = "grey70", linewidth = 0.5) +
    ggplot2::labs(
      title = title,
      subtitle = sprintf("Window: %d periods", window),
      x = "Date",
      y = "Correlation"
    ) +
    ggplot2::scale_y_continuous(limits = c(-1, 1)) +
    theme_trading(dark = theme_dark)
}

#' Plot Performance Comparison
#'
#' @description
#' Compare multiple strategies or assets on the same chart.
#'
#' @param data Data frame with columns: datetime, strategy/symbol name, equity
#' @param group_col Column name for grouping (default: "strategy" or "symbol")
#' @param value_col Column name for values (default: auto-detect equity)
#' @param normalize Normalize all series to start at 100 (default: TRUE)
#' @param title Chart title (default: "Performance Comparison")
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
plot_performance_comparison <- function(data,
                                       group_col = NULL,
                                       value_col = NULL,
                                       normalize = TRUE,
                                       title = "Performance Comparison",
                                       theme_dark = FALSE) {
  
  # Auto-detect group column
  if (is.null(group_col)) {
    if ("strategy" %in% names(data)) {
      group_col <- "strategy"
    } else if ("symbol" %in% names(data)) {
      group_col <- "symbol"
    } else if ("name" %in% names(data)) {
      group_col <- "name"
    } else {
      stop("Cannot detect grouping column. Specify group_col parameter.")
    }
  }
  
  # Auto-detect value column
  if (is.null(value_col)) {
    value_col <- detect_equity_column(data)
    if (is.null(value_col)) {
      value_col <- "value"
    }
  }
  
  # Normalize if requested
  if (normalize) {
    data <- data %>%
      dplyr::group_by(.data[[group_col]]) %>%
      dplyr::mutate(
        normalized_value = .data[[value_col]] / dplyr::first(.data[[value_col]]) * 100
      ) %>%
      dplyr::ungroup()
    value_col <- "normalized_value"
  }
  
  ggplot2::ggplot(data, ggplot2::aes(x = .data$datetime, y = .data[[value_col]], 
                                     color = .data[[group_col]])) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::labs(
      title = title,
      x = "Date",
      y = if (normalize) "Normalized Value (Base = 100)" else "Value",
      color = group_col
    ) +
    ggplot2::scale_color_manual(values = get_trading_palette(length(unique(data[[group_col]])))) +
    theme_trading(dark = theme_dark)
}

#' Plot Risk-Return Scatter
#'
#' @description
#' Scatter plot showing risk vs return for multiple strategies.
#'
#' @param data Data frame with columns: name, return, risk
#' @param return_col Column name for returns (default: "return")
#' @param risk_col Column name for risk (default: "risk" or "volatility")
#' @param label_col Column name for labels (default: auto-detect)
#' @param title Chart title (default: "Risk-Return Profile")
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
plot_risk_return <- function(data,
                            return_col = "return",
                            risk_col = NULL,
                            label_col = NULL,
                            title = "Risk-Return Profile",
                            theme_dark = FALSE) {
  
  # Auto-detect risk column
  if (is.null(risk_col)) {
    if ("risk" %in% names(data)) {
      risk_col <- "risk"
    } else if ("volatility" %in% names(data)) {
      risk_col <- "volatility"
    } else if ("sd" %in% names(data)) {
      risk_col <- "sd"
    } else {
      stop("Cannot detect risk column. Specify risk_col parameter.")
    }
  }
  
  # Auto-detect label column
  if (is.null(label_col)) {
    if ("name" %in% names(data)) {
      label_col <- "name"
    } else if ("strategy" %in% names(data)) {
      label_col <- "strategy"
    } else if ("symbol" %in% names(data)) {
      label_col <- "symbol"
    }
  }
  
  p <- ggplot2::ggplot(data, ggplot2::aes(x = .data[[risk_col]], y = .data[[return_col]])) +
    ggplot2::geom_point(size = 4, color = "#1976d2", alpha = 0.7) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    ggplot2::labs(
      title = title,
      x = risk_col,
      y = return_col
    ) +
    ggplot2::scale_x_continuous(labels = scales::percent_format()) +
    ggplot2::scale_y_continuous(labels = scales::percent_format()) +
    theme_trading(dark = theme_dark)
  
  # Add labels if available
  if (!is.null(label_col) && label_col %in% names(data)) {
    p <- p +
      ggrepel::geom_text_repel(
        ggplot2::aes(label = .data[[label_col]]),
        size = 3,
        box.padding = 0.5
      )
  }
  
  p
}
