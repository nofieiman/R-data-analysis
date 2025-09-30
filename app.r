# Load required libraries for Shiny dashboard
install.packages(c("shiny", "shinydashboard", "DT", "plotly"))
library(shiny)
library(shinydashboard)
library(tidyverse)
library(ggplot2)
library(plotly)
library(DT)

# Load the processed data
sales_data <- read.csv("processed_sales_data.csv")
sales_data$Date <- as.Date(sales_data$Date)

# Define UI for the dashboard
ui <- dashboardPage(
  dashboardHeader(title = "Sales Analytics Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Category Analysis", tabName = "category", icon = icon("chart-bar")),
      menuItem("Price & Rating Analysis", tabName = "price_rating", icon = icon("chart-line")),
      menuItem("Time Series Analysis", tabName = "timeseries", icon = icon("calendar")),
      menuItem("Raw Data", tabName = "rawdata", icon = icon("table")),
      
      # Filters
      br(),
      h4("Data Filters", style = "padding-left: 15px;"),
      
      selectInput("category_filter", "Category:",
                  choices = c("All", unique(sales_data$Category)),
                  selected = "All"),
      
      selectInput("region_filter", "Region:",
                  choices = c("All", unique(sales_data$Region)),
                  selected = "All"),
      
      selectInput("price_category_filter", "Price Category:",
                  choices = c("All", unique(sales_data$Price_Category)),
                  selected = "All"),
      
      dateRangeInput("date_filter", "Date Range:",
                     start = min(sales_data$Date),
                     end = max(sales_data$Date),
                     min = min(sales_data$Date),
                     max = max(sales_data$Date))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .box { margin-bottom: 10px; }
        .info-box-content { text-align: center; }
        .main-header .logo { font-weight: bold; }
      "))
    ),
    
    tabItems(
      # Overview Tab
      tabItem(tabName = "overview",
        fluidRow(
          # Value boxes
          valueBoxOutput("total_revenue_box", width = 3),
          valueBoxOutput("total_units_box", width = 3),
          valueBoxOutput("avg_rating_box", width = 3),
          valueBoxOutput("total_products_box", width = 3)
        ),
        
        fluidRow(
          box(
            title = "Revenue Distribution by Category",
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("revenue_pie_chart"),
            width = 6
          ),
          
          box(
            title = "Top Performing Products",
            status = "info",
            solidHeader = TRUE,
            DT::dataTableOutput("top_products_table"),
            width = 6
          )
        ),
        
        fluidRow(
          box(
            title = "Regional Performance",
            status = "warning",
            solidHeader = TRUE,
            plotlyOutput("regional_barchart"),
            width = 12
          )
        )
      ),
      
      # Category Analysis Tab
      tabItem(tabName = "category",
        fluidRow(
          box(
            title = "Revenue by Category",
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("category_revenue_chart"),
            width = 6
          ),
          
          box(
            title = "Units Sold by Category",
            status = "success",
            solidHeader = TRUE,
            plotlyOutput("category_units_chart"),
            width = 6
          )
        ),
        
        fluidRow(
          box(
            title = "Price Distribution by Category",
            status = "info",
            solidHeader = TRUE,
            plotlyOutput("category_price_boxplot"),
            width = 12
          )
        ),
        
        fluidRow(
          box(
            title = "Category Summary Statistics",
            status = "warning",
            solidHeader = TRUE,
            DT::dataTableOutput("category_summary_table"),
            width = 12
          )
        )
      ),
      
      # Price & Rating Analysis Tab
      tabItem(tabName = "price_rating",
        fluidRow(
          box(
            title = "Price vs Rating Relationship",
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("price_rating_scatter"),
            width = 8
          ),
          
          box(
            title = "Correlation Statistics",
            status = "info",
            solidHeader = TRUE,
            verbatimTextOutput("correlation_stats"),
            width = 4
          )
        ),
        
        fluidRow(
          box(
            title = "Rating Distribution",
            status = "success",
            solidHeader = TRUE,
            plotlyOutput("rating_histogram"),
            width = 6
          ),
          
          box(
            title = "Price Category Analysis",
            status = "warning",
            solidHeader = TRUE,
            plotlyOutput("price_category_chart"),
            width = 6
          )
        )
      ),
      
      # Time Series Analysis Tab
      tabItem(tabName = "timeseries",
        fluidRow(
          box(
            title = "Revenue Over Time",
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("revenue_timeseries"),
            width = 12
          )
        ),
        
        fluidRow(
          box(
            title = "Daily Units Sold",
            status = "success",
            solidHeader = TRUE,
            plotlyOutput("units_timeseries"),
            width = 6
          ),
          
          box(
            title = "Time Series Controls",
            status = "info",
            solidHeader = TRUE,
            selectInput("timeseries_aggregation", "Aggregation Level:",
                        choices = c("Daily", "Weekly", "Monthly"),
                        selected = "Daily"),
            sliderInput("smoothing_span", "Smoothing Span:",
                        min = 0.1, max = 1, value = 0.5, step = 0.1),
            width = 6
          )
        )
      ),
      
      # Raw Data Tab
      tabItem(tabName = "rawdata",
        fluidRow(
          box(
            title = "Sales Data",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("raw_data_table")
          )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive data filtering
  filtered_data <- reactive({
    data <- sales_data
    
    # Apply filters
    if (input$category_filter != "All") {
      data <- data %>% filter(Category == input$category_filter)
    }
    
    if (input$region_filter != "All") {
      data <- data %>% filter(Region == input$region_filter)
    }
    
    if (input$price_category_filter != "All") {
      data <- data %>% filter(Price_Category == input$price_category_filter)
    }
    
    data <- data %>% 
      filter(Date >= input$date_filter[1] & Date <= input$date_filter[2])
    
    return(data)
  })
  
  # Value boxes
  output$total_revenue_box <- renderValueBox({
    data <- filtered_data()
    total_rev <- sum(data$Revenue)
    
    valueBox(
      paste0("$", format(round(total_rev), big.mark = ",")),
      "Total Revenue",
      icon = icon("dollar-sign"),
      color = "green"
    )
  })
  
  output$total_units_box <- renderValueBox({
    data <- filtered_data()
    total_units <- sum(data$Units_Sold)
    
    valueBox(
      format(total_units, big.mark = ","),
      "Total Units Sold",
      icon = icon("shopping-cart"),
      color = "blue"
    )
  })
  
  output$avg_rating_box <- renderValueBox({
    data <- filtered_data()
    avg_rating <- mean(data$Rating, na.rm = TRUE)
    
    valueBox(
      round(avg_rating, 2),
      "Average Rating",
      icon = icon("star"),
      color = "yellow"
    )
  })
  
  output$total_products_box <- renderValueBox({
    data <- filtered_data()
    total_products <- n_distinct(data$ProductID)
    
    valueBox(
      total_products,
      "Total Products",
      icon = icon("cubes"),
      color = "purple"
    )
  })
  
  # Overview tab charts
  output$revenue_pie_chart <- renderPlotly({
    data <- filtered_data()
    
    category_revenue <- data %>%
      group_by(Category) %>%
      summarise(Revenue = sum(Revenue)) %>%
      arrange(desc(Revenue))
    
    plot_ly(category_revenue, labels = ~Category, values = ~Revenue, type = 'pie',
            textinfo = 'label+percent',
            insidetextorientation = 'radial') %>%
      layout(title = 'Revenue Distribution by Category')
  })
  
  output$top_products_table <- DT::renderDataTable({
    data <- filtered_data()
    
    top_products <- data %>%
      group_by(Product, Category) %>%
      summarise(
        Revenue = sum(Revenue),
        Units_Sold = sum(Units_Sold),
        Avg_Rating = mean(Rating)
      ) %>%
      arrange(desc(Revenue)) %>%
      head(10)
    
    DT::datatable(top_products, options = list(pageLength = 5))
  })
  
  output$regional_barchart <- renderPlotly({
    data <- filtered_data()
    
    regional_summary <- data %>%
      group_by(Region) %>%
      summarise(
        Revenue = sum(Revenue),
        Units_Sold = sum(Units_Sold)
      )
    
    plot_ly(regional_summary, x = ~Region, y = ~Revenue, type = 'bar',
            name = 'Revenue', marker = list(color = 'rgb(55, 83, 109)')) %>%
      add_trace(y = ~Units_Sold, name = 'Units Sold', 
                marker = list(color = 'rgb(26, 118, 255)')) %>%
      layout(title = 'Regional Performance',
             xaxis = list(title = 'Region'),
             yaxis = list(title = 'Value'),
             barmode = 'group')
  })
  
  # Category Analysis tab
  output$category_revenue_chart <- renderPlotly({
    data <- filtered_data()
    
    category_summary <- data %>%
      group_by(Category) %>%
      summarise(Revenue = sum(Revenue))
    
    plot_ly(category_summary, x = ~Category, y = ~Revenue, type = 'bar',
            marker = list(color = 'steelblue')) %>%
      layout(title = 'Total Revenue by Category',
             xaxis = list(title = 'Category'),
             yaxis = list(title = 'Revenue'))
  })
  
  output$category_units_chart <- renderPlotly({
    data <- filtered_data()
    
    category_summary <- data %>%
      group_by(Category) %>%
      summarise(Units_Sold = sum(Units_Sold))
    
    plot_ly(category_summary, x = ~Category, y = ~Units_Sold, type = 'bar',
            marker = list(color = 'lightgreen')) %>%
      layout(title = 'Total Units Sold by Category',
             xaxis = list(title = 'Category'),
             yaxis = list(title = 'Units Sold'))
  })
  
  output$category_price_boxplot <- renderPlotly({
    data <- filtered_data()
    
    plot_ly(data, x = ~Category, y = ~Price, color = ~Category, type = "box") %>%
      layout(title = 'Price Distribution by Category',
             xaxis = list(title = 'Category'),
             yaxis = list(title = 'Price'))
  })
  
  output$category_summary_table <- DT::renderDataTable({
    data <- filtered_data()
    
    summary_table <- data %>%
      group_by(Category) %>%
      summarise(
        Avg_Price = round(mean(Price), 2),
        Total_Revenue = sum(Revenue),
        Avg_Rating = round(mean(Rating), 2),
        Total_Units = sum(Units_Sold),
        Number_of_Products = n_distinct(ProductID)
      ) %>%
      arrange(desc(Total_Revenue))
    
    DT::datatable(summary_table, options = list(pageLength = 10))
  })
  
  # Price & Rating Analysis tab
  output$price_rating_scatter <- renderPlotly({
    data <- filtered_data()
    
    plot_ly(data, x = ~Price, y = ~Rating, color = ~Category,
            type = 'scatter', mode = 'markers',
            text = ~paste("Product:", Product, "<br>Revenue: $", Revenue),
            marker = list(size = 10, opacity = 0.7)) %>%
      layout(title = 'Price vs Rating Relationship',
             xaxis = list(title = 'Price'),
             yaxis = list(title = 'Rating'))
  })
  
  output$correlation_stats <- renderPrint({
    data <- filtered_data()
    
    correlation <- cor(data$Price, data$Rating, use = "complete.obs")
    cat("Correlation between Price and Rating:\n")
    cat(round(correlation, 3), "\n\n")
    
    cat("ANOVA Results (Price by Category):\n")
    anova_result <- aov(Price ~ Category, data = data)
    print(summary(anova_result))
  })
  
  output$rating_histogram <- renderPlotly({
    data <- filtered_data()
    
    plot_ly(data, x = ~Rating, type = "histogram",
            marker = list(color = 'lightblue')) %>%
      layout(title = 'Rating Distribution',
             xaxis = list(title = 'Rating'),
             yaxis = list(title = 'Frequency'))
  })
  
  output$price_category_chart <- renderPlotly({
    data <- filtered_data()
    
    price_cat_summary <- data %>%
      group_by(Price_Category) %>%
      summarise(
        Count = n(),
        Avg_Rating = mean(Rating)
      )
    
    plot_ly(price_cat_summary, x = ~Price_Category, y = ~Count, type = 'bar',
            name = 'Product Count', marker = list(color = 'orange')) %>%
      add_trace(y = ~Avg_Rating * max(Count)/5, name = 'Avg Rating', 
                type = 'scatter', mode = 'lines+markers',
                yaxis = 'y2', line = list(color = 'red')) %>%
      layout(title = 'Price Category Analysis',
             xaxis = list(title = 'Price Category'),
             yaxis = list(title = 'Product Count'),
             yaxis2 = list(title = 'Average Rating', 
                          overlaying = "y", 
                          side = "right",
                          range = c(0, 5)))
  })
  
  # Time Series Analysis tab
  output$revenue_timeseries <- renderPlotly({
    data <- filtered_data()
    
    time_series <- data %>%
      group_by(Date) %>%
      summarise(Daily_Revenue = sum(Revenue))
    
    plot_ly(time_series, x = ~Date, y = ~Daily_Revenue, type = 'scatter', mode = 'lines',
            line = list(color = 'steelblue', width = 2)) %>%
      layout(title = 'Daily Revenue Over Time',
             xaxis = list(title = 'Date'),
             yaxis = list(title = 'Revenue'))
  })
  
  output$units_timeseries <- renderPlotly({
    data <- filtered_data()
    
    time_series <- data %>%
      group_by(Date) %>%
      summarise(Daily_Units = sum(Units_Sold))
    
    plot_ly(time_series, x = ~Date, y = ~Daily_Units, type = 'scatter', mode = 'lines',
            line = list(color = 'green', width = 2)) %>%
      layout(title = 'Daily Units Sold Over Time',
             xaxis = list(title = 'Date'),
             yaxis = list(title = 'Units Sold'))
  })
  
  # Raw Data tab
  output$raw_data_table <- DT::renderDataTable({
    data <- filtered_data()
    
    DT::datatable(data, 
                  options = list(
                    pageLength = 10,
                    scrollX = TRUE,
                    autoWidth = TRUE
                  ),
                  filter = 'top')
  })
}

# Run the application
shinyApp(ui = ui, server = server)
