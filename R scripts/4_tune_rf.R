# L08 Model Tuning ----
# Define and tune random forest

## Set seed
set.seed(219)

## load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doParallel)

# handle common conflicts
tidymodels_prefer()

# load folds data
load(here("data/spotify_folds.rda"))


# load preprocessing/feature engineering/recipe
load(here("results/tree_recipe.rda"))

################################################
# set up parallel processing!
num_cores <- parallel::detectCores(logical = TRUE)

cl <- makePSOCKcluster(num_cores)
registerDoParallel(cl)

################################################

# model specifications
rf_mod <- rand_forest(trees = 1000, 
                      min_n = tune(), 
                      mtry = tune()) |> 
  set_engine('ranger') |> 
  set_mode('classification')


# define workflows
rf_wflow <- workflow() |>
  add_model(rf_mod) |>
  add_recipe(tree_recipe)

# get parameters and define tuning grid
rf_params <-  extract_parameter_set_dials(rf_mod) |>
  update(mtry = mtry (range = c(1, 12)))

rf_grid <- grid_regular(rf_params, levels = 5)

# tune models
tune_rf_1000 <- rf_wflow |>
  tune_grid(
    resamples = spotify_folds,
    grid = rf_grid,
    control = control_grid(save_workflow = TRUE)
  )


# Stop cluster
stopCluster(cl)


# write out results
save(tune_rf_1000, file = here("results/tune_rf_1000.rda"))

