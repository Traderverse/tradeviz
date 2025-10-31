#' Professional Trading Theme for ggplot2
#'
#' @description
#' A clean, professional theme optimized for financial charts.
#' Features dark grid on light background, minimal clutter, and
#' clear axis labels suitable for presentations and reports.
#'
#' @param base_size Base font size (default: 11)
#' @param base_family Base font family (default: "")
#' @param dark Use dark theme (default: FALSE)
#'
#' @return A ggplot2 theme object
#' @export
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' ggplot(data, aes(x = date, y = close)) +
#'   geom_line() +
#'   theme_trading()
#' }
theme_trading <- function(base_size = 11, base_family = "", dark = FALSE) {
  if (dark) {
    theme_trading_dark(base_size, base_family)
  } else {
    theme_trading_light(base_size, base_family)
  }
}

#' @keywords internal
theme_trading_light <- function(base_size = 11, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # Grid
      panel.grid.major = ggplot2::element_line(color = "grey90", linewidth = 0.3),
      panel.grid.minor = ggplot2::element_line(color = "grey95", linewidth = 0.2),
      
      # Background
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      
      # Axes
      axis.line = ggplot2::element_line(color = "grey30", linewidth = 0.5),
      axis.ticks = ggplot2::element_line(color = "grey30", linewidth = 0.3),
      axis.text = ggplot2::element_text(color = "grey20", size = base_size * 0.9),
      axis.title = ggplot2::element_text(color = "grey10", size = base_size, 
                                         face = "bold", margin = ggplot2::margin(t = 5, b = 5)),
      
      # Legend
      legend.position = "right",
      legend.background = ggplot2::element_rect(fill = "white", color = "grey80", linewidth = 0.3),
      legend.key = ggplot2::element_rect(fill = "white", color = NA),
      legend.text = ggplot2::element_text(size = base_size * 0.9),
      legend.title = ggplot2::element_text(size = base_size, face = "bold"),
      
      # Title
      plot.title = ggplot2::element_text(size = base_size * 1.3, face = "bold", 
                                         hjust = 0, color = "grey10"),
      plot.subtitle = ggplot2::element_text(size = base_size * 1.1, 
                                            hjust = 0, color = "grey30"),
      plot.caption = ggplot2::element_text(size = base_size * 0.8, 
                                           hjust = 1, color = "grey50"),
      
      # Strips (for facets)
      strip.background = ggplot2::element_rect(fill = "grey90", color = "grey70"),
      strip.text = ggplot2::element_text(size = base_size, face = "bold", color = "grey10"),
      
      # Margins
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )
}

#' @keywords internal
theme_trading_dark <- function(base_size = 11, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # Grid
      panel.grid.major = ggplot2::element_line(color = "grey30", linewidth = 0.3),
      panel.grid.minor = ggplot2::element_line(color = "grey20", linewidth = 0.2),
      
      # Background
      plot.background = ggplot2::element_rect(fill = "grey10", color = NA),
      panel.background = ggplot2::element_rect(fill = "grey10", color = NA),
      
      # Axes
      axis.line = ggplot2::element_line(color = "grey70", linewidth = 0.5),
      axis.ticks = ggplot2::element_line(color = "grey70", linewidth = 0.3),
      axis.text = ggplot2::element_text(color = "grey80", size = base_size * 0.9),
      axis.title = ggplot2::element_text(color = "grey90", size = base_size, 
                                         face = "bold", margin = ggplot2::margin(t = 5, b = 5)),
      
      # Legend
      legend.position = "right",
      legend.background = ggplot2::element_rect(fill = "grey15", color = "grey40", linewidth = 0.3),
      legend.key = ggplot2::element_rect(fill = "grey15", color = NA),
      legend.text = ggplot2::element_text(size = base_size * 0.9, color = "grey80"),
      legend.title = ggplot2::element_text(size = base_size, face = "bold", color = "grey90"),
      
      # Title
      plot.title = ggplot2::element_text(size = base_size * 1.3, face = "bold", 
                                         hjust = 0, color = "grey95"),
      plot.subtitle = ggplot2::element_text(size = base_size * 1.1, 
                                            hjust = 0, color = "grey70"),
      plot.caption = ggplot2::element_text(size = base_size * 0.8, 
                                           hjust = 1, color = "grey50"),
      
      # Strips (for facets)
      strip.background = ggplot2::element_rect(fill = "grey20", color = "grey40"),
      strip.text = ggplot2::element_text(size = base_size, face = "bold", color = "grey90"),
      
      # Margins
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )
}

