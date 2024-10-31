# Initial data checks & data splitting
library(tidyverse)
library(tidymodels)
library(here)
library(naniar)

# set seed
set.seed(219)

# handle common conflicts
tidymodels_prefer()

# Load and clean data
spotify_data_og <- read_csv(here("data/spotify_songs.csv")) |>
  janitor :: clean_names()

# Check for missingness in data
view(miss_var_summary(spotify_data_og))

# Remove entries with missing data
clean_spotify_data <- na.omit(spotify_data_og)

# Recheck for missingness
view(miss_var_summary(clean_spotify_data))

summary(clean_spotify_data)
dim(clean_spotify_data)

# Turn valence into a factor
vfact <- cut(clean_spotify_data$valence, 3)
vfact <- fct_recode(vfact, 
                    "Low" = "(-0.000991,0.33]",
                    "Medium" = "(0.33,0.661]",
                    "High" = "(0.661,0.992]")

# turn danceability into a factor
dfact <- cut(clean_spotify_data$danceability, 3)
dfact <- fct_recode(vfact, 
                    "Low" = "(-0.000983,0.328]",
                    "Medium" = "(0.328,0.655]",
                    "High" = "(0.655,0.984]")

lfact <- cut(clean_spotify_data$liveness, 3)
lfact <- fct_recode(lfact, 
                    "Low" = "(-0.000996,0.332]",
                    "Medium" = "(0.332,0.664]",
                    "High" = "(0.664,0.997]")

popular <- cut(clean_spotify_data$track_popularity, 2)
popular <- fct_recode(popular,
           "Not popular" = "(-0.1,50]",
           "Popular" = "(50,100]")

# Apply changes to dataset
clean_spotify_data <- clean_spotify_data |>
  mutate(track_popularity = popular,
         mode = factor(mode),
         playlist_genre = factor(playlist_genre),
         playlist_subgenre = factor(playlist_subgenre),
         playlist_name = factor(playlist_name),
         valence = vfact,
         danceability = dfact,
         liveness = lfact,
         track_album_release_date =  ymd(track_album_release_date))

# Remove any NA's again
view(miss_var_summary(clean_spotify_data))
clean_spotify_data <- na.omit(clean_spotify_data)

# Look at the dataset to check for skewness in target variable
summary(clean_spotify_data)

# The track popularity 
ggplot(clean_spotify_data, aes(x = track_popularity)) +
  geom_bar() +
  theme_minimal()


# Take a smaller stratified sample of data
# This data has more entries than my computer can process in a reasonable time
# Take 10,000
dim(clean_spotify_data)

spotify_data <- clean_spotify_data |>
  group_by(track_popularity) |>
  slice_sample(n = 5000) |>
  ungroup()

dim(spotify_data)
# initial split
spotify_split <- initial_validation_split(spotify_data, 
                                          prop = c(.7, .15), 
                                          strata = track_popularity)

spotify_valid <- validation(spotify_split)
spotify_train <- training(spotify_split)
spotify_test <- testing(spotify_split)

# fold your data
spotify_folds <- spotify_train |>
  vfold_cv(v = 5, repeats = 3, strata = track_popularity)

# write out results (training/testing data)
save(spotify_valid, file = here("data/spotify_valid.rda"))
save(spotify_train, file = here("data/spotify_train.rda"))
save(spotify_test, file = here("data/spotify_test.rda"))
save(spotify_folds, file = here("data/spotify_folds.rda"))
