## Processing of Titanic Data
library(class)
setwd("./titanic")
source("../auto/tomkit.R")
test <- read.csv("./data/test.csv")
train <- read.csv("./data/train.csv")

scale_map <- function(x,y){
    a <- aggregate(y ~ x, data=data.frame(x,y), mean)
    .ret <- a$y/min(a$y)
    names(.ret) <- a$x
    return(.ret)
}


## TRANSFORM Training Set 
pclass_map <- scale_map(train$Pclass, train$Survived)
gender_map <- scale_map(train$Sex, train$Survived)
embark_map <- scale_map(train$Embarked, train$Survived)

train$embark_alt <- embark_map[train$Embarked]
train$embark_alt[train$Embarked=='' | is.na(train$Embarked)] <- mean(train$embark_alt, na.rm=TRUE)

train$under10 <- 0
train$under10[train$Age <10] <- 1

train$over60 <- 0
train$over60[train$Age >60] <- 1

age_map1 <- scale_map(train$under10, train$Survived)
age_map2 <- scale_map(train$over60, train$Survived)

train_alt <- data.frame(
    survived = train$Survived,
    pid = train$PassengerId,
    pclass = pclass_map[train$Pclass],
    gender = gender_map[train$Sex],
    embark = train$embark_alt,
    under10 = age_map1[as.character(train$under10)],
    over60 = age_map2[as.character(train$over60)])

test$embark_alt <- embark_map[test$Embarked]
test$embark_alt[test$Embarked=='' | is.na(test$Embarked)] <- mean(train$embark_alt, na.rm=TRUE)

test$under10 <- 0
test$under10[test$Age <10] <- 1

test$over60 <- 0
test$over60[test$Age >60] <- 1

test_alt <- data.frame( pid = test$PassengerId,
    pclass = pclass_map[test$Pclass],
    gender = gender_map[test$Sex],
    embark = test$embark_alt,
    under10 = age_map[as.character(test$under10)],
    over50 = age_map2[as.character(test$over60)])
    
    
test_knn <- function(x, i){
    test_index <- sample(seq_along(x$survived), 80, replace=FALSE)
    chunk1 <- x[-test_index,]
    chunk2 <- x[test_index,]
    chunk2$prediction <- knn(chunk1[,3:7], chunk2[,3:7], chunk1$survived, k=i)
    return(sum(chunk2$survived == chunk2$prediction)/80)
}

objective_k <- lapply(1:20, function(i){
    .ret <- replicate(100, test_knn(train_alt, i))
    return(data.frame(k=i, avg_score=mean(.ret)))
})

objective_k <- do.call("rbind", objective_k)
plot(objective_k$k, objective_k$avg_score)

### Empirically k = 4

test_alt$prediction <- knn(train_alt[,3:7], test_alt[,2:6], train_alt$survived, k=4)

output <- paste(test_alt$pid, test_alt$prediction, sep=",")
output <- paste(output, collapse="\n")
sink("output.csv")
cat("PassengerId,Survived", fill=TRUE)
cat(output, fill=TRUE)
sink()


