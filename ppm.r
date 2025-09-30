# Install and load necessary libraries if you have not done so
install.packages("ggplot2")
install.packages("dplyr")
install.packages("reshape2")

library(ggplot2)
library(dplyr)
library(reshape2)

# Define the project data
projects <- c("Solar Power Plant", "E-Commerce Platform", "Smart City Development",
              "Data Center Expansion", "Electric Vehicle Factory")
mean_cost <- c(500, 200, 350, 450, 600)     # Mean cost in IDR Billion
sd_cost <- c(50, 30, 40, 55, 70)            # Cost standard deviation in IDR Billion
mean_return <- c(900, 400, 750, 850, 1200)  # Mean return in IDR Billion
sd_return <- c(100, 60, 80, 90, 150)        # Return standard deviation in IDR Billion

# Number of Monte Carlo simulations
n_simulations <- 1000

# Monte Carlo Simulation: Randomly generate costs and returns for each project
set.seed(123)  # For reproducibility

simulation_results <- data.frame(matrix(nrow = n_simulations, ncol = 2))

for (i in 1:n_simulations) {
  
  # Generate random costs and returns using normal distribution
  random_costs <- rnorm(length(projects), mean_cost, sd_cost)
  random_returns <- rnorm(length(projects), mean_return, sd_return)
  
  # Total cost and total return for the portfolio
  total_cost <- sum(random_costs)
  total_return <- sum(random_returns)
  
  # Store the simulation results
  simulation_results[i, ] <- c(total_cost, total_return)
}

colnames(simulation_results) <- c("Total_Cost", "Total_Return")

# Summary of simulation results
summary(simulation_results)

# Histogram of Total Cost
ggplot(simulation_results, aes(x = Total_Cost)) +
  geom_histogram(binwidth = 10, fill = "blue", alpha = 0.7) +
  labs(title = "Distribution of Total Portfolio Cost", 
       x = "Total Cost (IDR Billion)", 
       y = "Frequency") +
  theme_minimal()

# Histogram of Total Return
ggplot(simulation_results, aes(x = Total_Return)) +
  geom_histogram(binwidth = 10, fill = "green", alpha = 0.7) +
  labs(title = "Distribution of Total Portfolio Return", 
       x = "Total Return (IDR Billion)", 
       y = "Frequency") +
  theme_minimal()

# Scatter plot of Total Cost vs Total Return to visualize trade-offs
ggplot(simulation_results, aes(x = Total_Cost, y = Total_Return)) +
  geom_point(alpha = 0.5, color = "purple") +
  labs(title = "Total Cost vs Total Return (Monte Carlo Simulation)", 
       x = "Total Cost (IDR Billion)", 
       y = "Total Return (IDR Billion)") +
  theme_minimal()
