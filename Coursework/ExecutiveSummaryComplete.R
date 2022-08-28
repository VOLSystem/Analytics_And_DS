#Finalized Executive Summary Routines
#Author: K Woods

#Note: DEMAND_ADJUSTED has NA values in the Import column set to 0

for (series in 1:144) {
  years <- 1995:2030
  par(mfrow=c(1,2))
  predictedservice <- as.numeric(SERVICE[series,])
  plot(y=predictedservice,x=years,type="l",xlab="Year",ylab="Service Percentage",ylim = c(0,1))
  
  
  lines(y=predictedservice[22:36]+0*typicalerror,x=years[22:36],col="red",lwd=3)
  lines(y=predictedservice[22:36]+2*typicalerror,x=years[22:36],col="red")
  lines(y=predictedservice[22:36]-2*typicalerror,x=years[22:36],col="red")
  title(levels(DEMAND_ORIGINAL$Country)[good.countries[series]])
  abline(v=2015)
  
  
  import.series <- DEMAND_ADJUSTED$Imports[which(DEMAND_ADJUSTED$Country==levels(DEMAND_ADJUSTED$Country)[good.countries[series]])]
  import.series <- rev(import.series)
  plot.ts(import.series, xlab = "Years from 1990", ylab = "Imports")
  par(mfrow=c(1,1))
  readline(prompt="Press Return/Enter to move onto next plot or Esc a few times to quit ")
}

#Determining change percentage in service level for all countries being evaluated
#Change <- c()
#for(i in 1:144){
#  x <- SERVICE[i,c("2015","2020")]
#  Change[i] <- ((x[1,2]- x[1,1])/x[1,1])
#}

#Evaluating based on the average Service values over a period in comparison to projection for 2020
#This yields more valuable results as it offsets abnormalities that may skew results if only considering one
#year versus an average of several years.
Change <- c()
for(i in 1:144){
  x <- SERVICE[i,c("2011":"2015","2020")]
  Change[i] <- ((x[1,6] - ((sum(x[1,1:5]))/5))/((sum(x[1,1:5]))/5))
}

#Cutoff percentage for which countries should at least be considered before looking at imports to set final criterion
ChangeEvaluate <- which(Change >= 0.05)
#extracting country names for selected countries to be considered based on imports
Consider <- row.names(SERVICE[ChangeEvaluate,])
Consider

#Countries that do not meet the change in Service value cutoff for consideration
Ignore <- row.names(SERVICE[-ChangeEvaluate,])
Ignore

#Viewing Import values for countries that make the service level change cut off
#Easy to evaluate contries that have no data available for part or all of import amounts
#Imports should be considerd both for growth and dollar values.

#Pare down to Import Values > $10k
i <- 0
Pursue <- c()
for(sub10k in 1:length(ChangeEvaluate)){
  if(max(DEMAND_ADJUSTED$Imports[which(DEMAND_ADJUSTED$Country==levels(DEMAND_ADJUSTED$Country)[good.countries[ChangeEvaluate[sub10k]]])]) >= 10000){
    i <- i + 1
    ValuedImports <- ChangeEvaluate[sub10k]  
    Pursue[i] <- row.names(SERVICE[ValuedImports,])
  }
}
#Countries that meet both the cutoff criteria for Service Change and for Imports
#Thes countries should be pursued
Pursue

#Countries to monitor that meet Service change requirements but not Import
Monitor <- row.names(SERVICE[Consider[which(  !(Consider %in% Pursue))],])
Monitor

#Visualization of Imports by country for those being considered
for(cutoff in 1:31){
  import.seriesCutoff <- DEMAND_ADJUSTED$Imports[which(DEMAND_ADJUSTED$Country==levels(DEMAND_ADJUSTED$Country)[good.countries[ChangeEvaluate[cutoff]]])]
  import.seriesCutoff <- rev(import.seriesCutoff)
  plot.ts(import.seriesCutoff, xlab = "Years from 1990", ylab = "Imports")
  title(levels(DEMAND_ADJUSTED$Country)[good.countries[ChangeEvaluate[cutoff]]])
  readline(prompt="Press Return/Enter to move onto next plot or Esc a few times to quit ")
}



#Bhutan: < 600 import values
#Brunei: 0 import data
#Burkina Faso: < 10k import values
#Central African Republic: Erratic, though showing mostly gains from 2013 on; <1000 import values
#Guinea: < 10k import values
#Indonesia: Heavy declines towards 2015, with no data available at the end
#Jamaica: < 10k import values
#Maldives: Steady increase, but low overall value maxing at 3000
#Mali: extremely heavy declines towards 2015, < 10k import values
#Mauritania: relatively stable, but low overall values ~1000
#Republic of Congo: 0 import data
#Sierra Leone: increasing, but max value < 2000
#Tajikistan: low starting values with steady climb, but peaks only reaching ~3000 range
#Tanzania: 0 import data
#Togo: mostly steady gains, but a sharp decline at the 2014-15 mark down to ~3000
#Yemen: steady increase but a sharp drop for 2014-15 to ~16000. War/bad data?
