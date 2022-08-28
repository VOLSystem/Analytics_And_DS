load("WATERPOINTPredictions.RData")

library(robustbase)
library(regclass)
library(lubridate)
library(discretization)
library(regclass)
library(caret)
library(caretEnsemble)
library(nnet)
library(e1071)
library(glmnet)
library(gbm)
library(pROC)
library(parallel)
library(doParallel)

suggest_transformation <- function(x,powers,add=0) {
  if(add!=0) { x <- x + add }
  if(min(x)<=0) { powers <- powers[which(powers>0)] }
  skewnesses <- rep(0,length(powers))
  for (p in powers) {
    if(p==0) { x.trans <- log10(x) } else { x.trans <- x^p }
    skewnesses[which(powers==p)] <- mc(x.trans)
  }
  best.p <- powers[which.min(skewnesses)]
  if(best.p==0) { return("log10")} else { return(best.p) }
}

combine_infrequent_levels <- function(x,threshold=20,newname="Combined") { 
  x <- factor(x)
  rare.levels <- names( which( sort( table(x) ) <= threshold ) )
  if(length(rare.levels)==0) { return(list(values=x,combined=NULL)) }
  
  levels(x)[ which(levels(x) %in% rare.levels) ] <- newname
  ST <- sort(table(x))
  if(ST[newname]<=threshold) {  #Combined will be the least frequent level
    levels.to.combine <- which( levels(x) %in% c(newname,names(ST)[2]))
    levels(x)[levels.to.combine] <- newname
    rare.levels <- c(rare.levels,names(ST)[2])}
  return(list(values=x,combined=rare.levels))
}

discretize_x_for_categorical_y <- function(DATA,threshold=0,train.rows=NA,equal=FALSE) {
  require(discretization)
  require(regclass)
  if(class(DATA[,1]) %in% c("character","factor")) {
    if(threshold == 0 | is.na(threshold)) { } else { 
      DATA[,1] <- combine_infrequent_levels(DATA[,1],threshold)$values }
    if( length(train.rows)>1 ) { HALFDISC <- DATA[train.rows,] } else { HALFDISC <- DATA }
    A <- aggregate(HALFDISC[,2]~HALFDISC[,1],FUN=function(x)mean(x==levels(x)[1])) 
    A <- A[order(A[,2]),]
    SUB <- HALFDISC
    SUB[,1] <- match(HALFDISC[,1],A[,1]) 
    disc.scheme <- mdlp(SUB)
    cutoffs <- sort( unlist( disc.scheme$cutp ) )
    A$value <- 1:nrow(A)
    A$code <- factor( rep(letters[1:(length(cutoffs)+1)],nrow(A)) )[1:nrow(A)] 
    for (i in 1:length(cutoffs)) {
      if(i==1) { A$code[1:floor(cutoffs[1])] <- letters[1] } else { 
        A$code[ which(A$value > cutoffs[i-1] & A$value <= cutoffs[i]) ] <- letters[i] }
    }
    A$code[ which(A$value>max(cutoffs)) ] <- letters[i+1]
    names(A) <- c( "OldValue","yAverage","Rank","NewValue")
    results <- list(Details=A,newlevels= factor( A$NewValue[ match(DATA[,1],A[,1]) ] ) )
    y <- DATA[,2]
    x <- results$newlevels
    TEMP <- data.frame(y,x)
    
    mosaic(y~x,data=TEMP,xlab="New Levels",ylab=names(DATA)[2],inside=TRUE,equal=equal)
    return( results ) } else {
      
      
      
      if( length(train.rows)>1) { HALFDISC <- DATA[train.rows,] } else { HALFDISC <- DATA }
      SUB <- HALFDISC
      disc.scheme <- mdlp(SUB)
      cuts <- unlist( disc.scheme$cutp )
      A <- aggregate(disc.scheme$Disc.data[,2]~disc.scheme$Disc.data[,1],FUN=function(x)mean(x==levels(x)[1]))
      details <- data.frame(Lower=rep(0,nrow(A)),Upper=rep(0,nrow(A)),yAverage=rep(0,nrow(A)),NewValue=rep(0,nrow(A)))
      
      for (i in 1:nrow(details)) {
        details$Lower[i] <- min( SUB[ which(disc.scheme$Disc.data[,1]==i),1] )
        details$Upper[i] <- max( SUB[ which(disc.scheme$Disc.data[,1]==i),1] )
        details$NewValue[i] <- letters[i]
      }
      details$yAverage <- A[,2]
      newvalues <- rep(0,nrow(DATA)) 
      for (i in 1:nrow(DATA)) {
        temp <- which( DATA[i,1] >= details$Lower )
        if(length(temp)>0) { temp <- max( which( DATA[i,1] >= details$Lower ) ) } else { temp <- 1 }
        newvalues[i] <- details$NewValue[temp]
      }
      results <- list(Details=details,newlevels=factor(newvalues))
      y <- DATA[,2]
      x <- results$newlevels
      TEMP <- data.frame(y,x)
      mosaic(y~x,data=TEMP,xlab="New Levels",ylab=names(DATA)[2],inside=TRUE,equal=equal)
      return(results) }
}


