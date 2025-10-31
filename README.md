# 📊 tradeviz: Financial Visualization Suite for TradingVerse

Beautiful, publication-ready financial visualizations with minimal code. Built for the TradingVerse ecosystem.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-%3E%3D4.1.0-blue)](https://www.r-project.org/)

## ✨ Features

- 📈 **Chart Plotting**: Candlesticks, OHLC, line, and area charts
- 💹 **Performance Visualization**: Equity curves, drawdown plots, return analysis
- 🔍 **Risk Analytics**: Correlation heatmaps, rolling metrics, risk-return scatter
- 📊 **Portfolio Analysis**: Allocation charts, weight evolution, contribution attribution
- 🎨 **Professional Themes**: Trading-optimized dark and light themes
- 🖱️ **Interactive Charts**: Plotly integration for web-ready visualizations
- 🎯 **Multi-Panel Dashboards**: Comprehensive strategy reporting
- 🚀 **Zero Configuration**: Sensible defaults, works out of the box

## 📦 Installation

```r
# Install from GitHub
devtools::install_github("tradingverse/tradeviz")

# Or for development
git clone https://github.com/Traderverse/tradeviz.git
cd tradeviz
source("setup.R")
```

## 🚀 Quick Start

### Basic Candlestick Chart

```r
library(tradeviz)
library(tradeio)

# Fetch data
data <- fetch_prices("AAPL", from = "2024-01-01")

# Create candlestick chart with volume
plot_candles(data)
```

### Equity Curve with Drawdown

```r
library(tradeengine)

# Run backtest
results <- backtest(strategy, initial_capital = 10000)

# Visualize
plot_equity_curve(results, drawdown_panel = TRUE)
```

### Interactive Dashboard

```r
# Create comprehensive dashboard
plot_strategy_dashboard(results) %>%
  make_interactive()
```

## 📊 Visualization Gallery

### Chart Plotting Functions

#### Candlestick Charts

```r
# Basic candlestick
data %>% plot_candles()

# Without volume
data %>% plot_candles(show_volume = FALSE)

# Dark theme
data %>% plot_candles(theme_dark = TRUE)

# With indicators
data %>%
  add_sma(20) %>%
  add_sma(50) %>%
  plot_candles() +
  add_indicator_line("sma_20", color = "blue") +
  add_indicator_line("sma_50", color = "red")
```

#### OHLC and Line Charts

```r
# OHLC bars
data %>% plot_ohlc()

# Line chart
data %>% plot_line(y = "close")

# Area chart
data %>% plot_area(y = "close", fill = "#1976d2", alpha = 0.3)
```

### Performance Visualizations

#### Equity Curves

```r
# Basic equity curve
results %>% plot_equity_curve()

# With benchmark comparison
results %>% plot_equity_curve(benchmark = benchmark_data)

# Log scale for long-term
results %>% plot_equity_curve(log_scale = TRUE)

# Without drawdown panel
results %>% plot_equity_curve(drawdown_panel = FALSE)
```

#### Drawdown Analysis

```r
# Drawdown chart
results %>% plot_drawdown()

# Underwater chart (alias)
results %>% plot_underwater()

# Without highlighting max DD
results %>% plot_drawdown(highlight_max = FALSE)
```

#### Returns Analysis

```r
# Returns distribution
results %>% plot_returns_distribution()

# Without normal overlay
results %>% plot_returns_distribution(show_normal = FALSE)

# Monthly returns heatmap
equity_data %>% plot_monthly_returns()
```

### Analytical Plots

#### Correlation Analysis

```r
# Correlation matrix
multi_asset_data %>%
  plot_correlation()

# Spearman correlation
multi_asset_data %>%
  plot_correlation(method = "spearman")

# Without values
multi_asset_data %>%
  plot_correlation(show_values = FALSE)
```

#### Rolling Metrics

```r
# Rolling Sharpe ratio
returns_data %>%
  plot_rolling_sharpe(window = 60)

# Rolling correlation
data %>%
  plot_rolling_correlation(x = "returns_spy", y = "returns_qqq", window = 60)

# Generic rolling metric
data %>%
  plot_rolling(metric = "volatility", smooth = TRUE)
```

#### Performance Comparison

```r
# Compare multiple strategies
combined_data %>%
  plot_performance_comparison(group_col = "strategy")

# Without normalization
combined_data %>%
  plot_performance_comparison(normalize = FALSE)
```

#### Risk-Return Scatter

```r
# Risk-return profile
summary_data %>%
  plot_risk_return(return_col = "cagr", risk_col = "volatility")
```

### Portfolio Visualizations

#### Allocation Charts

```r
# Pie chart
allocation_data %>%
  plot_allocation(type = "pie")

# Bar chart
allocation_data %>%
  plot_allocation(type = "bar")
```

#### Weight Evolution

```r
# Area chart showing weight changes
weights_data %>%
  plot_weights(type = "area")

# Line chart
weights_data %>%
  plot_weights(type = "line")
```

### Multi-Panel Dashboards

#### Strategy Dashboard

```r
# Comprehensive 4-panel dashboard
results %>%
  plot_strategy_dashboard()

# Dark theme
results %>%
  plot_strategy_dashboard(theme_dark = TRUE)
```

#### Multi-Indicator Chart

```r
# Price with multiple indicators
data %>%
  add_sma(20) %>%
  add_rsi(14) %>%
  add_macd() %>%
  plot_multi_indicator(
    indicators = c("sma_20", "rsi", "macd"),
    indicator_types = c("overlay", "panel", "panel")
  )
```

#### Backtest Report

```r
# Complete backtest report
plot_backtest_report(
  results = results,
  data = price_data,
  metrics = summary_metrics
)
```

### Interactive Visualizations

#### Make Any Plot Interactive

```r
# Convert ggplot to plotly
data %>%
  plot_equity_curve() %>%
  make_interactive()

# Interactive candlestick (native plotly)
data %>%
  plot_interactive(show_volume = TRUE)
```

## 🎨 Themes and Styling

### Professional Trading Theme

```r
# Use trading theme
library(ggplot2)

ggplot(data, aes(x = date, y = close)) +
  geom_line() +
  theme_trading()  # Light theme

# Dark theme
ggplot(data, aes(x = date, y = close)) +
  geom_line(color = "white") +
  theme_trading(dark = TRUE)
```

### Trading Color Scales

```r
# Trading colors (green/red for up/down)
ggplot(data, aes(x = date, y = returns, color = direction)) +
  geom_point() +
  scale_color_trading()

# Trading fills
ggplot(data, aes(x = date, y = returns, fill = direction)) +
  geom_col() +
  scale_fill_trading()
```

### Custom Palettes

```r
# Get trading color palette
colors <- get_trading_palette(5)

# Sequential palette
colors <- get_trading_palette(10, type = "sequential")

# Diverging palette
colors <- get_trading_palette(11, type = "diverging")
```

## 🔗 Integration with TradingVerse

### Complete Workflow Example

```r
library(tradingverse)  # Loads all packages

# Data → Features → Backtest → Visualize
results <- fetch_prices(c("AAPL", "MSFT"), from = "2023-01-01") %>%
  
  # Add technical indicators (tradefeatures)
  add_sma(20) %>%
  add_rsi(14) %>%
  add_bbands(20, 2) %>%
  
  # Define strategy (tradeengine)
  add_strategy(
    entry = (rsi < 30) & (close < bb_lower),
    exit = (rsi > 70) | (close > bb_upper)
  ) %>%
  
  # Backtest (tradeengine)
  backtest(initial_capital = 100000)

# Visualize results (tradeviz)
results %>%
  plot_strategy_dashboard() %>%
  make_interactive()

# Detailed chart with indicators
fetch_prices("AAPL") %>%
  add_sma(20) %>%
  add_rsi(14) %>%
  plot_multi_indicator(
    indicators = c("sma_20", "rsi"),
    indicator_types = c("overlay", "panel")
  )
```

## 📚 Function Reference

### Chart Plotting
- `plot_candles()` - Candlestick charts with volume
- `plot_ohlc()` - OHLC bar charts
- `plot_line()` - Line charts
- `plot_area()` - Area charts
- `add_indicator_line()` - Add indicator overlay
- `add_indicator_ribbon()` - Add band overlay (Bollinger Bands)

### Performance Visualization
- `plot_equity_curve()` - Portfolio equity over time
- `plot_drawdown()` - Drawdown from peak
- `plot_underwater()` - Underwater equity chart (alias)
- `plot_returns_distribution()` - Histogram of returns
- `plot_monthly_returns()` - Calendar heatmap

### Analytical Plots
- `plot_correlation()` - Correlation matrix heatmap
- `plot_heatmap()` - Generic heatmap
- `plot_rolling()` - Rolling metric chart
- `plot_rolling_sharpe()` - Rolling Sharpe ratio
- `plot_rolling_correlation()` - Rolling correlation
- `plot_performance_comparison()` - Compare strategies
- `plot_risk_return()` - Risk-return scatter plot

### Portfolio Visualizations
- `plot_allocation()` - Portfolio allocation (pie/bar)
- `plot_weights()` - Weight evolution over time

### Interactive & Dashboards
- `make_interactive()` - Convert to plotly
- `plot_interactive()` - Native plotly candlesticks
- `plot_multi_indicator()` - Multi-panel indicator chart
- `plot_strategy_dashboard()` - 4-panel strategy dashboard
- `plot_backtest_report()` - Comprehensive report layout

### Themes & Styling
- `theme_trading()` - Professional trading theme
- `scale_color_trading()` - Trading color scale
- `scale_fill_trading()` - Trading fill scale
- `get_trading_palette()` - Get color palette

## 🎯 Design Philosophy

### Intuitive API
```r
# Pipe-friendly
data %>%
  plot_candles() %>%
  make_interactive()

# Sensible defaults
plot_candles(data)  # Just works!

# Extensive customization
plot_candles(data, 
             show_volume = FALSE,
             theme_dark = TRUE,
             color_up = "green",
             color_down = "red")
```

### Automatic Data Detection
```r
# Works with different column names
plot_equity_curve(data)  # Finds 'equity', 'value', 'portfolio_value', etc.

# Works with backtest results
results %>% plot_equity_curve()  # Extracts equity automatically
```

### Multi-Symbol Support
```r
# Automatically facets by symbol
multi_data %>% plot_candles()  # Creates panel for each symbol
```

### Flexible Composition
```r
# Combine plots with patchwork
p1 <- plot_equity_curve(results1, drawdown_panel = FALSE)
p2 <- plot_equity_curve(results2, drawdown_panel = FALSE)

library(patchwork)
p1 | p2  # Side by side
p1 / p2  # Stacked
```

## 💡 Tips & Best Practices

### Performance
- Use `plot_interactive()` for native plotly candlesticks (faster than `make_interactive()`)
- For large datasets, consider sampling or aggregating before plotting
- Interactive plots work best with < 10,000 points

### Customization
```r
# Add custom layers to any plot
plot_candles(data) +
  geom_vline(xintercept = signal_date, linetype = "dashed") +
  annotate("text", x = signal_date, y = price, label = "Buy Signal")

# Customize themes
plot_equity_curve(results) +
  theme_trading(base_size = 14) +
  labs(title = "My Custom Title")
```

### Saving Plots
```r
# Save static plot
p <- plot_strategy_dashboard(results)
ggsave("strategy_dashboard.png", p, width = 12, height = 8, dpi = 300)

# Save interactive plot
p_interactive <- make_interactive(p)
htmlwidgets::saveWidget(p_interactive, "dashboard.html")
```

### Dashboards in Reports
```r
# Use in R Markdown
```{r fig.width=12, fig.height=8}
results %>% plot_strategy_dashboard()
```

# Interactive version
```{r}
results %>%
  plot_strategy_dashboard() %>%
  make_interactive()
```
```

## 🤝 Contributing

We welcome contributions! Areas of interest:
- New visualization types
- Performance optimizations
- Additional themes
- Documentation improvements
- Bug fixes

## 📄 License

MIT License - see [LICENSE](LICENSE) file.

## 🔗 Links

- **GitHub**: https://github.com/Traderverse/tradeviz
- **Documentation**: https://tradingverse.github.io/tradeviz
- **TradingVerse**: https://tradingverse.org
- **Issues**: https://github.com/Traderverse/tradeviz/issues

## 🙏 Acknowledgments

Built on top of:
- **ggplot2**: Grammar of graphics
- **plotly**: Interactive visualizations
- **patchwork**: Plot composition
- **viridis**: Color palettes
- **RColorBrewer**: Color schemes

Inspired by:
- **TradingView**: Chart aesthetics
- **Bloomberg Terminal**: Professional styling
- **Python's mplfinance**: Financial plotting

---

**Built with ❤️ for the TradingVerse ecosystem**

*Making quantitative trading visualization accessible to everyone*
