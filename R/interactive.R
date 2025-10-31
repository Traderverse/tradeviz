#' Make Plot Interactive
#'
#' @description
#' Convert any ggplot2 object to an interactive plotly visualization.
#'
#' @param plot A ggplot2 object
#' @param tooltip Tooltip variables (default: "all")
#' @param dynamicTicks Use dynamic ticks (default: TRUE)
#' @param ...Additional arguments passed to ggplotly
#'
#' @return A plotly object
#' @export
#'
#' @examples
#' \dontrun{
#' p <- data %>% plot_candles()
#' make_interactive(p)
#'
#' # Or use pipe
#' data %>%
#'   plot_equity_curve() %>%
#'   make_interactive()
#' }
make_interactive <- function(plot, tooltip = "all", dynamicTicks = TRUE, ...) {
  
  # Handle patchwork objects
  if (inherits(plot, "patchwork")) {
    warning("Interactive conversion of patchwork objects may not preserve layout. ",
            "Consider plotting panels separately.")
  }
  
  p_interactive <- plotly::ggplotly(plot, tooltip = tooltip, dynamicTicks = dynamicTicks, ...)
  
  # Configure for better UX
  p_interactive <- plotly::config(
    p_interactive,
    displayModeBar = TRUE,
    displaylogo = FALSE,
    modeBarButtonsToRemove = c("lasso2d", "select2d", "autoScale2d")
  )
  
  p_interactive
}

#' Plot Interactive Candlesticks
#'
#' @description
#' Create interactive candlestick chart using plotly directly for better
#' performance and features compared to converting from ggplot2.
#'
#' @param data Data frame with OHLC data
#' @param title Chart title (default: auto-generated)
#' @param show_volume Show volume bars (default: TRUE)
#'
#' @return A plotly object
#' @export
plot_interactive <- function(data, title = NULL, show_volume = TRUE) {
  
  required_cols <- c("datetime", "open", "high", "low", "close")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  if (is.null(title)) {
    if ("symbol" %in% names(data)) {
      title <- paste("Interactive Chart:", unique(data$symbol)[1])
    } else {
      title <- "Interactive Candlestick Chart"
    }
  }
  
  # Main candlestick chart
  fig <- plotly::plot_ly(data, x = ~datetime, type = "candlestick",
                         open = ~open, high = ~high, low = ~low, close = ~close,
                         increasing = list(line = list(color = "#26a69a")),
                         decreasing = list(line = list(color = "#ef5350")),
                         name = "Price")
  
  # Add volume if requested and available
  if (show_volume && "volume" %in% names(data)) {
    # Determine colors based on price direction
    data$direction <- ifelse(data$close >= data$open, "up", "down")
    colors <- ifelse(data$direction == "up", "#26a69a", "#ef5350")
    
    fig <- plotly::subplot(
      fig,
      plotly::plot_ly(data, x = ~datetime, y = ~volume, type = "bar",
                     marker = list(color = colors),
                     name = "Volume",
                     yaxis = "y2"),
      nrows = 2,
      heights = c(0.7, 0.3),
      shareX = TRUE
    )
  }
  
  # Layout
  fig <- plotly::layout(
    fig,
    title = title,
    xaxis = list(title = "Date", rangeslider = list(visible = FALSE)),
    yaxis = list(title = "Price"),
    hovermode = "x unified",
    plot_bgcolor = "white",
    paper_bgcolor = "white"
  )
  
  # Configure
  fig <- plotly::config(
    fig,
    displayModeBar = TRUE,
    displaylogo = FALSE,
    modeBarButtonsToRemove = c("lasso2d", "select2d")
  )
  
  fig
}

