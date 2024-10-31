## Basic repo setup for final project

Describe project and general structure of repo ...
Here you will find three folder: data, results, and R scripts.

Data holds the original csv, from where the data was extracted. Additionally it holds the data from the inital_validation_split, as well as the folds. 

The results folder contains the logistic_fit, the tune_knn, tune_rf.
It also contains both recipes, the tree recipe and the sink recipe. Lastly it has the final fit of the random forest.

Lastly r scripts contain the various r scripts. It starts with the intial data, where the target variable is analyzed and and split. then it has an eda script that looks at the predictor variables. Next there is a separate script for the recipes script, which contains two recipes. Then there are three separate scripts which develop each of the models. the last script contains the model analysis, which shows the best model and then fits it.

