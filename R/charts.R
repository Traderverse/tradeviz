#' Plot Candlestick Chart
#'
#' @description
#' Create beautiful candlestick charts with optional volume bars and
#' indicator overlays. Automatically handles multiple symbols with faceting.
#'
#' @param data Data frame with columns: datetime, open, high, low, close, (optional) volume
#' @param title Chart title (default: auto-generated)
#' @param subtitle Chart subtitle (default: NULL)
#' @param show_volume Show volume bars below (default: TRUE)
#' @param volume_height Relative height of volume panel (default: 0.2)
#' @param color_up Color for up candles (default: "#26a69a")
#' @param color_down Color for down candles (default: "#ef5350")
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object or patchwork object (if volume shown)
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#' data <- fetch_prices("AAPL", from = "2024-01-01")
#' plot_candles(data)
#' plot_candles(data, show_volume = FALSE, theme_dark = TRUE)
#' }
plot_candles <- function(data, 
                        title = NULL, 
                        subtitle = NULL,
                        show_volume = TRUE,
                        volume_height = 0.2,
                        color_up = "#26a69a",
                        color_down = "#ef5350",
                        theme_dark = FALSE) {
  
  # Validate required columns
  required_cols <- c("datetime", "open", "high", "low", "close")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Prepare data
  plot_data <- data %>%
    dplyr::mutate(
      direction = ifelse(.data$close >= .data$open, "up", "down"),
      color = ifelse(.data$direction == "up", color_up, color_down)
    )
  
  # Auto-generate title if not provided
  if (is.null(title)) {
    if ("symbol" %in% names(data)) {
      symbols <- unique(data$symbol)
      title <- paste("Candlestick Chart:", paste(symbols, collapse = ", "))
    } else {
      title <- "Candlestick Chart"
    }
  }
  
  # Main candlestick plot
  p_candles <- ggplot2::ggplot(plot_data) +
    # High-Low lines
    ggplot2::geom_segment(
      ggplot2::aes(x = .data$datetime, xend = .data$datetime, 
                  y = .data$low, yend = .data$high),
      color = "grey40", linewidth = 0.3
    ) +
    # Candle bodies
    ggplot2::geom_segment(
      ggplot2::aes(x = .data$datetime, xend = .data$datetime,
                  y = .data$open, yend = .data$close, color = .data$direction),
      linewidth = 2
    ) +
    ggplot2::scale_color_manual(
      values = c("up" = color_up, "down" = color_down),
      guide = "none"
    ) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = NULL,
      y = "Price"
    ) +
    ggplot2::scale_y_continuous(labels = scales::dollar_format()) +
    ggplot2::scale_x_datetime(date_labels = "%b %d", date_breaks = "1 month") +
    theme_trading(dark = theme_dark)
  
  # Add faceting if multiple symbols
  if ("symbol" %in% names(data) && length(unique(data$symbol)) > 1) {
    p_candles <- p_candles + ggplot2::facet_wrap(~symbol, scales = "free_y", ncol = 1)
  }
  
  # Add volume if requested
  if (show_volume && "volume" %in% names(data)) {
    p_volume <- ggplot2::ggplot(plot_data) +
      ggplot2::geom_col(
        ggplot2::aes(x = .data$datetime, y = .data$volume, fill = .data$direction),
        width = 0.8
      ) +
      ggplot2::scale_fill_manual(
        values = c("up" = color_up, "down" = color_down),
        guide = "none"
      ) +
      ggplot2::labs(x = "Date", y = "Volume") +
      ggplot2::scale_y_continuous(labels = scales::comma_format()) +
      ggplot2::scale_x_datetime(date_labels = "%b %d", date_breaks = "1 month") +
      theme_trading(dark = theme_dark) +
      ggplot2::theme(
        axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
      )
    
    if ("symbol" %in% names(data) && length(unique(data$symbol)) > 1) {
      p_volume <- p_volume + ggplot2::facet_wrap(~symbol, scales = "free_y", ncol = 1)
    }
    
    # Combine using patchwork
    p_combined <- p_candles / p_volume + 
      patchwork::plot_layout(heights = c(1 - volume_height, volume_height))
    
    return(p_combined)
  }
  
  return(p_candles)
}