#' Create Multi-Indicator Chart
#'
#' @description
#' Create a multi-panel chart showing price with multiple indicators.
#'
#' @param data Data frame with price and indicator columns
#' @param indicators Vector of indicator column names to plot
#' @param indicator_types Vector of types: "overlay", "panel" (default: all "panel")
#' @param title Chart title (default: auto-generated)
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A patchwork object
#' @export
#'
#' @examples
#' \dontrun{
#' data %>%
#'   add_sma(20) %>%
#'   add_rsi(14) %>%
#'   add_macd() %>%
#'   plot_multi_indicator(
#'     indicators = c("sma_20", "rsi", "macd"),
#'     indicator_types = c("overlay", "panel", "panel")
#'   )
#' }
plot_multi_indicator <- function(data,
                                indicators,
                                indicator_types = rep("panel", length(indicators)),
                                title = "Price with Indicators",
                                theme_dark = FALSE) {
  
  # Validate
  if (length(indicators) != length(indicator_types)) {
    stop("Length of indicators and indicator_types must match")
  }
  
  missing_cols <- setdiff(indicators, names(data))
  if (length(missing_cols) > 0) {
    stop("Missing indicator columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Main price chart
  p_price <- plot_candles(data, title = title, show_volume = FALSE, theme_dark = theme_dark)
  
  # Add overlay indicators
  overlay_inds <- indicators[indicator_types == "overlay"]
  for (ind in overlay_inds) {
    p_price <- p_price + add_indicator_line(ind)
  }
  
  # Create panel plots
  panel_inds <- indicators[indicator_types == "panel"]
  panel_plots <- list()
  
  for (ind in panel_inds) {
    p_panel <- ggplot2::ggplot(data, ggplot2::aes(x = .data$datetime, y = .data[[ind]])) +
      ggplot2::geom_line(color = "#1976d2", linewidth = 1) +
      ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      ggplot2::labs(x = NULL, y = ind) +
      theme_trading(dark = theme_dark)
    
    panel_plots[[ind]] <- p_panel
  }
  
  # Combine all plots
  if (length(panel_plots) > 0) {
    all_plots <- c(list(p_price), panel_plots)
    combined <- patchwork::wrap_plots(all_plots, ncol = 1, heights = c(0.5, rep(0.5/length(panel_plots), length(panel_plots))))
  } else {
    combined <- p_price
  }
  
  combined
}

#' Create Strategy Dashboard
#'
#' @description
#' Create a comprehensive multi-panel dashboard showing strategy performance.
#'
#' @param results Backtest results object from tradeengine
#' @param title Dashboard title (default: "Strategy Dashboard")
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A patchwork object
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeengine)
#' results <- backtest(strategy, initial_capital = 10000)
#' plot_strategy_dashboard(results)
#' }
plot_strategy_dashboard <- function(results,
                                   title = "Strategy Dashboard",
                                   theme_dark = FALSE) {
  
  if (!inherits(results, "backtest_result")) {
    stop("Input must be a backtest_result object from tradeengine")
  }
  
  # Extract data
  equity_data <- results$equity
  
  # 1. Equity curve
  p1 <- plot_equity_curve(results, title = "Equity Curve", 
                         drawdown_panel = FALSE, theme_dark = theme_dark)
  
  # 2. Drawdown
  p2 <- plot_drawdown(results, title = "Drawdown", 
                     highlight_max = TRUE, theme_dark = theme_dark)
  
  # 3. Returns distribution
  p3 <- plot_returns_distribution(results, title = "Returns Distribution",
                                 show_normal = TRUE, theme_dark = theme_dark)
  
  # 4. Monthly returns (if enough data)
  if (nrow(equity_data) > 30) {
    p4 <- plot_monthly_returns(equity_data, title = "Monthly Returns",
                              theme_dark = theme_dark)
    
    # Combine all 4 plots
    combined <- (p1 | p3) / (p2 | p4) +
      patchwork::plot_annotation(
        title = title,
        theme = theme_trading(dark = theme_dark)
      )
  } else {
    # Combine 3 plots if not enough data for monthly
    combined <- p1 / (p2 | p3) +
      patchwork::plot_annotation(
        title = title,
        theme = theme_trading(dark = theme_dark)
      )
  }
  
  combined
}

#' Create Backtest Report Layout
#'
#' @description
#' Create a comprehensive report layout with all key visualizations.
#'
#' @param results Backtest results
#' @param data Original price data (optional, for price chart)
#' @param metrics Summary metrics data frame (optional)
#' @param title Report title (default: "Backtest Report")
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A patchwork object
#' @export
plot_backtest_report <- function(results,
                                data = NULL,
                                metrics = NULL,
                                title = "Backtest Report",
                                theme_dark = FALSE) {
  
  if (!inherits(results, "backtest_result")) {
    stop("results must be a backtest_result object")
  }
  
  # Main dashboard
  dashboard <- plot_strategy_dashboard(results, title = title, theme_dark = theme_dark)
  
  # Add price chart if data provided
  if (!is.null(data)) {
    p_price <- plot_candles(data, title = "Price Action", 
                           show_volume = TRUE, theme_dark = theme_dark)
    
    # Combine
    dashboard <- p_price / dashboard +
      patchwork::plot_layout(heights = c(0.3, 0.7))
  }
  
  dashboard
}

#' Plot Portfolio Allocation
#'
#' @description
#' Visualize portfolio allocation as a pie or bar chart.
#'
#' @param data Data frame with columns: asset, weight/value
#' @param type Chart type: "pie", "bar", "treemap" (default: "pie")
#' @param value_col Column name for values (default: "weight")
#' @param label_col Column name for labels (default: "asset")
#' @param title Chart title (default: "Portfolio Allocation")
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot or plotly object
#' @export
plot_allocation <- function(data,
                           type = "pie",
                           value_col = "weight",
                           label_col = "asset",
                           title = "Portfolio Allocation",
                           theme_dark = FALSE) {
  
  if (!all(c(value_col, label_col) %in% names(data))) {
    stop("Required columns not found")
  }
  
  if (type == "pie") {
    # Pie chart using ggplot2
    p <- ggplot2::ggplot(data, ggplot2::aes(x = "", y = .data[[value_col]], 
                                            fill = .data[[label_col]])) +
      ggplot2::geom_bar(stat = "identity", width = 1) +
      ggplot2::coord_polar("y", start = 0) +
      ggplot2::labs(title = title, fill = label_col) +
      ggplot2::scale_fill_manual(values = get_trading_palette(nrow(data))) +
      theme_trading(dark = theme_dark) +
      ggplot2::theme(
        axis.text = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        axis.title = ggplot2::element_blank(),
        panel.grid = ggplot2::element_blank()
      )
    
  } else if (type == "bar") {
    # Bar chart
    p <- ggplot2::ggplot(data, ggplot2::aes(x = reorder(.data[[label_col]], .data[[value_col]]), 
                                            y = .data[[value_col]],
                                            fill = .data[[label_col]])) +
      ggplot2::geom_col() +
      ggplot2::coord_flip() +
      ggplot2::labs(title = title, x = label_col, y = value_col) +
      ggplot2::scale_fill_manual(values = get_trading_palette(nrow(data))) +
      ggplot2::scale_y_continuous(labels = scales::percent_format()) +
      theme_trading(dark = theme_dark) +
      ggplot2::theme(legend.position = "none")
    
  } else {
    stop("Unsupported chart type: ", type)
  }
  
  p
}

#' Plot Weight Evolution
#'
#' @description
#' Show how portfolio weights change over time.
#'
#' @param data Data frame with columns: datetime, asset, weight
#' @param title Chart title (default: "Portfolio Weights Over Time")
#' @param type Chart type: "area", "line" (default: "area")
#' @param theme_dark Use dark theme (default: FALSE)
#'
#' @return A ggplot object
#' @export
plot_weights <- function(data,
                        title = "Portfolio Weights Over Time",
                        type = "area",
                        theme_dark = FALSE) {
  
  required_cols <- c("datetime", "asset", "weight")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  if (type == "area") {
    p <- ggplot2::ggplot(data, ggplot2::aes(x = .data$datetime, y = .data$weight, 
                                            fill = .data$asset)) +
      ggplot2::geom_area(position = "stack", alpha = 0.7) +
      ggplot2::labs(title = title, x = "Date", y = "Weight", fill = "Asset") +
      ggplot2::scale_y_continuous(labels = scales::percent_format()) +
      ggplot2::scale_fill_manual(values = get_trading_palette(length(unique(data$asset)))) +
      theme_trading(dark = theme_dark)
    
  } else if (type == "line") {
    p <- ggplot2::ggplot(data, ggplot2::aes(x = .data$datetime, y = .data$weight, 
                                            color = .data$asset)) +
      ggplot2::geom_line(linewidth = 1) +
      ggplot2::labs(title = title, x = "Date", y = "Weight", color = "Asset") +
      ggplot2::scale_y_continuous(labels = scales::percent_format()) +
      ggplot2::scale_color_manual(values = get_trading_palette(length(unique(data$asset)))) +
      theme_trading(dark = theme_dark)
    
  } else {
    stop("Unsupported chart type: ", type)
  }
  
  p
}
