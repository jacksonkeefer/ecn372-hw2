# Makefile for ECN 372 Homework 2
# makefile to train and evaluate the model

.PHONY: evaluate train

# Default target
.DEFAULT_GOAL := evaluate

# Train the model
train:
	@echo "Training model..."
	Rscript --vanilla Src/Train.r

# Evaluate the model on test data
# This first trains the model, then evaluates it
evaluate: train
	@echo "Evaluating model..."
	Rscript --vanilla Src/Evaluate.r
