# Burak Himmetoglu
# 10-11-2017
# bhimmetoglu@ucsb.edu
#
# Titanic Survival Prediction -- Visualization
#
# Libraries
library(ggplot2)

# Read data (only training)
train <- as.data.frame(read_csv("./data/train.csv", col_types = 'iiiccdiicdcc'))
train <- train %>%
  mutate(Sex=as.factor(Sex)) %>%
  mutate(Survived = as.factor(Survived)) %>%
  mutate(Pclass = as.factor(Pclass))

# Survival by gender 
gg0 <- ggplot(train, aes(Survived)) + geom_bar(aes(fill=Sex),position="dodge") + 
  ggtitle("Survival count by gender")
gg0

# Survival by Pclass and gender
gg1 <- ggplot(train, aes(Survived)) + geom_bar(aes(fill=Sex),position="dodge") + 
  facet_grid(.~Pclass) + 
  ggtitle("Survival count by gender and Pclass")
gg1

# Survival by Fare and Gender
gg2 <- ggplot(train %>% filter(Fare <= 200), aes(Survived, Fare)) + 
  geom_boxplot(aes(fill=Survived)) + 
  facet_grid(.~Sex) +
  ggtitle("Survival by Fare and Gender")
gg2

# Survival by Age and Gender
gg3 <- ggplot(train, aes(Age)) +
  geom_histogram(bins=10, aes(fill=Sex)) +
  facet_grid(.~Survived) +
  ggtitle("Survival by Age and Gender")
gg3

# Survival by Pclass, Age, Sex
gg4 <- ggplot(train, aes(Age,Survived)) + 
  geom_jitter(aes(color=Sex), size=2.5, height=0.3) + 
  facet_grid(.~Pclass)
gg4
