# Purpose: Train a model to predict article popularity (shares).
# Strategy:
#   1) Load training data
#   2) Predict log(shares) instead of shares (shares is very skewed)
#   3) Use 10-fold cross-validation to tune a regularized regression (glmnet)
#   4) Fit the final model on ALL training data
#   5) Save the trained model to models/final_model.rds

# --- Libraries ---
library(tidyverse)
library(tidymodels)

# Make results reproducible (same CV folds each run)
set.seed(42)

# --- Load Training Data ---
# Read the training data from data/raw/train.csv into a dataframe
df <- read_csv("data/raw/train.csv")

# --- Create Log Transformation ---
# Create a new column log_shares by taking the natural log of shares
# This helps with skewed distributions (shares can be very large)
df <- df %>%
  mutate(log_shares = log(shares))

# --- Print Basic Information ---
# Print the number of rows (observations) in the dataset
cat("Number of rows:", nrow(df), "\n")

# Print the number of columns (variables) in the dataset
cat("Number of columns:", ncol(df), "\n")

# Print a summary of the shares variable (min, max, mean, median, quartiles)
# This gives us a quick overview without printing the entire dataset
cat("\nSummary of shares:\n")
summary(df$shares)

# --- Create Cross-Validation Splits ---
# Create 10-fold cross-validation splits using tidymodels
# This randomly divides the data into 10 equal-sized groups (folds)
# Each fold will serve as a validation set once, while the other 9 folds are used for training
# Cross-validation helps us tune model parameters and estimate performance without needing a separate test set
# The set.seed(42) above ensures we get the same splits each time we run the code
folds <- vfold_cv(df, v = 10)

# --- Create Recipe for Data Preprocessing ---
# A recipe defines how to prepare the data before modeling
# We specify that log_shares is our outcome (what we want to predict)
# and all other variables (except shares) will be predictors
recipe <- recipe(log_shares ~ ., data = df) %>%
  # Step 1: Remove the shares column
  # We don't want shares as a predictor since we're predicting log_shares
  # (shares and log_shares are the same information, just transformed)
  step_rm(shares) %>%
  # Step 1.5: Remove the url column
  # The url column is non-numeric (text) and cannot be used as a predictor
  # glmnet requires all predictors to be numeric
  step_rm(url) %>%
  # Step 2: Remove zero-variance predictors
  # These are columns where every row has the same value (no variation)
  # They can't help predict the outcome and can cause problems in some models
  step_zv(all_predictors()) %>%
  # Step 3: Normalize numeric predictors
  # This centers (subtracts mean) and scales (divides by standard deviation) all numeric variables
  # Normalization helps models that are sensitive to the scale of variables (like regularized regression)
  # It ensures all predictors are on a similar scale, which improves model performance
  step_normalize(all_numeric_predictors())

# --- Define Model ---
# Create a regularized linear regression model using glmnet
# Regularized regression adds a penalty to prevent overfitting and can perform variable selection
model <- linear_reg(penalty = tune(), mixture = tune()) %>%
  set_engine("glmnet")

# Understanding the parameters:
# - penalty: Controls the strength of regularization (how much we penalize large coefficients)
#   * Higher penalty = simpler model (smaller coefficients, fewer variables)
#   * Lower penalty = more complex model (larger coefficients, more variables)
#   * We'll tune this to find the best value using cross-validation
#
# - mixture: Controls the type of regularization (the balance between Lasso and Ridge)
#   * mixture = 0: Pure Ridge regression (L2 penalty) - shrinks coefficients but keeps all variables
#   * mixture = 1: Pure Lasso regression (L1 penalty) - can set coefficients to exactly zero (variable selection)
#   * mixture between 0 and 1: Elastic Net - combines both Lasso and Ridge benefits
#   * We'll tune this to find the best balance for our data

# --- Create Workflow ---
# A workflow combines the recipe (data preprocessing) with the model
# This makes it easy to apply the same preprocessing and modeling steps together
workflow <- workflow() %>%
  add_recipe(recipe) %>%
  add_model(model)

# --- Tune Model Parameters ---
# Tuning means trying different values of model parameters (penalty and mixture) 
# to find the combination that gives the best performance
# We use cross-validation (CV) to evaluate each parameter combination because:
# 1) It gives us an honest estimate of how well the model will perform on new data
# 2) We can test many parameter combinations without needing a separate test set
# 3) Each fold acts as a mini test set, so we get 10 performance estimates per combination

# Create a grid of parameter values to try
# penalty: values on log10 scale from 1e-6 (0.000001) to 1e1 (10)
#   We specify the range as c(-6, 1), which tidymodels interprets as log10 scale internally
#   This creates values evenly spaced on log10 scale: 10^-6, 10^-5, ..., 10^0, 10^1
# mixture: values from 0 (pure Ridge) to 1 (pure Lasso)
tune_grid <- grid_regular(
  penalty(range = c(-6, 1)),  # log10 scale: -6 means 10^-6, 1 means 10^1
  mixture(range = c(0, 1)),
  levels = 10  # Try 10 values for each parameter (100 combinations total)
)

# Tune the workflow using 10-fold cross-validation
# This will fit the model 100 times (once for each parameter combination)
# and evaluate each one using all 10 CV folds
tune_results <- workflow %>%
  tune_grid(
    resamples = folds,           # Use our 10-fold CV splits
    grid = tune_grid,            # Try all parameter combinations in the grid
    metrics = metric_set(rmse)   # Use RMSE (Root Mean Squared Error) to evaluate performance
  )

# Select the best parameter combination based on RMSE
# This finds the penalty and mixture values that gave the lowest average RMSE across all CV folds
best_params <- select_best(tune_results, metric = "rmse")

# --- Finalize and Fit Final Model ---
# Now that we've found the best parameters, we finalize the workflow
# This updates the workflow to use the best penalty and mixture values (no longer tuning)
final_workflow <- workflow %>%
  finalize_workflow(best_params)

# Fit the final model on the ENTIRE training dataset
# We use all the data (not just a subset) because:
# 1) We've already validated our model choice using cross-validation
# 2) More training data generally leads to better model performance
# 3) This is the model we'll use for making predictions on new data
final_model <- final_workflow %>%
  fit(data = df)

# --- Save the Final Model ---
# Create the models/ directory if it doesn't exist
# dir.create() won't error if the directory already exists (showWarnings = FALSE)
if (!dir.exists("models")) {
  dir.create("models", recursive = TRUE)
}

# Save the fitted model to a file using saveRDS()
# This allows us to load the model later (in Evaluate.r) without retraining
# RDS format is R's native format for saving R objects
saveRDS(final_model, file = "models/final_model.rds")

cat("\nModel training complete! Final model saved to models/final_model.rds\n")