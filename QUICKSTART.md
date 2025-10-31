# 🚀 tradeviz Quick Start (5 Minutes)

Get started with financial visualization in 5 minutes!

## Installation

```r
devtools::install_github("tradingverse/tradeviz")
```

## 30-Second Example

```r
library(tradeviz)
library(tradeio)
library(tradeengine)

# Get data, add indicators, backtest, visualize
fetch_prices("AAPL", from = "2024-01-01") %>%
  add_sma(20) %>%
  add_rsi(14) %>%
  add_strategy(entry = rsi < 30, exit = rsi > 70) %>%
  backtest(initial_capital = 10000) %>%
  plot_strategy_dashboard()
```

## Common Tasks

### 1. Candlestick Chart

```r
# Basic
data %>% plot_candles()

# With indicators
data %>%
  add_sma(20) %>%
  plot_candles() +
  add_indicator_line("sma_20", color = "blue")
```

### 2. Equity Curve

```r
# Basic
results %>% plot_equity_curve()

# With drawdown
results %>% plot_equity_curve(drawdown_panel = TRUE)
```

### 3. Interactive Chart

```r
# Make any plot interactive
data %>%
  plot_candles() %>%
  make_interactive()

# Native interactive candlesticks
data %>% plot_interactive()
```

### 4. Strategy Dashboard

```r
# 4-panel comprehensive dashboard
results %>% plot_strategy_dashboard()
```

### 5. Correlation Heatmap

```r
# Multi-asset correlation
multi_asset_data %>%
  plot_correlation()
```

### 6. Performance Comparison

```r
# Compare multiple strategies
combined_results %>%
  plot_performance_comparison(group_col = "strategy")
```

## Key Functions

### Chart Types
- `plot_candles()` - Candlestick with volume
- `plot_line()` - Simple line chart
- `plot_ohlc()` - OHLC bars

### Performance
- `plot_equity_curve()` - Equity over time
- `plot_drawdown()` - Drawdown analysis
- `plot_returns_distribution()` - Return histogram
- `plot_monthly_returns()` - Calendar heatmap

### Analytics
- `plot_correlation()` - Correlation matrix
- `plot_rolling_sharpe()` - Rolling Sharpe ratio
- `plot_risk_return()` - Risk-return scatter

### Dashboards
- `plot_strategy_dashboard()` - Multi-panel dashboard
- `plot_multi_indicator()` - Price + indicators
- `make_interactive()` - Convert to plotly

## Styling

```r
# Use trading theme
plot + theme_trading()

# Dark theme
plot + theme_trading(dark = TRUE)

# Trading colors
plot + scale_color_trading()
```

## Tips

### Customization
```r
# All plots are ggplot2 objects
plot_candles(data) +
  labs(title = "My Custom Title") +
  theme_minimal()
```

### Composition
```r
# Use patchwork for layouts
library(patchwork)

p1 <- plot_equity_curve(results1, drawdown_panel = FALSE)
p2 <- plot_drawdown(results1)

p1 / p2  # Stack vertically
p1 | p2  # Side by side
```

### Saving
```r
# Static
ggsave("plot.png", plot, width = 10, height = 6, dpi = 300)

# Interactive
htmlwidgets::saveWidget(interactive_plot, "plot.html")
```

## Integration

### With TradingVerse
```r
library(tradingverse)  # Loads all packages

# Complete workflow
fetch_prices("AAPL") %>%         # tradeio
  add_rsi(14) %>%                # tradefeatures
  add_strategy(...) %>%          # tradeengine
  backtest() %>%                 # tradeengine
  plot_strategy_dashboard()      # tradeviz
```

## Next Steps

1. **Read README.md** for complete function reference
2. **Try examples/** for more complex scenarios
3. **Check vignettes** for detailed tutorials
4. **Browse ?tradeviz** for API documentation

## Common Patterns

### Multi-Indicator Chart
```r
data %>%
  add_sma(20) %>%
  add_rsi(14) %>%
  add_macd() %>%
  plot_multi_indicator(
    indicators = c("sma_20", "rsi", "macd"),
    indicator_types = c("overlay", "panel", "panel")
  )
```

### Backtest Visualization
```r
# Complete backtest analysis
results %>% plot_strategy_dashboard()

# Individual components
results %>% plot_equity_curve()
results %>% plot_drawdown()
results %>% plot_returns_distribution()
results %>% plot_monthly_returns()
```

### Portfolio Analysis
```r
# Allocation
allocation_data %>% plot_allocation(type = "pie")

# Weight evolution
weights_data %>% plot_weights(type = "area")
```

## Pro Tips

1. **Use dark theme** for presentations: `theme_dark = TRUE`
2. **Make dashboards interactive** for exploration
3. **Normalize comparisons** with `normalize = TRUE`
4. **Facet by symbol** automatically with multi-symbol data
5. **Add custom annotations** with ggplot2 layers

---

**Ready to visualize!** 📊

For more details: `?tradeviz` or visit https://tradingverse.org
