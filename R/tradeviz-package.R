#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

#' tradeviz: Financial Visualization Suite for TradingVerse
#'
#' @description
#' A comprehensive visualization package for quantitative trading and investment
#' research. Provides beautiful, publication-ready charts with minimal code.
#'
#' @section Key Features:
#' \describe{
#'   \item{Chart Plotting}{Candlestick, OHLC, line, and area charts with indicator overlays}
#'   \item{Performance Visualization}{Equity curves, drawdown plots, return analysis}
#'   \item{Risk Analytics}{Correlation heatmaps, rolling metrics, efficient frontiers}
#'   \item{Portfolio Analysis}{Allocation pies, weight evolution, contribution attribution}
#'   \item{Interactive Charts}{Plotly integration for web-ready visualizations}
#'   \item{Custom Themes}{Professional trading-style themes and color palettes}
#' }
#'
#' @section Main Functions:
#' \describe{
#'   \item{\code{\link{plot_candles}}}{Create candlestick charts}
#'   \item{\code{\link{plot_equity_curve}}}{Plot strategy equity curves}
#'   \item{\code{\link{plot_drawdown}}}{Visualize drawdowns}
#'   \item{\code{\link{plot_correlation}}}{Correlation heatmaps}
#'   \item{\code{\link{plot_interactive}}}{Make any plot interactive}
#'   \item{\code{\link{plot_strategy_dashboard}}}{Multi-panel strategy dashboard}
#' }
#'
#' @section Integration:
#' tradeviz works seamlessly with other TradingVerse packages:
#' \itemize{
#'   \item \strong{tradeengine}: Visualize backtest results
#'   \item \strong{tradeio}: Plot fetched market data
#'   \item \strong{tradefeatures}: Show indicators on charts
#'   \item \strong{trademetrics}: Display performance metrics
#' }
#'
#' @examples
#' \dontrun{
#' library(tradeviz)
#' library(tradeengine)
#' library(tradefeatures)
#'
#' # Basic candlestick chart
#' data |> plot_candles()
#'
#' # With indicators
#' data |>
#'   add_sma(20) |>
#'   plot_candles() |>
#'   add_indicator_line(sma_20, color = "blue")
#'
#' # Backtest results
#' results |>
#'   plot_equity_curve()
#'
#' # Interactive dashboard
#' results |>
#'   plot_strategy_dashboard() |>
#'   make_interactive()
#' }
#'
#' @name tradeviz-package
#' @keywords internal
NULL

# Suppress R CMD check notes for NSE (non-standard evaluation)
utils::globalVariables(c(
  ".", "symbol", "datetime", "date", "open", "high", "low", "close", "volume",
  "adjusted", "equity", "drawdown", "returns", "cumulative_returns",
  "position", "trades", "pnl", "value", "weight", "allocation",
  "correlation", "variable", "Var1", "Var2", "metric", "label",
  "month", "year", "monthly_return", "avg_return", "cum_return",
  "upper", "lower", "middle", "ma", "indicator", "name", "type",
  "sharpe", "volatility", "max_dd", "cagr", "win_rate", "rsi"
))

# Import pipe operator
#' @importFrom magrittr %>%
#' @importFrom rlang .data :=
#' @importFrom stats cor sd dnorm rnorm rpois runif reorder
#' @importFrom utils tail install.packages
#' @importFrom grDevices colorRampPalette
NULL
