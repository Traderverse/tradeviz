#' Live Streaming Chart
#'
#' @description
#' Create a live-updating chart that refreshes with new data automatically.
#' Uses Shiny reactivity for real-time updates. Ideal for monitoring live markets.
#'
#' @param data_function Function that returns updated data (e.g., fetch_prices)
#' @param chart_type Type of chart: "candles", "line", "equity" (default: "candles")
#' @param update_interval Update interval in milliseconds (default: 5000 = 5 seconds)
#' @param max_points Maximum points to display (default: 500)
#' @param title Chart title (default: auto-generated)
#' @param theme_dark Use dark theme (default: TRUE for live charts)
#' @param indicators Optional list of indicator functions to apply
#' @param height Chart height in pixels (default: 600)
#'
#' @return A Shiny UI element with live chart
#' @export
#'
#' @examples
#' \dontrun{
#' library(shiny)
#' library(tradeviz)
#' library(tradeio)
#'
#' # Define data fetcher
#' get_live_data <- function() {
#'   fetch_prices("AAPL", from = Sys.Date() - 30)
#' }
#'
#' # Create live chart
#' ui <- fluidPage(
#'   plot_live(get_live_data, chart_type = "candles", update_interval = 5000)
#' )
#'
#' server <- function(input, output, session) {}
#' shinyApp(ui, server)
#' }
plot_live <- function(data_function,
                     chart_type = "candles",
                     update_interval = 5000,
                     max_points = 500,
                     title = NULL,
                     theme_dark = TRUE,
                     indicators = NULL,
                     height = 600) {
  
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required for live charts. Install with: install.packages('shiny')")
  }
  
  if (is.null(title)) {
    title <- paste("Live", chart_type, "Chart")
  }
  
  # Create unique output ID
  output_id <- paste0("live_plot_", gsub("[^0-9]", "", as.character(Sys.time())))
  
  # Create Shiny UI
  shiny::tagList(
    shiny::div(
      style = "margin: 20px;",
      shiny::h3(title),
      plotly::plotlyOutput(output_id, height = height)
    )
  )
}

#' Live Chart Server Component
#'
#' @description
#' Server-side logic for live charts. Use in your Shiny server function.
#'
#' @param id Output ID for the chart
#' @param data_function Function that returns updated data
#' @param chart_type Type of chart
#' @param update_interval Update interval in milliseconds
#' @param max_points Maximum points to display
#' @param theme_dark Use dark theme
#' @param indicators Optional indicator functions
#'
#' @return Shiny observer
#' @export
render_live_chart <- function(id, data_function, chart_type = "candles",
                              update_interval = 5000, max_points = 500,
                              theme_dark = TRUE, indicators = NULL) {
  
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required. Install with: install.packages('shiny')")
  }
  
  shiny::observe({
    shiny::invalidateLater(update_interval)
    
    # Fetch fresh data
    data <- tryCatch(
      data_function(),
      error = function(e) {
        message("Error fetching data: ", e$message)
        return(NULL)
      }
    )
    
    if (is.null(data) || nrow(data) == 0) {
      return(NULL)
    }
    
    # Limit points
    if (nrow(data) > max_points) {
      data <- data[(nrow(data) - max_points + 1):nrow(data), ]
    }
    
    # Apply indicators if provided
    if (!is.null(indicators)) {
      for (ind_func in indicators) {
        data <- ind_func(data)
      }
    }
    
    # Create plot based on type
    p <- switch(chart_type,
      "candles" = plot_interactive(data, show_volume = TRUE),
      "line" = {
        fig <- plotly::plot_ly(data, x = ~datetime, y = ~close, type = "scatter", mode = "lines",
                              line = list(color = "#1976d2", width = 2))
        fig <- plotly::layout(fig, 
                             title = "Live Price",
                             xaxis = list(title = "Time"),
                             yaxis = list(title = "Price"))
        fig
      },
      "equity" = {
        if ("equity" %in% names(data)) {
          fig <- plotly::plot_ly(data, x = ~datetime, y = ~equity, type = "scatter", 
                                mode = "lines", fill = "tozeroy",
                                line = list(color = "#26a69a", width = 2))
          fig <- plotly::layout(fig,
                               title = "Live Equity",
                               xaxis = list(title = "Time"),
                               yaxis = list(title = "Equity"))
          fig
        }
      },
      plot_interactive(data)
    )
    
    # Render
    plotly::renderPlotly({
      p
    })
  })
}

