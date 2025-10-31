# tradeviz Examples - Comprehensive Demonstration
# This file showcases all major visualization functions

library(tradeviz)
library(tradeio)
library(tradefeatures)
library(tradeengine)
library(dplyr)

# ============================================================================
# Example 1: Basic Candlestick Chart
# ============================================================================

cat("\n=== Example 1: Candlestick Charts ===\n")

# Fetch some data
data <- fetch_prices("AAPL", from = "2024-01-01", to = "2024-10-31")

# Basic candlestick with volume
p1 <- plot_candles(data, title = "AAPL Candlestick Chart")
print(p1)

# Without volume
p2 <- plot_candles(data, show_volume = FALSE, title = "AAPL - No Volume")
print(p2)

# Dark theme
p3 <- plot_candles(data, theme_dark = TRUE, title = "AAPL - Dark Theme")
print(p3)

# ============================================================================
# Example 2: Candlesticks with Indicators
# ============================================================================

cat("\n=== Example 2: Charts with Indicators ===\n")

# Add indicators
data_with_indicators <- data %>%
  add_sma(20) %>%
  add_sma(50) %>%
  add_bbands(20, 2)

# Plot with overlays
p4 <- plot_candles(data_with_indicators, show_volume = FALSE) +
  add_indicator_line("sma_20", color = "blue", linewidth = 1) +
  add_indicator_line("sma_50", color = "red", linewidth = 1) +
  add_indicator_ribbon("bb_lower", "bb_upper", fill = "grey", alpha = 0.2)

print(p4)

# ============================================================================
# Example 3: Line and Area Charts
# ============================================================================

cat("\n=== Example 3: Line and Area Charts ===\n")

# Simple line chart
p5 <- plot_line(data, y = "close", title = "AAPL Close Price")
print(p5)

# Area chart
p6 <- plot_area(data, y = "close", fill = "#1976d2", alpha = 0.3)
print(p6)

# OHLC bars
p7 <- plot_ohlc(data, title = "AAPL OHLC Bars")
print(p7)

# ============================================================================
# Example 4: Backtest Visualizations
# ============================================================================

cat("\n=== Example 4: Backtest Performance ===\n")

# Run a simple backtest
strategy_data <- data %>%
  add_sma(20) %>%
  add_rsi(14) %>%
  add_strategy(
    name = "RSI Mean Reversion",
    entry = rsi < 30,
    exit = rsi > 70,
    position_size = 1000
  )

results <- backtest(strategy_data, initial_capital = 10000)

# Equity curve
p8 <- plot_equity_curve(results, title = "Strategy Equity Curve")
print(p8)

# Equity curve with drawdown panel
p9 <- plot_equity_curve(results, drawdown_panel = TRUE)
print(p9)

# Just drawdown
p10 <- plot_drawdown(results, highlight_max = TRUE)
print(p10)

# ============================================================================
# Example 5: Returns Analysis
# ============================================================================

cat("\n=== Example 5: Returns Analysis ===\n")

# Returns distribution
p11 <- plot_returns_distribution(results, 
                                 title = "Daily Returns Distribution",
                                 show_normal = TRUE)
print(p11)

# Monthly returns heatmap
if (nrow(results$equity) > 30) {
  p12 <- plot_monthly_returns(results$equity, 
                              title = "Monthly Returns Calendar")
  print(p12)
}

# ============================================================================
# Example 6: Multi-Asset Correlation
# ============================================================================

cat("\n=== Example 6: Correlation Analysis ===\n")

# Fetch multiple assets
multi_data <- fetch_prices(c("AAPL", "MSFT", "GOOGL", "AMZN"), 
                           from = "2024-01-01")

# Correlation heatmap
p13 <- plot_correlation(multi_data, 
                        title = "Tech Stock Correlations",
                        show_values = TRUE)
print(p13)

# ============================================================================
# Example 7: Rolling Metrics
# ============================================================================

cat("\n=== Example 7: Rolling Metrics ===\n")

