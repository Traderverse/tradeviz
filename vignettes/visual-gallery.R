## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 5,
  dpi = 96,
  out.width = "100%"
)


## ----setup--------------------------------------------------------------------
library(tradeviz)
library(dplyr)


## ----sample_data--------------------------------------------------------------
# Create sample OHLC data
set.seed(123)
n <- 100
dates <- seq.Date(Sys.Date() - n + 1, Sys.Date(), by = "day")

# Generate synthetic prices
returns <- rnorm(n, 0.0005, 0.02)
close_prices <- 100 * cumprod(1 + returns)

# OHLC data
sample_data <- tibble(
  symbol = "AAPL",
  datetime = as.POSIXct(dates),
  open = close_prices + rnorm(n, 0, 0.5),
  high = pmax(close_prices + abs(rnorm(n, 1, 0.5)), close_prices),
  low = pmin(close_prices - abs(rnorm(n, 1, 0.5)), close_prices),
  close = close_prices,
  volume = rpois(n, 1000000)
)


## ----candlestick--------------------------------------------------------------
sample_data %>%
  plot_candles(title = "AAPL - Candlestick Chart", show_volume = FALSE)


## ----line_chart---------------------------------------------------------------
sample_data %>%
  plot_line(title = "AAPL - Close Price")


## ----equity_curve-------------------------------------------------------------
# Create sample equity curve
equity_data <- tibble(
  datetime = as.POSIXct(dates),
  equity = 10000 * cumprod(1 + rnorm(n, 0.001, 0.015))
)

equity_data %>%
  plot_equity_curve(title = "Strategy Performance", drawdown_panel = FALSE)


## ----drawdown-----------------------------------------------------------------
equity_data %>%
  plot_drawdown(title = "Strategy Drawdown")


## ----correlation, fig.height=6, fig.width=7-----------------------------------
# Create multi-asset returns
set.seed(456)
cor_data <- data.frame(
  AAPL = rnorm(n, 0.001, 0.02),
  GOOGL = rnorm(n, 0.001, 0.018),
  MSFT = rnorm(n, 0.0008, 0.016),
  AMZN = rnorm(n, 0.0012, 0.025)
)

plot_correlation(cor_data, title = "Asset Correlation Matrix")


## ----palettes, fig.height=3---------------------------------------------------
# Show available color schemes
scales::show_col(get_trading_palette("classic", 8))