ALL <- rbind(TRAIN,HOLDOUT.TO.SHARE)

#HOLDOUT.TO.SHARE$installer <- combine_infrequent_levels(HOLDOUT.TO.SHARE$installer,threshold=400)$values
#HOLDOUT.TO.SHARE$funder <- combine_infrequent_levels(HOLDOUT.TO.SHARE$funder,threshold=600)$values
#HOLDOUT.TO.SHARE$num_private <- log10(HOLDOUT.TO.SHARE$num_private+1)
#HOLDOUT.TO.SHARE$region_code <- factor( HOLDOUT.TO.SHARE$region_code )
#HOLDOUT.TO.SHARE$district_code <- factor( HOLDOUT.TO.SHARE$district_code )
#HOLDOUT.TO.SHARE$lga <- combine_infrequent_levels(HOLDOUT.TO.SHARE$lga,600)$values


#For knn, regression, need data in a very specific form

#TRAIN.TRANS will contain symmetrized version of the numerical predictors
ALL.TRANS <- ALL
ALL.TRANS$installer <- combine_infrequent_levels(ALL.TRANS$installer,threshold=400)$values
ALL.TRANS$funder <- combine_infrequent_levels(ALL.TRANS$funder,threshold=600)$values
ALL.TRANS$num_private <- log10(ALL.TRANS$num_private+1)
ALL.TRANS$region_code <- factor( ALL.TRANS$region_code )
ALL.TRANS$district_code <- factor( ALL.TRANS$district_code )
ALL.TRANS$lga <- combine_infrequent_levels(ALL.TRANS$lga,600)$values


hist(ALL.TRANS$amount_tsh)
suggest_transformation(ALL.TRANS$amount_tsh,powers=seq(-3,3,.5), add=1 )
hist( (ALL.TRANS$amount_tsh+1)^(-3) )
hist( log10(ALL.TRANS$amount_tsh+1) )
#I don't like -3, but I do like the log, so....
ALL.TRANS$amount_tsh <- log10(ALL.TRANS$amount_tsh+1)

hist(ALL.TRANS$gps_height)
hist(ALL.TRANS$longitude)
hist(ALL.TRANS$latitude)  #These look fine, no transformations are going to make them more symmetric

hist(ALL.TRANS$population)
summary(ALL.TRANS$population)
suggest_transformation(ALL.TRANS$population,powers=seq(-3,3,.5), add=1 )
hist( log10(ALL.TRANS$population) )
ALL.TRANS$population <- log10(ALL.TRANS$population)


hist(ALL$age)  #looks ok, but a negative value indicates an integrity issue
length(which(ALL$age<0))


##Scaling and transformation
ALL.TRANSSCALED <- ALL.TRANS
column.classes <- unlist(lapply(ALL.TRANSSCALED,FUN=class))  #Get classes of each column
numeric.columns <- which(column.classes %in% c("numeric","integer"))  #Positions of numerical volumns
ALL.TRANSSCALED[,numeric.columns] <- as.data.frame( scale(ALL.TRANSSCALED[,numeric.columns]) )


##Just scaling
ALL.SCALED <- ALL
column.classes <- unlist(lapply(ALL.SCALED,FUN=class))  #Get classes of each column
numeric.columns <- which(column.classes %in% c("numeric","integer"))  #Positions of numerical volumns
ALL.SCALED[,numeric.columns] <- as.data.frame( scale(ALL.SCALED[,numeric.columns]) )



TRAIN.RAW <- ALL[1:nrow(TRAIN),]
TRAIN.SCALED <- ALL.SCALED[1:nrow(TRAIN),]
TRAIN.TRANS <- ALL.TRANS[1:nrow(TRAIN),]
TRAIN.TRANSSCALED <- ALL.TRANSSCALED[1:nrow(TRAIN),]