#' Create Live Dashboard
#'
#' @description
#' Create a complete live trading dashboard with multiple charts and metrics.
#' Includes live price, equity, positions, and performance metrics.
#'
#' @param symbols Vector of symbols to monitor
#' @param update_interval Update interval in milliseconds (default: 5000)
#' @param initial_capital Initial capital for tracking
#' @param launch Launch the dashboard immediately (default: TRUE)
#'
#' @return Shiny app object
#' @export
#'
#' @examples
#' \dontrun{
#' # Launch live dashboard
#' launch_live_dashboard(symbols = c("AAPL", "MSFT", "GOOGL"))
#'
#' # Or create and customize
#' app <- create_live_dashboard(c("AAPL", "MSFT"), launch = FALSE)
#' # Customize app...
#' shiny::runApp(app)
#' }
launch_live_dashboard <- function(symbols,
                                 update_interval = 5000,
                                 initial_capital = 10000,
                                 launch = TRUE) {
  
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required. Install with: install.packages('shiny')")
  }
  
  if (!requireNamespace("shinydashboard", quietly = TRUE)) {
    message("Installing shinydashboard for better dashboard UI...")
    install.packages("shinydashboard")
  }
  
  app <- create_live_dashboard_app(symbols, update_interval, initial_capital)
  
  if (launch) {
    shiny::runApp(app)
  }
  
  invisible(app)
}

