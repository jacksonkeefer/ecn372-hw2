# ECN 372 – Homework 2

**Prediction assignment.** 
Build a model to predict article popularity (`shares`) on a held-out test set. 
You will submit a GitHub repo; I will run **`make evaluate`** to print your model’s test MSE. 
Your model must outperform a hidden baseline model of mine to get full credit for the prediction component.

---

## The assignment

You have training data (`train.csv`) to fit a predictive model for the target variable **`shares`**. 
At grading time I will add test data to your repo and run **`make evaluate`**;
that command must compute predictions on the test set and **print only the test MSE** (mean squared error). 
How you get there (variable selection, cross-validation, choice of model) is up to you, but it must be thoughtful and documented/explained.

---

## Data

- **Training data:** `train.csv` is included in this repo. Use it to train and validate your model.
- **Test data:** When grading, I will place `test.csv` in the directory **`data/raw/`** at the root of your project. It has the same columns/structure as `train.csv`; the target is again **`shares`**.
- **Variable descriptions:** See `OnlineNewsPopularity.names` for details on the features and the target.

Your Makefile’s `evaluate` target must assume that `test.csv` is located at **`data/raw/test.csv`**.

---

## What’s expected

**One model.** You must choose a single final model for `shares`. Your submission should reflect that choice clearly.

**`make evaluate`.** Your repo must include a **Makefile** with an **`evaluate`** command. When I run **`make evaluate`**, it must:

1. Load your trained model (or train it from `train.csv` and then evaluate),
2. Read test data from **`data/raw/test.csv`**,
3. Compute predictions for the test set,
4. **Print only the test MSE** to stdout—no other output.

Example of acceptable output:

```
MSE: 1234.56
```

**Replicability.** 
The repo must run on my machine without extra guesswork. 
Ensure **`make evaluate`** works once `test.csv` is in `data/raw/` in the project root directory.

**Model selection.** 
Your final model should be chosen in a structured way (e.g. variable selection and/or cross-validation). 
That process should be visible in your code and/or a short write-up.

**README.** 
Your repo’s README must contain a **thorough explanation of all the choices you made** along the way and **why** you made them. 
That includes (but is not limited to) preprocessing, variable or feature selection, choice of model, and any tuning or validation choices—with clear rationale for each.

**AI usage.** 
If you use any AI tools (e.g. ChatGPT, Copilot, Cursor), you must document how you used them (what for, and to what extent) in the README or a separate file (e.g. `AI_USAGE.md`).

---

## How you’re assessed

Your submission is evaluated on:

1. **Code quality.** Code should be clean, well-structured, and well-documented so that your approach is easy to follow.
2. **README.** The README thoroughly explains all choices made (preprocessing, variable selection, model, tuning, etc.) and their rationale.
3. **Replicability.** The repo runs on my machine without issues; environment is clearly specified; **`make evaluate`** works once `test.csv` is in `data/raw/`.
4. **Model selection.** A thoughtful, structured process (e.g. variable selection and cross-validation) is used to arrive at the final model, and that process is visible in the code and/or a short write-up.
5. **Prediction performance.** Your model’s test MSE is compared to a hidden baseline. You must outperform this baseline to receive full credit for the prediction component.
6. **AI usage.** Any use of AI tools is clearly documented (what for, and to what extent).

---

## Methodology and Model Choices

### Preprocessing

**Log transformation of target variable:** The `shares` variable is highly right-skewed (ranging from 1 to 843,300), which violates the normality assumptions of linear regression. I transformed the target to `log(shares)` to normalize the distribution and improve model performance. Predictions are made on the log scale and then converted back using `exp()` for evaluation.

**Removed non-numeric predictors:** The `url` column was removed as it contains text data and cannot be used as a predictor in glmnet, which requires all features to be numeric.

**Removed zero-variance predictors:** Predictors with no variation (same value across all observations) were removed using `step_zv()` as they provide no information for prediction and can cause numerical issues.

**Normalization:** All numeric predictors were standardized (centered and scaled) using `step_normalize()`. This is essential for regularized regression models like glmnet, which are sensitive to the scale of variables. Normalization ensures all predictors contribute equally to the penalty term.

### Model Selection

**Regularized Linear Regression (glmnet):** I chose elastic net regression implemented via glmnet because:
- It handles high-dimensional data well (60+ predictors)
- It performs automatic variable selection (Lasso component) while maintaining stability (Ridge component)
- It helps prevent overfitting through regularization
- It's computationally efficient for cross-validation

**Elastic Net (mixture parameter):** Rather than choosing pure Lasso (mixture=1) or pure Ridge (mixture=0), I tuned the `mixture` parameter from 0 to 1 to find the optimal balance. This allows the model to benefit from both:
- Lasso's variable selection capability (can set coefficients to exactly zero)
- Ridge's stability with correlated predictors

**Penalty parameter:** The regularization strength (`penalty`) was tuned on a log10 scale from 1e-6 to 1e1. This wide range allows the model to find the optimal balance between model complexity and generalization.

### Model Tuning and Validation

**10-fold Cross-Validation:** I used 10-fold CV to tune hyperparameters because:
- It provides a robust estimate of model performance without needing a separate validation set
- It uses all available training data efficiently
- It gives 10 performance estimates per parameter combination for more reliable selection

**Grid search:** A regular grid with 10 levels for each parameter (100 total combinations) was used to systematically explore the hyperparameter space. RMSE was used as the evaluation metric to select the best parameters.

**Final model fitting:** After selecting the best hyperparameters via CV, the final model was fit on the entire training dataset to maximize the data available for learning.

### Environment

**Required R packages:**
- `tidyverse` (for data manipulation)
- `tidymodels` (for modeling framework)
- `glmnet` (for regularized regression engine)

These can be installed with:
```r
install.packages(c("tidyverse", "tidymodels", "glmnet"))
```

**Setup after cloning:**
1. Ensure R is installed 
2. Install required packages (see above):
   ```r
   install.packages(c("tidyverse", "tidymodels", "glmnet"))
   ```
3. The training data should be in `data/raw/train.csv`. 
   ```
4. Run `make evaluate` to train the model and evaluate (once `test.csv` is provided by the instructor)

### AI Usage

I used Cursor (an AI-powered code editor) extensively throughout this project to:
- Write the initial R code structure for training and evaluation scripts
- Debug errors and fix issues (e.g., missing packages, non-numeric column handling)
- Generate beginner-friendly comments explaining each step
- Create the Makefile for automation
- Install missing R package dependencies

The AI assistance was primarily for code generation, error debugging, and documentation. All methodological choices (log transformation, model selection, CV approach) were made based on standard machine learning best practices for regression problems with skewed targets.

---

## Submission

- Your submission must be a **GitHub repository** named **`ecn372-hw2`**, containing your code and this README.
- To submit, open an **Issue** in this repository (the course repo):
  - **Title:** Your full name (e.g. `Giorgi Nikolaishvili`).
  - **Body:** Only the link to your `ecn372-hw2` repo (nothing else).
- Submissions via email, Canvas, or any other channel will **not** be accepted.

I will clone your repo from the link in your Issue, add `test.csv` to `data/raw/`, and run **`make evaluate`** to obtain your test MSE.