# Calculate returns for rolling Sharpe
returns_data <- data %>%
  mutate(returns = (close / lag(close)) - 1)

# Rolling Sharpe ratio
p14 <- plot_rolling_sharpe(returns_data, 
                           window = 60,
                           title = "60-Day Rolling Sharpe Ratio")
print(p14)

# ============================================================================
# Example 8: Performance Comparison
# ============================================================================

cat("\n=== Example 8: Strategy Comparison ===\n")

# Run multiple strategies
strategy1 <- data %>%
  add_sma(20) %>%
  add_strategy(entry = close > sma_20, exit = close < sma_20) %>%
  backtest(initial_capital = 10000)

strategy2 <- data %>%
  add_rsi(14) %>%
  add_strategy(entry = rsi < 30, exit = rsi > 70) %>%
  backtest(initial_capital = 10000)

# Combine results
combined <- bind_rows(
  strategy1$equity %>% mutate(strategy = "SMA Trend"),
  strategy2$equity %>% mutate(strategy = "RSI Mean Reversion")
)

# Compare performance
p15 <- plot_performance_comparison(combined, 
                                   group_col = "strategy",
                                   normalize = TRUE,
                                   title = "Strategy Comparison (Normalized)")
print(p15)

# ============================================================================
# Example 9: Multi-Indicator Chart
# ============================================================================

cat("\n=== Example 9: Multi-Indicator Panel Chart ===\n")

# Add multiple indicators
indicator_data <- data %>%
  add_sma(20) %>%
  add_rsi(14) %>%
  add_macd()

# Multi-panel chart
p16 <- plot_multi_indicator(
  indicator_data,
  indicators = c("sma_20", "rsi", "macd"),
  indicator_types = c("overlay", "panel", "panel"),
  title = "AAPL with Multiple Indicators"
)
print(p16)

# ============================================================================
# Example 10: Strategy Dashboard
# ============================================================================

cat("\n=== Example 10: Comprehensive Strategy Dashboard ===\n")

# Full dashboard (4 panels)
p17 <- plot_strategy_dashboard(results, 
                               title = "RSI Mean Reversion Dashboard")
print(p17)

# Dark theme version
p18 <- plot_strategy_dashboard(results, 
                               title = "Dashboard - Dark Theme",
                               theme_dark = TRUE)
print(p18)

# ============================================================================
# Example 11: Interactive Visualizations
# ============================================================================

cat("\n=== Example 11: Interactive Charts ===\n")

# Make any plot interactive
p_interactive <- plot_equity_curve(results, drawdown_panel = FALSE) %>%
  make_interactive()
print(p_interactive)

# Native plotly candlesticks (better performance)
p_interactive2 <- plot_interactive(data, show_volume = TRUE)
print(p_interactive2)

# Interactive dashboard
p_interactive3 <- plot_strategy_dashboard(results) %>%
  make_interactive()
print(p_interactive3)

# ============================================================================
# Example 12: Portfolio Allocation
# ============================================================================

cat("\n=== Example 12: Portfolio Visualization ===\n")

# Create sample allocation data
allocation <- data.frame(
  asset = c("AAPL", "MSFT", "GOOGL", "AMZN", "Cash"),
  weight = c(0.25, 0.25, 0.20, 0.20, 0.10)
)

# Pie chart
p19 <- plot_allocation(allocation, type = "pie", 
                      title = "Portfolio Allocation")
print(p19)

# Bar chart
p20 <- plot_allocation(allocation, type = "bar",
                      title = "Portfolio Weights")
print(p20)

# ============================================================================
# Example 13: Custom Themes and Styling
# ============================================================================

cat("\n=== Example 13: Custom Themes ===\n")

library(ggplot2)

# Using theme_trading
p21 <- ggplot(data, aes(x = datetime, y = close)) +
  geom_line(color = "#1976d2", linewidth = 1) +
  labs(title = "Custom Plot with Trading Theme") +
  theme_trading()
print(p21)

