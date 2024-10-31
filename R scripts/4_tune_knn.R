# L08 Model Tuning ----
# Define and tune KNN
## Set seed
set.seed(219)

## load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(kknn)
library(doParallel)

# handle common conflicts
tidymodels_prefer()

# load folds data
load(here("data/spotify_folds.rda"))


# load preprocessing/feature engineering/recipe
load(here("results/sink_recipe.rda"))



################################################
# set up parallel processing!
num_cores <- parallel::detectCores(logical = TRUE)

cl <- makePSOCKcluster(num_cores)
registerDoParallel(cl)


################################################

# model specifications
knn_mod <- nearest_neighbor(neighbors = tune()) |>
  set_mode("classification") |>
  set_engine("kknn")

# define workflows
knn_wflow <- workflow() |>
  add_model(knn_mod) |>
  add_recipe(sink_recipe)


# get parameters and define tuning grid
knn_params <- extract_parameter_set_dials(knn_mod) |>
  update(neighbors = neighbors(range = c(1,20)))

knn_grid <- grid_regular(knn_params, levels = 20)

# tune models
tune_knn <- knn_wflow |>
  tune_grid(
    resamples = spotify_folds,
    grid = knn_grid,
    control = control_grid(save_workflow = TRUE)
  )


# Stop cluster
stopCluster(cl)


# write out results
save(tune_knn, file = here("results/tune_knn.rda"))