#' Trading Color Scale
#'
#' @description
#' Color scale with financial market conventions:
#' green for bullish/positive, red for bearish/negative.
#'
#' @param ... Additional arguments passed to scale_color_manual
#'
#' @return A ggplot2 color scale
#' @export
scale_color_trading <- function(...) {
  colors <- c(
    "positive" = "#26a69a",  # Teal/green for gains
    "negative" = "#ef5350",  # Red for losses
    "neutral" = "#78909c",   # Grey for neutral
    "long" = "#26a69a",
    "short" = "#ef5350",
    "benchmark" = "#1976d2", # Blue for benchmark
    "signal" = "#ffa726"     # Orange for signals
  )
  
  ggplot2::scale_color_manual(values = colors, ...)
}

#' Trading Fill Scale
#'
#' @description
#' Fill scale with financial market conventions.
#'
#' @param ... Additional arguments passed to scale_fill_manual
#'
#' @return A ggplot2 fill scale
#' @export
scale_fill_trading <- function(...) {
  colors <- c(
    "positive" = "#26a69a",
    "negative" = "#ef5350",
    "neutral" = "#78909c",
    "long" = "#26a69a",
    "short" = "#ef5350",
    "benchmark" = "#1976d2",
    "signal" = "#ffa726"
  )
  
  ggplot2::scale_fill_manual(values = colors, ...)
}

#' Get Trading Color Palette
#'
#' @description
#' Returns a vector of colors suitable for trading visualizations.
#'
#' @param n Number of colors needed
#' @param type Type of palette: "default", "sequential", "diverging", "qualitative"
#'
#' @return A character vector of hex colors
#' @export
#'
#' @examples
#' get_trading_palette(5)
#' get_trading_palette(10, "sequential")
get_trading_palette <- function(n, type = "default") {
  palettes <- list(
    default = c("#1976d2", "#26a69a", "#ffa726", "#ef5350", "#7e57c2", 
                "#66bb6a", "#ec407a", "#42a5f5", "#ffca28", "#ab47bc"),
    sequential = viridis::viridis(n),
    diverging = RColorBrewer::brewer.pal(min(n, 11), "RdYlGn"),
    qualitative = RColorBrewer::brewer.pal(min(n, 12), "Set3")
  )
  
  palette <- palettes[[type]]
  
  if (n > length(palette)) {
    # Interpolate if more colors needed
    colorRampPalette(palette)(n)
  } else {
    palette[1:n]
  }
}

#' Format Currency
#'
#' @description Helper to format numbers as currency
#'
#' @param x Numeric vector
#' @param prefix Currency symbol (default: "$")
#' @param suffix Currency suffix (default: "")
#' @param accuracy Rounding accuracy (default: 0.01)
#'
#' @return Character vector of formatted values
#' @keywords internal
format_currency <- function(x, prefix = "$", suffix = "", accuracy = 0.01) {
  scales::dollar(x, prefix = prefix, suffix = suffix, accuracy = accuracy)
}

#' Format Percentage
#'
#' @description Helper to format numbers as percentages
#'
#' @param x Numeric vector
#' @param accuracy Rounding accuracy (default: 0.01)
#'
#' @return Character vector of formatted values
#' @keywords internal
format_percentage <- function(x, accuracy = 0.01) {
  scales::percent(x, accuracy = accuracy)
}