##K nearest neighbors
require(parallel)
require(doParallel)
cluster <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
registerDoParallel(cluster)

knnGrid <- expand.grid(k = 1:40)   
fitControl <- trainControl(method="cv",number=5, classProbs = TRUE, summaryFunction = twoClassSummary) 

set.seed(474); KNN.transscaled <- train(status~.,data=TRAIN.TRANSSCALED,method='knn',trControl=fitControl, tuneGrid=knnGrid)
#Error in na.fail.default(list(status = c(2L, 2L, 2L, 1L, 2L, 1L, 2L, 2L,  : 
#missing values in object
KNN.transscaled$bestTune
KNN.transscaled$results[rownames(KNN.transscaled$bestTune),] #0.623664 k=40

stopCluster(cluster)
registerDoSEQ()

#r crossvalidation}
fitControl <- trainControl(method="cv",number=5, verboseIter = TRUE,
                           summaryFunction = twoClassSummary, classProbs = TRUE) 

####partition model

#Set up search grid; values of cp we want to try out
rpartGrid <- expand.grid(cp=10^seq(from=-4,to=-1,length=30))
#train function
#cluster <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
#registerDoParallel(cluster)
fitControl <- trainControl(method="cv",number=5, verboseIter = TRUE,
                           summaryFunction = twoClassSummary, classProbs = TRUE, allowParallel = TRUE) 
set.seed(474); RPARTfit <- train(status~.,data=TRAIN.RAW,method="rpart",metric="ROC",trControl=fitControl,tuneGrid=rpartGrid)
#stopCluster(cluster)
#registerDoSEQ()

RPARTfit  #Look at output to see which cp was best
RPARTfit$bestTune #Gives best parameters
RPARTfit$results #Look at output in more detail (lets you see SDs)
RPARTfit$results[rownames(RPARTfit$bestTune),] #0.8735782  #not so good
plot(ROC~cp,data=RPARTfit$results,log="x")  #If tuned on AUC

RPART.predictions <- predict(RPARTfit,newdata=HOLDOUT.TO.SHARE,type="prob")



####Random Forest
require(parallel)
require(doParallel)
#Set up search grid; values of cp we want to try out
forestGrid <- expand.grid(mtry=c(1,2,3,7))
#train function
cluster <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
registerDoParallel(cluster)
fitControl <- trainControl(method="cv",number=5, verboseIter = TRUE,
                           summaryFunction = twoClassSummary, classProbs = TRUE, allowParallel = TRUE) 
set.seed(474); FORESTfit <- train(status~.,data=TRAIN.RAW,method="rf",metric="ROC",trControl=fitControl,tuneGrid=forestGrid)
stopCluster(cluster)
registerDoSEQ()

FORESTfit  #Look at output to see which cp was best
FORESTfit$bestTune #Gives best parameters
FORESTfit$results #Look at output in more detail (lets you see SDs)
FORESTfit$results[rownames(FORESTfit$bestTune),] #0.8889186
plot(ROC~mtry,data=FORESTfit$results)  #If tuned on AUC
varImp(FORESTfit)

FOREST.predictions <- predict(FORESTfit,newdata=HOLDOUT.TO.SHARE,type="prob")
write.csv(FOREST.predictions,file="Kwoods21FinalPredictions.csv",row.names = FALSE)
##What about on combined levels?
cluster <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
registerDoParallel(cluster)
fitControl <- trainControl(method="cv",number=5, verboseIter = TRUE,
                           summaryFunction = twoClassSummary, classProbs = TRUE, allowParallel = TRUE) 
set.seed(474); FORESTfit.new <- train(status~.,data=TRAIN.TRANS,method="rf",metric="ROC",trControl=fitControl,tuneGrid=forestGrid)
stopCluster(cluster)
registerDoSEQ()

#Error in randomForest.default(x, y, mtry = param$mtry, ...) : 
#  NA/NaN/Inf in foreign function call (arg 1)
#In addition: Warning message:
#  In nominalTrainWorkflow(x = x, y = y, wts = weights, info = trainInfo,  :

FORESTfit.new  #Look at output to see which cp was best
FORESTfit.new$bestTune #Gives best parameters
FORESTfit.new$results #Look at output in more detail (lets you see SDs)
FORESTfit.new$results[rownames(FORESTfit.new$bestTune),] #0.8962562
plot(ROC~mtry,data=FORESTfit.new$results)  #If tuned on AUC
varImp(FORESTfit.new)