# Dark theme
p22 <- ggplot(data, aes(x = datetime, y = close)) +
  geom_line(color = "white", linewidth = 1) +
  labs(title = "Custom Plot - Dark Theme") +
  theme_trading(dark = TRUE)
print(p22)

# Using trading color scales
price_direction <- data %>%
  mutate(direction = ifelse(close >= lag(close), "positive", "negative"))

p23 <- ggplot(price_direction, aes(x = datetime, y = close, color = direction)) +
  geom_point(alpha = 0.5) +
  scale_color_trading() +
  labs(title = "Price Action with Trading Colors") +
  theme_trading()
print(p23)

# ============================================================================
# Example 14: Combining Plots with Patchwork
# ============================================================================

cat("\n=== Example 14: Custom Layouts ===\n")

library(patchwork)

# Create individual plots
p_candles <- plot_candles(data, show_volume = FALSE, 
                         title = "Price Action")
p_equity <- plot_equity_curve(results, drawdown_panel = FALSE,
                             title = "Equity Curve")
p_returns <- plot_returns_distribution(results, 
                                      title = "Returns")
p_dd <- plot_drawdown(results, title = "Drawdown")

# Side by side
layout1 <- p_candles | p_equity
print(layout1)

# Grid layout
layout2 <- (p_candles | p_equity) / (p_returns | p_dd)
print(layout2)

# Complex layout
layout3 <- p_candles / (p_equity | p_returns | p_dd) +
  plot_annotation(
    title = "Comprehensive Trading Analysis",
    theme = theme_trading()
  )
print(layout3)

# ============================================================================
# Example 15: Exporting Plots
# ============================================================================

cat("\n=== Example 15: Saving Plots ===\n")

# Save static plot
ggsave("equity_curve.png", p8, width = 10, height = 6, dpi = 300)

# Save dashboard
ggsave("strategy_dashboard.png", p17, width = 12, height = 8, dpi = 300)

# Save interactive plot
htmlwidgets::saveWidget(p_interactive, "interactive_equity.html")

cat("\n✓ All examples complete! Plots saved to current directory.\n")

# ============================================================================
# Example 16: Complete Workflow
# ============================================================================

cat("\n=== Example 16: Complete TradingVerse Workflow ===\n")

# The full pipeline: Data → Features → Strategy → Backtest → Visualize

complete_workflow <- function(symbol, from_date) {
  # 1. Fetch data (tradeio)
  data <- fetch_prices(symbol, from = from_date)
  
  # 2. Add features (tradefeatures)
  data <- data %>%
    add_sma(20) %>%
    add_sma(50) %>%
    add_rsi(14) %>%
    add_bbands(20, 2) %>%
    add_macd()
  
  # 3. Define and backtest strategy (tradeengine)
  results <- data %>%
    add_strategy(
      name = "Multi-Indicator Strategy",
      entry = (rsi < 30) & (close < bb_lower) & (macd > macd_signal),
      exit = (rsi > 70) | (close > bb_upper),
      position_size = 1000
    ) %>%
    backtest(initial_capital = 10000)
  
  # 4. Visualize (tradeviz)
  dashboard <- plot_strategy_dashboard(results, 
                                      title = paste(symbol, "Strategy Dashboard"))
  
  # Create detailed chart
  detailed_chart <- plot_multi_indicator(
    data,
    indicators = c("sma_20", "sma_50", "rsi", "macd"),
    indicator_types = c("overlay", "overlay", "panel", "panel"),
    title = paste(symbol, "Technical Analysis")
  )
  
  # Combine and return
  list(
    data = data,
    results = results,
    dashboard = dashboard,
    chart = detailed_chart
  )
}

# Run complete workflow
workflow_output <- complete_workflow("AAPL", "2024-01-01")

# Display results
print(workflow_output$dashboard)
print(workflow_output$chart)

# Make interactive
workflow_output$dashboard %>% 
  make_interactive() %>%
  print()

cat("\n🎉 Complete workflow demonstration finished!\n")
cat("tradeviz provides beautiful visualizations with minimal code.\n")
cat("Explore the TradingVerse ecosystem for more!\n")
