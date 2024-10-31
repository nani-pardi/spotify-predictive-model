# EDA should only be conducted on portion of training data
library(tidyverse)
library(tidymodels)
library(here)
library(naniar)

# set seed
set.seed(219)

# handle common conflicts
tidymodels_prefer()

# Load data
load(here("data/spotify_valid.rda"))

view(miss_var_summary(spotify_valid))

summary(spotify_valid)

# Right skewed Plot
ggplot(spotify_valid, aes(x = speechiness)) +
  geom_density()

# Log Transformation applied
ggplot(spotify_valid, aes(x = log10(speechiness))) +
  geom_density()

# Right skewed Plot
ggplot(spotify_valid, aes(x = acousticness)) +
  geom_density()

# Log Transformation applied
# Slightly less left skewed plot
ggplot(spotify_valid, aes(x = log10(acousticness))) +
  geom_density()

# Slight left skewed plot
ggplot(spotify_valid, aes(x = energy)) +
  geom_density()

ggplot(spotify_valid, aes(x = loudness)) +
  geom_density()

ggplot(spotify_valid, aes(x = key)) +
  geom_density()

# Incredibly right skewed plot
ggplot(spotify_valid, aes(x = instrumentalness)) +
  geom_density()

# Log transformation applied
ggplot(spotify_valid, aes(x = log10(instrumentalness))) +
  geom_density()

# Plot with peaks
ggplot(spotify_valid, aes(x = tempo)) +
  geom_density()

