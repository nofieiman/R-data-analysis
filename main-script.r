# Create dummy data
set.seed(123)  # For reproducibility

dummy_data <- data.frame(
  ProductID = 1:100,
  Product = paste0("Product_", sample(LETTERS[1:5], 100, replace = TRUE)),
  Category = sample(c("Electronics", "Clothing", "Home", "Books"), 100, replace = TRUE),
  Price = round(runif(100, 10, 500), 2),
  Units_Sold = sample(50:500, 100, replace = TRUE),
  Region = sample(c("North", "South", "East", "West"), 100, replace = TRUE),
  Rating = round(runif(100, 1, 5), 1),
  Date = seq.Date(as.Date("2023-01-01"), by = "day", length.out = 100)
)

# Calculate Revenue
dummy_data$Revenue <- dummy_data$Price * dummy_data$Units_Sold

# Add some missing values
dummy_data$Rating[sample(1:100, 10)] <- NA

# View the first few rows
head(dummy_data)

# Save as CSV
write.csv(dummy_data, "dummy_sales_data.csv", row.names = FALSE)

# Load necessary libraries
install.packages("tidyverse")
install.packages("ggplot2")
library(tidyverse)
library(ggplot2)

# 1. Load the data
sales_data <- read.csv("dummy_sales_data.csv")

# 2. Explore the data
head(sales_data)
str(sales_data)
summary(sales_data)

# 3. Data cleaning
# Check for missing values
sum(is.na(sales_data))
colSums(is.na(sales_data))

# Handle missing values (replace with mean)
sales_data$Rating[is.na(sales_data$Rating)] <- mean(sales_data$Rating, na.rm = TRUE)

# 4. Data transformation
# Create a new categorical variable based on price
sales_data <- sales_data %>%
  mutate(Price_Category = case_when(
    Price < 100 ~ "Low",
    Price >= 100 & Price < 300 ~ "Medium",
    Price >= 300 ~ "High"
  ))

# 5. Summary statistics by category
category_summary <- sales_data %>%
  group_by(Category) %>%
  summarise(
    Avg_Price = mean(Price),
    Total_Revenue = sum(Revenue),
    Avg_Rating = mean(Rating),
    Total_Units = sum(Units_Sold)
  )
print(category_summary)

# 6. Data visualization
# Revenue by category
ggplot(category_summary, aes(x = Category, y = Total_Revenue, fill = Category)) +
  geom_bar(stat = "identity") +
  labs(title = "Total Revenue by Product Category", 
       y = "Total Revenue", 
       x = "Category") +
  theme_minimal()

# Price distribution by category
ggplot(sales_data, aes(x = Category, y = Price, fill = Category)) +
  geom_boxplot() +
  labs(title = "Price Distribution by Category") +
  theme_minimal()

# Relationship between price and rating
ggplot(sales_data, aes(x = Price, y = Rating, color = Category)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Relationship Between Price and Rating") +
  theme_minimal()

# 7. Statistical analysis
# Correlation between price and rating
correlation <- cor(sales_data$Price, sales_data$Rating)
print(paste("Correlation between Price and Rating:", round(correlation, 3)))

# ANOVA to check if average price differs by category
price_anova <- aov(Price ~ Category, data = sales_data)
summary(price_anova)

# 8. Time series analysis (revenue over time)
sales_data$Date <- as.Date(sales_data$Date)
time_series <- sales_data %>%
  group_by(Date) %>%
  summarise(Daily_Revenue = sum(Revenue))

ggplot(time_series, aes(x = Date, y = Daily_Revenue)) +
  geom_line(color = "steelblue") +
  labs(title = "Daily Revenue Over Time", 
       y = "Revenue", 
       x = "Date") +
  theme_minimal()

# 9. Save processed data
write.csv(sales_data, "processed_sales_data.csv", row.names = FALSE)

# 10. Save visualizations
ggsave("revenue_by_category.png", width = 8, height = 6)
ggsave("price_rating_relationship.png", width = 8, height = 6)
