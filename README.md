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

## Submission

- Your submission must be a **GitHub repository** named **`ecn372-hw2`**, containing your code and this README.
- To submit, open an **Issue** in this repository (the course repo):
  - **Title:** Your full name (e.g. `Giorgi Nikolaishvili`).
  - **Body:** Only the link to your `ecn372-hw2` repo (nothing else).
- Submissions via email, Canvas, or any other channel will **not** be accepted.

I will clone your repo from the link in your Issue, add `test.csv` to `data/raw/`, and run **`make evaluate`** to obtain your test MSE.
