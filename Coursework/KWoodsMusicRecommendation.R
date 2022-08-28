recommend <- function(likes,TRANS,number,innovations=0,innovation.prob=0.5,min.listeners=50,max.length=5){
  RULES <- apriori(TRANS,
                   parameter = list(
                     supp=((min.listeners)/length(TRANS)),
                     conf=innovation.prob,maxlen=5),
                   appearance = list(lhs=likes,default="rhs"),
                   control=list(verbose=FALSE))
  #If there are no recommendations
  if(length(RULES)==0) {print("Sorry, we couldn't find any recommendations that you might like =(")
    stop()
  }else{
    #If recommendations are available
    #Convert RULES object into a dataframe for easier manipulation
    R <- extract_sides(RULES)
    #Make a dataframe containing the RHS of the recommendation and its level of confidence
    RECOMMENDATION <- data.frame(rhs=R$rhs,confidence=R$confidence,stringsAsFactors = FALSE)
    
    #Sort by confidence, highest up on top  (this is new compared to class)
    RECOMMENDATION <- RECOMMENDATION[order(RECOMMENDATION$confidence,decreasing=TRUE),]
    
    #Remove duplicate recommendations (many rules could recommend the same artist)
    RECOMMENDATION <- RECOMMENDATION[!duplicated(RECOMMENDATION$rhs),]
    #Remove recommendations that are bands in the listener's list of likes
    RECOMMENDATION <- subset(RECOMMENDATION,rhs %in% setdiff(RECOMMENDATION$rhs,likes ))
    
    #If there are more picks available than the number of recommendations the user would like
    #and no innovate artists are requested
    if(length(RULES) >= number & innovations==0){
      #Create a vector of the top requested number of recommendations
      top.picks <- RECOMMENDATION$rhs[1:number]
      top.picks
      
    #If there are more picks available than the number of recommendations the user would like
    #but not enough total picks to satisfy all innovative requests
    }else if(length(RULES) > number & length(RULES) < (number + innovations)){
      top.picks <- RECOMMENDATION$rhs[1:number]
      pick.prob <- (as.numeric( 1/itemFrequency(TRANS)[RECOMMENDATION$rhs[-(1:number)]] ))^2
      set.seed(479); potential.picks <- sample(RECOMMENDATION$rhs[-(1:number)],(length(RULES)-number))
      print(c(top.picks,potential.picks))
      print(paste("No additional recommendations available."))
      
    #If there are enough recommendations to return all primary and innovative artist requests
    }else if(length(RULES) > (number + innovations)){
      top.picks <- RECOMMENDATION$rhs[1:number]
      pick.prob <- (as.numeric( 1/itemFrequency(TRANS)[RECOMMENDATION$rhs[-(1:number)]] ))^2
      set.seed(479); potential.picks <- sample(RECOMMENDATION$rhs[-(1:number)],innovations)
      c(top.picks,potential.picks)
      
    #If there are fewer recommendations available than the initial number requested
    }else{
      top.picks <- RECOMMENDATION$rhs[1:length(RULES)]
      print(top.picks)
      print(paste("No additional recommendations available."))
    }
  }
  
}