#' Plot OHLC Bar Chart
#'
#' @description
#' Create OHLC (Open-High-Low-Close) bar chart.
#'
#' @param data Data frame with columns: datetime, open, high, low, close
#' @param title Chart title (default: auto-generated)
#' @param color_up Color for up bars (default: "#26a69a")
#' @param color_down Color for down bars (default: "#ef5350")
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
plot_ohlc <- function(data, 
                     title = NULL,
                     color_up = "#26a69a",
                     color_down = "#ef5350",
                     theme_dark = FALSE) {
  
  required_cols <- c("datetime", "open", "high", "low", "close")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  plot_data <- data %>%
    dplyr::mutate(
      direction = ifelse(.data$close >= .data$open, "up", "down")
    )
  
  if (is.null(title)) {
    title <- "OHLC Chart"
  }
  
  ggplot2::ggplot(plot_data) +
    # High-Low line
    ggplot2::geom_segment(
      ggplot2::aes(x = .data$datetime, xend = .data$datetime,
                  y = .data$low, yend = .data$high, color = .data$direction),
      linewidth = 0.5
    ) +
    # Open tick
    ggplot2::geom_segment(
      ggplot2::aes(x = .data$datetime - 3600, xend = .data$datetime,
                  y = .data$open, yend = .data$open, color = .data$direction),
      linewidth = 0.8
    ) +
    # Close tick
    ggplot2::geom_segment(
      ggplot2::aes(x = .data$datetime, xend = .data$datetime + 3600,
                  y = .data$close, yend = .data$close, color = .data$direction),
      linewidth = 0.8
    ) +
    ggplot2::scale_color_manual(
      values = c("up" = color_up, "down" = color_down),
      guide = "none"
    ) +
    ggplot2::labs(title = title, x = "Date", y = "Price") +
    ggplot2::scale_y_continuous(labels = scales::dollar_format()) +
    theme_trading(dark = theme_dark)
}

#' Plot Line Chart
#'
#' @description
#' Create simple line chart, optionally with multiple series.
#'
#' @param data Data frame with datetime and price columns
#' @param y Column name for y-axis (default: "close")
#' @param title Chart title (default: auto-generated)
#' @param color Line color (default: "#1976d2")
#' @param linewidth Line width (default: 1)
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
#'
#' @examples
#' \dontrun{
#' data %>% plot_line(y = "close")
#' data %>% plot_line(y = "sma_20", color = "red")
#' }
plot_line <- function(data,
                     y = "close",
                     title = NULL,
                     color = "#1976d2",
                     linewidth = 1,
                     theme_dark = FALSE) {
  
  if (!y %in% names(data)) {
    stop("Column '", y, "' not found in data")
  }
  
  if (is.null(title)) {
    title <- paste("Line Chart:", y)
  }
  
  p <- ggplot2::ggplot(data, ggplot2::aes(x = .data$datetime, y = .data[[y]])) +
    ggplot2::geom_line(color = color, linewidth = linewidth) +
    ggplot2::labs(title = title, x = "Date", y = y) +
    theme_trading(dark = theme_dark)
  
  # Add faceting if multiple symbols
  if ("symbol" %in% names(data) && length(unique(data$symbol)) > 1) {
    p <- p + ggplot2::facet_wrap(~symbol, scales = "free_y", ncol = 1)
  }
  
  p
}

#' Plot Area Chart
#'
#' @description
#' Create area chart with optional fill gradient.
#'
#' @param data Data frame with datetime and value columns
#' @param y Column name for y-axis (default: "close")
#' @param title Chart title (default: auto-generated)
#' @param fill Fill color (default: "#1976d2")
#' @param alpha Fill transparency (default: 0.3)
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
plot_area <- function(data,
                     y = "close",
                     title = NULL,
                     fill = "#1976d2",
                     alpha = 0.3,
                     theme_dark = FALSE) {
  
  if (!y %in% names(data)) {
    stop("Column '", y, "' not found in data")
  }
  
  if (is.null(title)) {
    title <- paste("Area Chart:", y)
  }
  
  ggplot2::ggplot(data, ggplot2::aes(x = .data$datetime, y = .data[[y]])) +
    ggplot2::geom_area(fill = fill, alpha = alpha) +
    ggplot2::geom_line(color = fill, linewidth = 1) +
    ggplot2::labs(title = title, x = "Date", y = y) +
    theme_trading(dark = theme_dark)
}

#' Add Indicator Line to Existing Plot
#'
#' @description
#' Add an indicator line overlay to an existing chart. This function
#' returns a layer that can be added to a ggplot object.
#'
#' @param y Column name for indicator
#' @param color Line color (default: "#1976d2")
#' @param linewidth Line width (default: 1)
#' @param linetype Line type (default: "solid")
#'
#' @return A ggplot layer
#' @export
#'
#' @examples
#' \dontrun{
#' data %>%
#'   plot_candles() +
#'   add_indicator_line("sma_20", color = "blue") +
#'   add_indicator_line("sma_50", color = "red")
#' }
add_indicator_line <- function(y, color = "#1976d2", linewidth = 1, linetype = "solid") {
  ggplot2::geom_line(
    ggplot2::aes(y = .data[[y]]),
    color = color,
    linewidth = linewidth,
    linetype = linetype,
    na.rm = TRUE
  )
}

#' Add Indicator Ribbon
#'
#' @description
#' Add a ribbon (band) overlay, useful for Bollinger Bands or envelopes.
#'
#' @param ymin Column name for lower bound
#' @param ymax Column name for upper bound
#' @param fill Fill color (default: "#1976d2")
#' @param alpha Transparency (default: 0.2)
#'
#' @return A ggplot layer
#' @export
add_indicator_ribbon <- function(ymin, ymax, fill = "#1976d2", alpha = 0.2) {
  ggplot2::geom_ribbon(
    ggplot2::aes(ymin = .data[[ymin]], ymax = .data[[ymax]]),
    fill = fill,
    alpha = alpha,
    na.rm = TRUE
  )
}
