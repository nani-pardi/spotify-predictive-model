# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(recipes)
library(naniar)

# handle common conflicts
tidymodels_prefer()

# load data ----
load(here("results/sink_recipe.rda"))
load(here("data/spotify_folds.rda"))


# set seed
set.seed(219)

# model specifications
logistic_mod <- logistic_reg() |> 
  set_engine("glm") |> 
  set_mode("classification")

# define workflows
logistic_wflow <- workflow() |>
  add_model(logistic_mod) |>
  add_recipe(sink_recipe)

# fit workflows/models
fit_logistic <- logistic_wflow |>
  fit_resamples(
    resamples = spotify_folds,
    control = control_resamples(save_workflow = TRUE)
  )

# write out results
save(fit_logistic, file = here("results/fit_logistic.rda"))