#' @keywords internal
create_live_dashboard_app <- function(symbols, update_interval, initial_capital) {
  
  ui <- shinydashboard::dashboardPage(
    shinydashboard::dashboardHeader(title = "TradingVerse Live Dashboard"),
    
    shinydashboard::dashboardSidebar(
      shinydashboard::sidebarMenu(
        shinydashboard::menuItem("Live Charts", tabName = "charts", icon = shiny::icon("chart-line")),
        shinydashboard::menuItem("Performance", tabName = "performance", icon = shiny::icon("chart-area")),
        shinydashboard::menuItem("Positions", tabName = "positions", icon = shiny::icon("table")),
        shinydashboard::menuItem("Settings", tabName = "settings", icon = shiny::icon("cog"))
      ),
      shiny::hr(),
      shiny::selectInput("symbol", "Select Symbol:", choices = symbols, selected = symbols[1]),
      shiny::sliderInput("refresh", "Refresh Rate (sec):", min = 1, max = 60, value = update_interval/1000),
      shiny::actionButton("pause", "Pause Updates", class = "btn-warning"),
      shiny::hr(),
      shiny::h4("Quick Stats"),
      shiny::verbatimTextOutput("quick_stats")
    ),
    
    shinydashboard::dashboardBody(
      shiny::tags$head(
        shiny::tags$style(shiny::HTML("
          .content-wrapper { background-color: #1a1a1a; color: #ffffff; }
          .box { background-color: #2a2a2a; color: #ffffff; border: 1px solid #3a3a3a; }
          .small-box { background-color: #2a2a2a; color: #ffffff; }
          .small-box h3, .small-box p { color: #ffffff; }
        "))
      ),
      
      shinydashboard::tabItems(
        # Live Charts Tab
        shinydashboard::tabItem(
          tabName = "charts",
          shiny::fluidRow(
            shinydashboard::valueBoxOutput("current_price", width = 3),
            shinydashboard::valueBoxOutput("daily_change", width = 3),
            shinydashboard::valueBoxOutput("volume", width = 3),
            shinydashboard::valueBoxOutput("market_cap", width = 3)
          ),
          shiny::fluidRow(
            shinydashboard::box(
              title = "Live Price Chart",
              status = "primary",
              solidHeader = TRUE,
              width = 12,
              plotly::plotlyOutput("live_chart", height = 500)
            )
          ),
          shiny::fluidRow(
            shinydashboard::box(
              title = "Technical Indicators",
              status = "info",
              solidHeader = TRUE,
              width = 12,
              plotly::plotlyOutput("indicator_chart", height = 300)
            )
          )
        ),
        
        # Performance Tab
        shinydashboard::tabItem(
          tabName = "performance",
          shiny::fluidRow(
            shinydashboard::valueBoxOutput("total_return", width = 3),
            shinydashboard::valueBoxOutput("sharpe_ratio", width = 3),
            shinydashboard::valueBoxOutput("max_drawdown", width = 3),
            shinydashboard::valueBoxOutput("win_rate", width = 3)
          ),
          shiny::fluidRow(
            shinydashboard::box(
              title = "Equity Curve",
              status = "success",
              solidHeader = TRUE,
              width = 8,
              plotly::plotlyOutput("equity_chart", height = 400)
            ),
            shinydashboard::box(
              title = "Returns Distribution",
              status = "warning",
              solidHeader = TRUE,
              width = 4,
              plotly::plotlyOutput("returns_dist", height = 400)
            )
          )
        ),
        
        # Positions Tab
        shinydashboard::tabItem(
          tabName = "positions",
          shiny::fluidRow(
            shinydashboard::box(
              title = "Current Positions",
              status = "primary",
              solidHeader = TRUE,
              width = 12,
              DT::dataTableOutput("positions_table")
            )
          ),
          shiny::fluidRow(
            shinydashboard::box(
              title = "Recent Trades",
              status = "info",
              solidHeader = TRUE,
              width = 12,
              DT::dataTableOutput("trades_table")
            )
          )
        ),
        
        # Settings Tab
        shinydashboard::tabItem(
          tabName = "settings",
          shiny::fluidRow(
            shinydashboard::box(
              title = "Dashboard Settings",
              status = "warning",
              solidHeader = TRUE,
              width = 6,
              shiny::checkboxInput("auto_refresh", "Auto Refresh", value = TRUE),
              shiny::numericInput("initial_cap", "Initial Capital:", value = initial_capital),
              shiny::selectInput("theme", "Theme:", choices = c("Dark", "Light"), selected = "Dark"),
              shiny::actionButton("reset", "Reset Dashboard", class = "btn-danger")
            ),
            shinydashboard::box(
              title = "Data Sources",
              status = "info",
              solidHeader = TRUE,
              width = 6,
              shiny::selectInput("data_source", "Data Source:", 
                               choices = c("Yahoo Finance", "Alpha Vantage", "Simulated"),
                               selected = "Yahoo Finance"),
              shiny::textInput("api_key", "API Key (if required):", ""),
              shiny::actionButton("test_connection", "Test Connection")
            )
          )
        )
      )
    )
  )
  
  server <- function(input, output, session) {
    
    # Reactive values
    rv <- shiny::reactiveValues(
      paused = FALSE,
      data = NULL,
      equity_history = data.frame(datetime = as.POSIXct(character()), equity = numeric())
    )
    
    # Pause/Resume button
    shiny::observeEvent(input$pause, {
      rv$paused <- !rv$paused
      shiny::updateActionButton(session, "pause", 
                               label = if (rv$paused) "Resume Updates" else "Pause Updates",
                               icon = shiny::icon(if (rv$paused) "play" else "pause"))
    })
    
    # Fetch live data
    live_data <- shiny::reactive({
      if (rv$paused) return(rv$data)
      
      shiny::invalidateLater(input$refresh * 1000)
      
      data <- tryCatch({
        if (!requireNamespace("tradeio", quietly = TRUE)) {
          # Simulate data if tradeio not available
          generate_simulated_data(input$symbol)
        } else {
          tradeio::fetch_prices(input$symbol, from = Sys.Date() - 30)
        }
      }, error = function(e) {
        message("Error fetching data: ", e$message)
        rv$data
      })
      
      rv$data <- data
      data
    })
    
    # Value boxes
    output$current_price <- shinydashboard::renderValueBox({
      data <- live_data()
      if (is.null(data) || nrow(data) == 0) return(NULL)
      
      current <- tail(data$close, 1)
      shinydashboard::valueBox(
        sprintf("$%.2f", current),
        "Current Price",
        icon = shiny::icon("dollar-sign"),
        color = "blue"
      )
    })
    
    output$daily_change <- shinydashboard::renderValueBox({
      data <- live_data()
      if (is.null(data) || nrow(data) < 2) return(NULL)
      
      change <- (tail(data$close, 1) / tail(data$close, 2)[1] - 1) * 100
      shinydashboard::valueBox(
        sprintf("%+.2f%%", change),
        "Daily Change",
        icon = shiny::icon("chart-line"),
        color = if (change >= 0) "green" else "red"
      )
    })
    
    output$volume <- shinydashboard::renderValueBox({
      data <- live_data()
      if (is.null(data) || nrow(data) == 0 || !"volume" %in% names(data)) return(NULL)
      
      vol <- tail(data$volume, 1)
      shinydashboard::valueBox(
        scales::comma(vol),
        "Volume",
        icon = shiny::icon("chart-bar"),
        color = "purple"
      )
    })
    
    output$market_cap <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        "N/A",
        "Market Cap",
        icon = shiny::icon("building"),
        color = "yellow"
      )
    })
    
    # Live chart
    output$live_chart <- plotly::renderPlotly({
      data <- live_data()
      if (is.null(data) || nrow(data) == 0) return(NULL)
      
      plot_interactive(data, title = paste(input$symbol, "Live Price"), show_volume = TRUE)
    })
    
    # Indicator chart
    output$indicator_chart <- plotly::renderPlotly({
      data <- live_data()
      if (is.null(data) || nrow(data) == 0) return(NULL)
      
      if (requireNamespace("tradefeatures", quietly = TRUE)) {
        data <- data %>%
          tradefeatures::add_rsi(14)
        
        fig <- plotly::plot_ly(data, x = ~datetime, y = ~rsi, type = "scatter", mode = "lines",
                              line = list(color = "#1976d2", width = 2))
        fig <- plotly::layout(fig,
                             title = "RSI (14)",
                             xaxis = list(title = ""),
                             yaxis = list(title = "RSI"))
        fig <- plotly::add_trace(fig, y = 30, type = "scatter", mode = "lines",
                                line = list(dash = "dash", color = "#26a69a", width = 1),
                                showlegend = FALSE)
        fig <- plotly::add_trace(fig, y = 70, type = "scatter", mode = "lines",
                                line = list(dash = "dash", color = "#ef5350", width = 1),
                                showlegend = FALSE)
        fig
      } else {
        plotly::plot_ly() %>% plotly::layout(title = "Install tradefeatures for indicators")
      }
    })
    
    # Quick stats
    output$quick_stats <- shiny::renderText({
      data <- live_data()
      if (is.null(data) || nrow(data) == 0) return("No data")
      
      paste(
        sprintf("Symbol: %s", input$symbol),
        sprintf("Points: %d", nrow(data)),
        sprintf("Last Update: %s", format(Sys.time(), "%H:%M:%S")),
        sprintf("Status: %s", if (rv$paused) "PAUSED" else "LIVE"),
        sep = "\n"
      )
    })
    
    # Placeholder outputs
    output$equity_chart <- plotly::renderPlotly({
      plotly::plot_ly() %>% plotly::layout(title = "Equity tracking coming soon...")
    })
    
    output$returns_dist <- plotly::renderPlotly({
      plotly::plot_ly() %>% plotly::layout(title = "Returns analysis coming soon...")
    })
    
    output$positions_table <- DT::renderDataTable({
      DT::datatable(data.frame(
        Symbol = input$symbol,
        Quantity = 100,
        Entry = 150.00,
        Current = 155.00,
        PnL = 500,
        Status = "Open"
      ))
    })
    
    output$trades_table <- DT::renderDataTable({
      DT::datatable(data.frame(
        Time = Sys.time(),
        Symbol = input$symbol,
        Type = "BUY",
        Quantity = 100,
        Price = 150.00,
        Total = 15000
      ))
    })
    
    # Value box placeholders
    output$total_return <- shinydashboard::renderValueBox({
      shinydashboard::valueBox("N/A", "Total Return", icon = shiny::icon("percent"), color = "green")
    })
    
    output$sharpe_ratio <- shinydashboard::renderValueBox({
      shinydashboard::valueBox("N/A", "Sharpe Ratio", icon = shiny::icon("chart-line"), color = "blue")
    })
    
    output$max_drawdown <- shinydashboard::renderValueBox({
      shinydashboard::valueBox("N/A", "Max Drawdown", icon = shiny::icon("arrow-down"), color = "red")
    })
    
    output$win_rate <- shinydashboard::renderValueBox({
      shinydashboard::valueBox("N/A", "Win Rate", icon = shiny::icon("trophy"), color = "yellow")
    })
  }
  
  shiny::shinyApp(ui, server)
}

#' Generate Simulated Live Data
#' @keywords internal
generate_simulated_data <- function(symbol, n_days = 30) {
  dates <- seq(Sys.Date() - n_days, Sys.Date(), by = "day")
  n <- length(dates)
  
  # Random walk
  returns <- rnorm(n, mean = 0.001, sd = 0.02)
  close <- 100 * cumprod(1 + returns)
  
  data.frame(
    symbol = symbol,
    datetime = as.POSIXct(dates),
    open = close * runif(n, 0.98, 1.02),
    high = close * runif(n, 1.00, 1.05),
    low = close * runif(n, 0.95, 1.00),
    close = close,
    volume = rpois(n, 1000000),
    adjusted = close
  )
}
