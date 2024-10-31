# Recipes and feature engineering

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(recipes)
library(naniar)

# load data ----
load(here("data/spotify_train.rda"))

# set seed
set.seed(219)

# Sink Recipe
sink_recipe <- recipe(track_popularity ~.,
                      data = spotify_train) |>
  step_rm(track_name, track_artist, track_album_name, track_id, playlist_id, 
          track_album_id, playlist_name, track_album_release_date) |>
  step_dummy(all_nominal_predictors()) |>
  step_log(acousticness, offset = 1) |>
  step_log(speechiness, offset = 1) |>
  step_log(instrumentalness, offset = 1) |>
  step_zv(all_numeric_predictors()) |>
  step_center(all_numeric_predictors(), na_rm = TRUE) |>
  step_scale(all_numeric_predictors(), na_rm = TRUE)
  
  
# Prep and bake new recipe
prep(sink_recipe) |>
  bake(new_data = NULL) 

summary(sink_recipe)

# Feature engineering recipe for tree
tree_recipe <- recipe(track_popularity ~.,
                      data = spotify_train) |>
  step_rm(track_name, track_artist, track_album_name, track_id, playlist_id, 
          track_album_id, playlist_name, track_album_release_date) |>
  step_zv(all_numeric_predictors())

# Prep and bake new recipe
prep(tree_recipe) |>
  bake(new_data = NULL) 

# Save out Files
save(sink_recipe, file = here("results/sink_recipe.rda"))
save(tree_recipe, file = here("results/tree_recipe.rda"))

