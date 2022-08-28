#Read in the data file  and explore the data
library(regclass)
KROGER <- read.csv('KrogerSpending.csv')

convert_categorical <- function(DATA,denominator=1) {
  to.convert <- which(unlist(lapply(DATA,class))=="factor")  #column numbers of categorical variables
  if(length(to.convert)==0) { return(DATA) } #nothing to be done
  for (i in to.convert) {  #loop over non-numerical columns
    formula <- as.formula( paste("~",names(DATA)[i],"-1",sep="") )  #set up formula for model.matrix
    INDICATORS <- data.frame(model.matrix(formula,data=DATA))/denominator
    DATA <- cbind(DATA,INDICATORS) #add columns for the indicator variables
  }
  DATA <- DATA[,-to.convert] #Get rid of categorical variables
}

convert_categorical(KROGER)
#Replace `KROGER` (assuming that's what you read the data in as) by first left-arrowing the result of running
#`log10(KROGER+1)` back into `KROGER` 
#1 added as logs cannot be taken at >=0
KROGER <- log10(KROGER+1) 
#Scale the data so that all means will be zero and all standard deviations will be 1
KROGERScaled <- as.data.frame(scale(KROGER))
#Check that scaling has occurred properly
apply(KROGERScaled,2,mean)
apply(KROGERScaled,2,sd)

#Is clustering appropriate?
hist(KROGERScaled$BABY)
plot(density(KROGERScaled$BABY))


#Using either k-means clustering or hierarchical clustering, consider a value of k=3.

##KMeans
KMEANS <- kmeans(KROGERScaled,center=3,iter.max=25,nstart=50)
KMEANS$centers   #Centers, average of each variable
KROGER$kmeansID <- KMEANS$cluster  #Add identity to original data
KROGERScaled$kmeansID <- KMEANS$cluster  #Add identity to scaled data
aggregate(.~kmeansID,data=KROGERScaled,FUN=median)  #Medians of each variable (trans/scaled)
aggregate(.~kmeansID,data=KROGER,FUN=median)

KROGER$kmeansID <-NULL

#Convert the (raw; i.e., unscaled and untransformed) data so that the numbers in each row give the fraction
#of money the customer spent on each category.

FRACTION <- KROGER
for(i in 1:length(KROGER)){
  for(j in 1:length(KROGER)){
    FRACTION[i,j] <- KROGER[i,j]/sum(KROGER[i,])
  }
  
}

FRACTION$OTHER <- NULL

FRACTION <- log10(FRACTION+0.01)
FRACTIONScaled <- as.data.frame(scale(FRACTION))

KMEANS <- kmeans(FRACTIONScaled,center=5,iter.max=25,nstart=50)
KMEANS$centers   #Centers, average of each variable
FRACTION$kmeansID <- KMEANS$cluster  #Add identity to original data
FRACTIONScaled$kmeansID <- KMEANS$cluster  #Add identity to original data
aggregate(.~kmeansID,data=FRACTIONScaled,FUN=median)



#complete, single, average, ward.D2 are options
HC <- hclust(dist(FRACTION),method="ward.D2")
plot(HC)

cutree(HC,k=5)
