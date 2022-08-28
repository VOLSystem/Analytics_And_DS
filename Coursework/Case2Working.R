#Updated loop by: Kal Woods for BAS 279 Case 2 Fall 2017


#Initialize empty sets for the pertinent vectors
YearsIntoFuture <- c()
R2HOLDOUT <- c()
PPV <- c()
TPR <- c()


for(j in 1:15){
YearsIntoFuture[j] <- j
##New task:  Predict 2015 from years 2014 and before down to 2000
rows.with.y <- which(COMPLETE.FOREST$Year==2015)
rows.with.x <- which(COMPLETE.FOREST$Year<=(2015 - j))


##Update the code so that GUESS is a dataset for one country with years 2012 and before
#In general, the 5 in the ( 27*(i-1)+5 ) will have to change if we do year 2009 and before etc.,
#as well as the paste("Year",1:23,sep="").  You can figure it out

i <- 1
GUESS <- COMPLETE.FOREST[( 27*(i-1)+(2+j)):(27*i),]
U <- unlist(GUESS)
U <- U[-which(names(U) %in% paste("Year",1:(26-j),sep=""))]
FUTURE <- data.frame(as.list(U))

for(i in 2:227) {
  GUESS <- COMPLETE.FOREST[( 27*(i-1)+(2+j)):(27*i),]
  U <- unlist(GUESS)
  U <- U[-which(names(U) %in% paste("Year",1:(26-j),sep=""))]
  FUTURE <- rbind(FUTURE,data.frame(as.list(U)))
}

FUTURE$y <- COMPLETE.FOREST$Serv.Value[rows.with.y]
set.seed(474)
train.rows <- sample(1:nrow(FUTURE),0.6*nrow(FUTURE))
FUTURE.TRAIN <- FUTURE[train.rows,]
FUTURE.HOLDOUT <- FUTURE[-train.rows,]

FUTURE.FOREST <- randomForest(y~.,data=FUTURE.TRAIN,ntree=5000)

actual.future <- FUTURE.HOLDOUT$y
predict.future <- predict(FUTURE.FOREST,newdata=FUTURE.HOLDOUT)
plot(actual.future~predict.future)
R2HOLDOUT[j] <- cor(actual.future,predict.future )^2



##So the model appears to have a reasonable amount of predictive accuracy.
##Will it be USEFUL for predicting large increases in service percentages?  Let's explore


##Create a dataframe called NOWANDTHEN.  Each row is a country.  The Serv.Value1 is the 
##Service value from 2012 (since that is how we defined FUTURE just now) and y is the value
##from 2016.  Create a column called movement that is either "Yes" or "Nope" for whether the
##Service value in 2016 is at least 1.05 times bigger than the service value in 2012

NOWANDTHEN <- FUTURE[,c("Serv.Value1","y")]
NOWANDTHEN$movement <- factor( ifelse(NOWANDTHEN$y/NOWANDTHEN$Serv.Value1>1.05,"Yes","Nope") )

##Take out the rows that were used as training, so we can see how well we predict movement on the holdout
NOWANDTHEN <- NOWANDTHEN[-train.rows,]
##Add column called prediction that is "Yes" or "Nope" depending on whether the PREDICTED service value
##in 2015 was going to be at least 1.05 times the service level in 2014, and so on.
NOWANDTHEN$prediction <- factor( ifelse(predict.future/NOWANDTHEN$Serv.Value1>1.05,"Yes","Nope") )

##See how often actual big increases in service levels were predicted
VALUES <- table(actual=NOWANDTHEN$movement,predicted=NOWANDTHEN$prediction)
PPV[j] <- VALUES[2,2]/(VALUES[2,2]+VALUES[1,2])
TPR[j] <- VALUES[2,2]/(VALUES[2,2]+VALUES[2,1])

}

#Write all values to a new frame for easy viewing by year
PredictedValues <- data.frame(YearsIntoFuture, R2HOLDOUT, PPV, TPR)

