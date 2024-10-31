## load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(kknn)
library(knitr)
library(doParallel)

# set seed
set.seed(219)

# handle common conflicts
tidymodels_prefer()

## load results ----
load(here("data/spotify_train.rda"))
load(here("data/spotify_test.rda"))
load(here("data/spotify_folds.rda"))
load(here("results/fit_logistic.rda"))
load(here("results/tune_knn.rda"))
load(here("results/tune_rf_1000.rda"))

# visualize tuning performance
autoplot(tune_knn)
show_best(tune_knn, metric = "accuracy")

show_best(fit_logistic, metric = "accuracy")

autoplot(tune_rf_1000)
show_best(tune_rf_1000, metric = "accuracy")

rf_results <- tune_rf_1000 |>
  collect_metrics() |>
  arrange(mean)


model_results <- as_workflow_set(
  lm = fit_logistic,
  knn = tune_knn,
  rf_1000 = tune_rf_1000)


final_wflow <- extract_workflow(tune_rf_1000) |>
  finalize_workflow(select_best(tune_rf_1000,
                                metric = "accuracy"))

rf_final_fit <- fit(final_wflow, spotify_train)

save(rf_final_fit, file = here("results/rf_final_fit.rda"))

rf_predict <- spotify_test |>
  select(track_popularity) |>
  bind_cols(predict(rf_final_fit, spotify_test)) 

rf_predict |>
  accuracy(track_popularity, .pred_class)

accuracy_result <- rf_predict |>
  accuracy(track_popularity, .pred_class)

kable(accuracy_result, caption = "Model Accuracy", digits = 3)

rf_predict |>
  conf_mat(track_popularity, .pred_class) |>
  autoplot(type = "heatmap")

rf_predict |> 
  roc_auc(track_popularity, .pred_class)
