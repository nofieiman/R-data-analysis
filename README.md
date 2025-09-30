Sales Analytics Dashboard

A comprehensive R Shiny dashboard for analyzing and visualizing sales data with interactive features and business intelligence capabilities.

📊 Overview

This project provides a complete sales analytics solution built with R and Shiny. It includes data generation, processing, statistical analysis, and an interactive dashboard for visualizing key business metrics.

✨ Features

📈 Analytics & Visualization

-    Dashboard Overview: Key metrics and performance indicators
-    Category Analysis: Product category performance breakdown
-    Price & Rating Analysis: Correlation and distribution analysis
-    Time Series Analysis: Revenue trends over time
-    Regional Analysis: Geographic performance metrics

🎯 Interactive Elements

-    Real-time data filtering by category, region, and date
-    Interactive Plotly charts and graphs
-    Responsive design that works on different screen sizes
-    Dynamic value boxes and summary statistics
-    Export capabilities for processed data

📊 Data Processing

-    Automated dummy data generation with realistic business patterns
-    Data cleaning and transformation pipelines
-    Statistical analysis (correlation, ANOVA, summary statistics)
-    Missing value handling and data validation

🚀 Quick Start

Prerequisites

-    R (version 4.0 or higher)
-    RStudio (recommended)

Installation

-    Clone the repository

`git clone https://github.com/yourusername/sales-analytics-dashboard.git
cd sales-analytics-dashboard`

-    Install required R packages


# Run in R console:
`install.packages(c("tidyverse", "shiny", "shinydashboard", "ggplot2", "plotly", "DT"))`

Run the application

# Method 1: Run the main analysis and dashboard
`source("sales_dashboard.R")`

# Method 2: Run only the Shiny dashboard
`shiny::runApp("app.R")`

🛠️ Code Components

Data Generation & Analysis (sales_analysis.R)

-    Creates realistic dummy sales data with 100 product records
-    Performs data cleaning and transformation
-    Generates summary statistics and visualizations
-    Conducts statistical analysis (correlation, ANOVA)

Shiny Dashboard (app.R)

-    Interactive web application with multiple tabs
-    Real-time data filtering and visualization
-    Responsive UI with value boxes and interactive charts
-    Data export capabilities

📊 Dashboard Tabs

1. Dashboard Overview

-    Key metrics: Total Revenue, Units Sold, Average Rating, Product Count
-    Revenue distribution by category (pie chart)
-    Top performing products table
-    Regional performance comparison

2. Category Analysis

-    Revenue and units sold by category
-    Price distribution box plots
-    Detailed category summary statistics

3. Price & Rating Analysis

-    Price vs Rating scatter plot with correlation
-    Rating distribution histogram
-    Price category analysis with dual-axis charts

4. Time Series Analysis

-    Daily revenue trends over time
-    Units sold time series
-    Adjustable aggregation levels

5. Raw Data

-    Interactive data table with search and filter
-    Export functionality
-    Complete dataset view

🔧 Customization

Adding New Data

Replace the dummy data generation with your actual data:

# Replace this section in sales_analysis.R
`your_real_data <- read.csv("your_sales_data.csv")`

Modifying Visualizations

Edit the ggplot2 and Plotly code in the server function:

`output$your_custom_chart <- renderPlotly({
  Your custom visualization code here
})`

Adding New Filters

Extend the sidebar UI with additional filters:

`selectInput("new_filter", "New Filter:",
            choices = c("Option1", "Option2"),
            selected = "Option1")`

📈 Sample Insights

The dashboard helps answer key business questions:

-    Which product categories generate the most revenue?
-    How does price correlate with customer ratings?
-    What are the sales trends over time?
-    How do different regions perform?
-    Which price categories are most popular?