FOREST.predictions <- predict(FORESTfit.new,newdata=HOLDOUT.TO.SHARE,type="prob")


#GLMnet--requires scaled data so that variables that run a large value range do not cause bias
seed <- 479
paramGrid <- expand.grid(.alpha = seq(0,1,.1),.lambda = 10^seq(-5,-1,length=5))  

########################################
####For parallelization (if it works)
########################################
require(parallel)
require(doParallel)
cluster <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
registerDoParallel(cluster)
fitControl <- trainControl(method="cv",number=5, verboseIter = TRUE,
                           summaryFunction = twoClassSummary, classProbs = TRUE, allowParallel = TRUE) 
set.seed(seed);  GLMnet <- train(status~.,data=TRAIN.SCALED,metric="ROC",method='glmnet', 
                                 trControl=fitControl, tuneGrid=paramGrid)
stopCluster(cluster)
registerDoSEQ()
########################################
########################################



########################################
####Nonparallel way
########################################
fitControl <- trainControl(method="cv",number=5, verboseIter = TRUE,
                           summaryFunction = twoClassSummary, classProbs = TRUE) 
set.seed(seed);  GLMnet <- train(OutcomeType~.,data=TRAIN.SCALED,metric="ROC",method='glmnet', 
                                 trControl=fitControl, tuneGrid=paramGrid)



#####See estimated ROC
GLMnet$bestTune
GLMnet$results[rownames(GLMnet$bestTune),] #0.8704536

####Make predictions
GLMnet.predictions <- predict(GLMnet,newdata=HOLDOUT.TO.SHARE,type="prob")
write.csv(GLMnet.predictions,file="Kwoods21FinalPredictions.csv",row.names = FALSE)


###What about without combining levels?

require(parallel)
require(doParallel)
cluster <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
registerDoParallel(cluster)
fitControl <- trainControl(method="cv",number=5, verboseIter = TRUE,
                           summaryFunction = twoClassSummary, classProbs = TRUE, allowParallel = TRUE) 
set.seed(seed);  GLMnet.raw <- train(status~.,data=TRAIN.TRANSSCALED,metric="ROC",method='glmnet', 
                                     trControl=fitControl, tuneGrid=paramGrid)
stopCluster(cluster)
registerDoSEQ()

GLMnet.raw$bestTune
GLMnet.raw$results[rownames(GLMnet.raw$bestTune),] #0.8704536

####Make predictions
GLMnetraw.predictions <- predict(GLMnet.raw,newdata=HOLDOUT.TO.SHARE,type="prob")


#####XGBoost
fitControl <- trainControl(method = "cv", number = 5, classProbs = TRUE, verboseIter = TRUE, returnData = FALSE)
xgboostGrid <- expand.grid(eta=0.001,nrounds=3000,
                           max_depth=c(4,6,8,10),min_child_weight=1,gamma=c(0,.1,.5,1,5,10),colsample_bytree=c(0.6,0.8,1),subsample=c(0.6,0.8,1))

#Make a copy for XGB and convert y variable into 0s and 1s (required)
TRAINXGB <- TRAIN.TRANS
TRAINXGB$status <- as.numeric(TRAINXGB$status)-1
#Convert data into sparse model matrix; the -1 is important for bookkeeping
TRAINXGB <- sparse.model.matrix(status~.-1,data=TRAINXGB)
#Expect the training to take a LONG time, potentially hours

cluster <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
registerDoParallel(cluster)

XTREME <- train(x=TRAINXGB,y=TRAIN$status,
                method="xgbTree",
                trControl=fitControl,
                tuneGrid=xgboostGrid,
                verbose=FALSE)

stopCluster(cluster)
registerDoSEQ()

XTREME$bestTune
XTREME$results[rownames(XTREME$bestTune),] 
#0.8564039
#nrounds max_depth eta gamma colsample_bytree min_child_weight subsample
#4    1000         5 0.1     0              0.8                1       0.8



#Aggregating results
#Selecting tuning parameters
#Fitting nrounds = 3000, max_depth = 10, eta = 0.001, gamma = 0.1, colsample_bytree = 0.6, min_child_weight = 1, subsample = 1 on full training set
###Make Predictions
XGBoost.predictions <- predict(XTREME,newdata=HOLDOUT.TO.SHARE,type="prob")






