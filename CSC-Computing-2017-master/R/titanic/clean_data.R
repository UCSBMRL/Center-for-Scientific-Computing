# Burak Himmetoglu
# 10-11-2017
# bhimmetoglu@ucsb.edu
#
# Titanic Survival Prediction -- Data Cleaning
#
# Libraries
library(readr)
library(dplyr)
library(Matrix)
library(stringr)

# Read data
train <- as.data.frame(read_csv("./data/train.csv", col_types = 'iiiccdiicdcc'))
test <- as.data.frame(read_csv("./data/test.csv", col_types = 'iiccdiicdcc'))

## Merge train and test for common processing
# First remove Survied column and keep it in a vector
survival <- select(train, c(Survived,PassengerId))
train <- mutate(train, Survived = NULL) %>% 
  mutate(is.train = 1) # Flag training data with is.train = 1

test <- mutate(test, is.train = 0) # Flag test data with is.train = 0
allData <- rbind(train,test)

# Find NA's
totNA <- function(x) { 
  temp <- is.na(x)
  sum(temp)
  } # Finds total number of NA's in a given vector x
naCols <- allData %>% summarize_all(funs(totNA))# For all the columns, finds how many NAs there are
cat("Number of NA's I have found: \n")
naCols

## Use titles of passangers as categorical variables
titles <- character(length = nrow(allData))
for (i in 1:nrow(allData)){
  temp <- str_split(allData$Name[i], "\\.")[[1]][1]
  titles[i] <- str_trim(str_split(temp, ",")[[1]][2], "left")
}
# Just keep the Title, remove name
allData <- allData %>% 
  mutate(title = as.factor(titles)) %>% 
  select(-Name)

# Check how many passangers there are with a given title
cat('Number of passangers per title')
allData %>% group_by(title) %>% count()

# Fill missing age information by Title
medAge <- allData %>% 
  group_by(title) %>% 
  summarise(medAge = median(Age, na.rm = TRUE))

allData <- allData %>% left_join(medAge, by="title")
allData[is.na(allData$Age), ]$Age <- allData[is.na(allData$Age), ]$medAge

# Find the most common embarked value
mostCommonEmbarked <- allData %>% 
  group_by(Embarked) %>% 
  summarize(nEmb = n()) %>% 
  arrange(desc(nEmb)) %>% 
  slice(1)
mostCommonEmbarked <- mostCommonEmbarked$Embarked # Pick the name

# Fill the NAs in Embarked with mostCommonEmbarked
fillEmbarked <- function(x){ x[is.na(x)] <- mostCommonEmbarked; x }
allData <- allData %>% mutate(Embarked = fillEmbarked(Embarked))

# There are so many NAs in Cabin 1024 out of 1309 observations. Create a has.cabin column
allData <- allData %>% mutate(has.cabin = ifelse(is.na(Cabin), 0, 1)) 

# Get the letter coding of the Cabin
letterCabin <- as.data.frame(substring(allData$Cabin, 1,1), stringsAsFactors = FALSE)
colnames(letterCabin) <- c("letCabin")
allData$letCabin <- letterCabin$letCabin

# Let's have a new level of cabin called NoCabin 
allData[allData$has.cabin == 0, ]$letCabin <- "No"
allData$Cabin <- NULL

## Fill missing Fare info based on class
medFare <- allData %>% group_by(Pclass) %>% 
  summarize(medFare = median(Fare, na.rm = TRUE))

allData <- allData %>% 
  left_join(medFare, by="Pclass")
allData[is.na(allData$Fare), ]$Fare <- allData[is.na(allData$Fare), ]$medFare

# Check that all NAs are dealt with
naCols <- allData %>% summarize_all(funs(totNA)) 
if (any(naCols > 0)) cat("There are still NA's to fix!")

# Add a new column named FamSize (Family Size)
allData <- allData %>% mutate(FamSize = SibSp + Parch)

# Convert some characters into factors
allData <- allData %>% 
  mutate_at(vars(Pclass,Sex,letCabin,Embarked,Pclass,has.cabin),funs(as.factor))

# We don not need Ticket column
allData$Ticket <- NULL

# Now, split back into train and test
train <- allData %>% 
  filter(is.train == 1) %>% 
  mutate(is.train = NULL) %>%
  left_join(survival, by = "PassengerId")
test <- allData %>% 
  filter(is.train == 0) %>% 
  mutate(is.train = NULL)

## Standardize columns Age, SibSp, Parch, Fare, medAge, medFare, FamSize
standardize <- function(x){
  (x-mean(x))/sd(x)
}

# Train
train <- train %>% 
  mutate_at(vars(Age,SibSp,Parch,Fare,medAge,medFare,FamSize),funs(standardize))

# Test
test <- test %>% 
  mutate_at(vars(Age,SibSp,Parch,Fare,medAge,medFare,FamSize),funs(standardize))

# Clean: Remove unnecessary variables. Then collect garbage
rm(allData,naCols,survival,fillEmbarked,totNA,medAge,medFare, 
   letterCabin, titles, mostCommonEmbarked); gc()
