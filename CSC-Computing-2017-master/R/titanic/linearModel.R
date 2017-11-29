# Burak Himmetoglu
# 10-11-2017
# bhimmetoglu@ucsb.edu
#
# Titanic Survival Prediction -- Basic Modeling
#
# Libraries
library(glmnet)
library(doMC)
registerDoMC() # For parallel processing, you can add number of cores

# Clean and prepare data
source('clean_data.R')

# Let us remove PassangerId as a predictor
train <- train %>% select(-PassengerId) 
testId <- test %>% select(PassengerId) # Save PassengerId for later
test <- test %>% select(-PassengerId) 

# Let us contruct model matrices from train and test
trainMatrix <- model.matrix(Survived ~., data = train)[,-1]
testMatrix <- model.matrix(~., data = test)[,-1]

# Take a look at what they look like
cat("The model Matrix turns factors into binary values:\n")
head(trainMatrix)

# Notice that Pclass=1 and Embarked=C is chosen as reference levels by model.matrix
# e.g. Pclass2 = Pclass = 0 means the observarion has Pclass 1 (same for Embarked)

# Let us train a Regularized Logistic Regression Model by 10-fold cross-validation
ytrain <- as.factor(train$Survived)
cv.logreg <- cv.glmnet(x = trainMatrix, y = ytrain, 
                       nfolds = 10, family = "binomial", parallel = TRUE)

# Choose the best lambda (alpha = 1 is set by default)
bestLambda <- cv.logreg$lambda.min

# Now fit with the bestLambda
mod.logreg <- glmnet(x = trainMatrix, y = ytrain, 
                     family = "binomial", lambda = bestLambda)

ypred <- predict(mod.logreg, 
                 newx = trainMatrix, 
                 type = "response") # Probability of survival is predicted

# If you choose type = "class" 0's and 1's will be predicted:
# Prob >= 0.5 --> Survived = 1, Prob < 0.5 --> Survived = 0

# Accuracy
ypred_binary <- ifelse(ypred >= 0.5, 1, 0)
acc = sum(ypred_binary == ytrain) / length(ytrain) *100
cat("Predicted accuracy = ", acc)

## A bit more advanced measure of performance
# What is the area under the ROC curve? 
library(pROC)
auc <- roc(ytrain, ypred[,1]) 
auc # ~ 0.86, not too bad for a simple model!
##

## Prediction on the unlabeled test set

# Finally predict on test set on test set
testSurvived <- predict(mod.logreg, newx = testMatrix, type = "class") 

# Bind with passangerId's
submit <- cbind(testId, testSurvived); 
colnames(submit) <- c("PassengerId", "Survived")

# Finally, write on file. You can submit to Kaggle if you wish!
write_csv(submit, path = "submission.csv")
