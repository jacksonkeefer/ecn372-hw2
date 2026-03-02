# Purpose: Load the trained model and evaluate it on the test set.
# IMPORTANT: This script must print ONLY the test MSE.

library(tidyverse)
library(tidymodels)

# --- Load trained model ---
model <- readRDS("models/final_model.rds")

# --- Load test data ---
test <- read_csv("data/raw/test.csv", show_col_types = FALSE)

# --- Make predictions ---
# Our model was trained to predict log(shares), so predictions are on log scale
pred_log <- predict(model, new_data = test) %>%
  pull(.pred)

# Convert predictions back to original shares scale
pred_shares <- exp(pred_log)

# --- Compute test MSE on original shares ---
# True values are in test$shares
mse <- mean((test$shares - pred_shares)^2)

# --- Print ONLY the MSE ---
cat(sprintf("MSE: %.6f\n", mse))
