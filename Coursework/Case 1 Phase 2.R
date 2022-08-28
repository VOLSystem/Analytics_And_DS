summarize_process <- function(BATCH,jobname,method = "controlchart") {
  batchtimes <- BATCH$Runtime..seconds.[which(BATCH$Batch.Job.Name==jobname)]
  
  batchtimes <- as.numeric(gsub(",","", batchtimes))
  
  #plot completed
  plot.ts(batchtimes,xlab="Job Number",ylab="Batch Times")
  
  #upper limit. Diff function gives the difference between sequential batch times
  if(method == "controlchart"){
    mr.bar <- mean( abs( diff( batchtimes)))
    UCL <- mean(batchtimes) + 2.66*mr.bar
    abline(h=UCL,col="red")
  
  #cating to the screen
    cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
    cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
    cat( paste("95% of run times are below",round(quantile(batchtimes,.95),digits = 2),"seconds \n"))
    cat( paste("Any job taking more than", round(UCL, digits = 2),"seconds signals a problem (control chart method) \n"))
  }
  
  if(method == "percentile"){
    abline(h=round(quantile(batchtimes,.95),digits = 2),col="red")
    
    cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
    cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
    cat( paste("95% of run times are below",round(quantile(batchtimes,.95),digits = 2),"seconds \n"))
    cat( paste("Any job taking more than", round(quantile(batchtimes,.95),digits = 2),"seconds signals a problem (percentile method) \n"))
  }
  
  if(method == "arma"){
    if(jobname == "Inventory Comparison MES"){
    abline(h=12.08873, col="red")
    
    cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
    cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
    cat( paste("95% of run times are below 12.09 seconds \n"))
    cat( paste("Any job taking more than 12.09 seconds signals a problem (arma method) \n"))
    
    }else if(jobname == "Inventory Comparison SAP"){
      
      abline(h=1348.057,col="red")
      
      cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
      cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
      cat( paste("95% of run times are below 1348.06 seconds \n"))
      cat( paste("Any job taking more than 1348.06 seconds signals a problem (arma method) \n"))
      
    }else if(jobname == "Pick Line Replenishment"){
      
      abline(h=2.888689,col="red")
      
      cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
      cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
      cat( paste("95% of run times are below 2.89 seconds \n"))
      cat( paste("Any job taking more than 2.89 seconds signals a problem (arma method) \n"))
      
      
    }else if(jobname == "Post Goods Issued Bogalusa Mill"){
      
      abline(h=7.073745, col="red")
      
      cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
      cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
      cat( paste("95% of run times are below 7.07 seconds \n"))
      cat( paste("Any job taking more than 7.07 seconds signals a problem (arma method) \n"))
      
    
    }else if(jobname == "Post Goods Issued Rome Mill"){
      
      abline(h=50.45265, col="red")
      
      cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
      cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
      cat( paste("95% of run times are below 50.45 seconds \n"))
      cat( paste("Any job taking more than 50.45 seconds signals a problem (arma method) \n"))
      
      
    }else if(jobname == "Process Blocked Stock"){
      
      abline(h=179.3245, col="red")
      
      cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
      cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
      cat( paste("95% of run times are below 179.32 seconds \n"))
      cat( paste("Any job taking more than 179.32 seconds signals a problem (arma method) \n"))
      
    }
    
    
    
  }
  
  
}
  

detect_issue <- function(BATCH,jobname,method = "control chart", newtime) {
  if( jobname %in% BATCH$Batch.Job.Name == FALSE) ( stop("Unknown jobname"))
  batchtimes <- BATCH$Runtime..seconds.[which(BATCH$Batch.Job.Name==jobname)]
  
  batchtimes <- as.numeric(gsub(",","", batchtimes))
  
  #plot completed
  par(mfrow=c(1,2))
  plot.ts(batchtimes,xlab="Job Number",ylab="Relative Frequency")
  legend('topleft',legend = c("CUTOFF","OBSERVED") ,lty = 1, col= c("red","blue"), cex = .5)
  
 
  if(method == "control chart"){
    #upper limit. Diff function gives the difference between sequential batch times
    mr.bar <- mean( abs( diff( batchtimes)))
    UCL <- mean(batchtimes) + 2.66*mr.bar
    abline(h=UCL,col="red")
    abline(h=newtime,col="blue")
    #histogram
    hist(batchtimes,main="",xlab = "Batch Times",ylab = "Relative Frequency", freq = FALSE)
    abline(v=newtime,col="blue")
    par(mfrow=c(1,1))
    
    #cating to the screen
    cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
    cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
    cat( paste("95% of run times are below",round(quantile(batchtimes,.95),digits = 2),"seconds \n"))
    cat( paste("Any job taking more than", round(UCL, digits = 2),"seconds signals a problem (control chart method) \n \n"))
    
      if(newtime > UCL){
        cat( paste("Issue detected:  the batch time of" ,newtime, "seconds is above the cutoff for a normal time (" ,round(UCL,digits = 2), ") \n"))
      } else{
        cat( paste("No issue with time of" ,newtime, "seconds\n"))
      }
  }else if(method =="percentile"){
    top <- round(quantile(batchtimes,.95),digits = 2)
    abline(h=top,col="red")
    abline(h=newtime,col="blue")
    #histogram
    hist(batchtimes,main="",xlab = "Batch Times",ylab = "Relative Frequency", freq = FALSE)
    abline(v=newtime,col="blue")
    par(mfrow=c(1,1))
    
    #cating to the screen
    cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
    cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
    cat( paste("95% of run times are below", top, "seconds \n"))
    cat( paste("Any job taking more than", top, "seconds signals a problem (control chart method) \n \n"))
    
    if(newtime > top){
      cat( paste("Issue detected:  the batch time of" ,newtime, "seconds is above the cutoff for a normal time (" ,top, ") \n"))
    } else{
      cat( paste("No issue with time of" ,newtime, "seconds\n"))
    }
    
    
  }else if(method == "arma"){
    
    if(jobname == "Inventory Comparison MES"){
      #the top variable is the established threshold value for each ARIMA evaluation
      top <- 12.09
      abline(h=top,col="red")
      abline(h=newtime,col="blue")
      #histogram
      hist(batchtimes,main="",xlab = "Batch Times",ylab = "Relative Frequency", freq = FALSE)
      abline(v=newtime,col="blue")
      par(mfrow=c(1,1))
      
      #cating to the screen
      cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
      cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
      cat( paste("95% of run times are below",top, "seconds \n"))
      cat( paste("Any job taking more than",top, "seconds signals a problem (control chart method) \n \n"))
      
      if(newtime > top){
        cat( paste("Issue detected:  the batch time of" ,newtime, "seconds is above the cutoff for a normal time (" ,top, ") \n"))
      } else{
        cat( paste("No issue with time of" ,newtime, "seconds\n"))
      }
      
      
    }else if(jobname == "Inventory Comparison SAP"){
      top <- 1348.06
      abline(h=top,col="red")
      abline(h=newtime,col="blue")
      #histogram
      hist(batchtimes,main="",xlab = "Batch Times",ylab = "Relative Frequency", freq = FALSE)
      abline(v=newtime,col="blue")
      par(mfrow=c(1,1))
      
      #cating to the screen
      cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
      cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
      cat( paste("95% of run times are below",top, "seconds \n"))
      cat( paste("Any job taking more than",top, "seconds signals a problem (control chart method) \n \n"))
      
      if(newtime > top){
        cat( paste("Issue detected:  the batch time of" ,newtime, "seconds is above the cutoff for a normal time (" ,top, ") \n"))
      } else{
        cat( paste("No issue with time of" ,newtime, "seconds\n"))
      }
      
      
    }else if(jobname == "Pick Line Replenishment"){
      top <- 2.89
      abline(h=top,col="red")
      abline(h=newtime,col="blue")
      #histogram
      hist(batchtimes,main="",xlab = "Batch Times",ylab = "Relative Frequency", freq = FALSE)
      abline(v=newtime,col="blue")
      par(mfrow=c(1,1))
      
      #cating to the screen
      cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
      cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
      cat( paste("95% of run times are below",top, "seconds \n"))
      cat( paste("Any job taking more than",top, "seconds signals a problem (control chart method) \n \n"))
      
      if(newtime > top){
        cat( paste("Issue detected:  the batch time of" ,newtime, "seconds is above the cutoff for a normal time (" ,top, ") \n"))
      } else{
        cat( paste("No issue with time of" ,newtime, "seconds\n"))
      }
      
    }else if(jobname =="Post Goods Issued Bogalusa Mill"){
      top <- 7.07
      abline(h=top,col="red")
      abline(h=newtime,col="blue")
      #histogram
      hist(batchtimes,main="",xlab = "Batch Times",ylab = "Relative Frequency", freq = FALSE)
      abline(v=newtime,col="blue")
      par(mfrow=c(1,1))
      
      #cating to the screen
      cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
      cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
      cat( paste("95% of run times are below",top, "seconds \n"))
      cat( paste("Any job taking more than",top, "seconds signals a problem (control chart method) \n \n"))
      
      if(newtime > top){
        cat( paste("Issue detected:  the batch time of" ,newtime, "seconds is above the cutoff for a normal time (" ,top, ") \n"))
      } else{
        cat( paste("No issue with time of" ,newtime, "seconds\n"))
      }
      
      
    }else if(jobname =="Post Goods Issued Rome Mill"){
      top <- 50.45
      abline(h=top,col="red")
      abline(h=newtime,col="blue")
      #histogram
      hist(batchtimes,main="",xlab = "Batch Times",ylab = "Relative Frequency", freq = FALSE)
      abline(v=newtime,col="blue")
      par(mfrow=c(1,1))
      
      #cating to the screen
      cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
      cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
      cat( paste("95% of run times are below",top, "seconds \n"))
      cat( paste("Any job taking more than",top, "seconds signals a problem (control chart method) \n \n"))
      
      if(newtime > top){
        cat( paste("Issue detected:  the batch time of" ,newtime, "seconds is above the cutoff for a normal time (" ,top, ") \n"))
      } else{
        cat( paste("No issue with time of" ,newtime, "seconds\n"))
      }
      
      
      
    }else if(jobname == "Process Blocked Stock" ){
    top <- 179.32
    abline(h=top,col="red")
    abline(h=newtime,col="blue")
    #histogram
    hist(batchtimes,main="",xlab = "Batch Times",ylab = "Relative Frequency", freq = FALSE)
    abline(v=newtime,col="blue")
    par(mfrow=c(1,1))
    
    #cating to the screen
    cat( paste("Expected run time is",median(batchtimes), "seconds \n"))
    cat( paste("50% of run times are between",quantile(batchtimes,.25),"and" ,quantile(batchtimes, .75),"seconds \n"))
    cat( paste("95% of run times are below",top, "seconds \n"))
    cat( paste("Any job taking more than",top, "seconds signals a problem (control chart method) \n \n"))
    
    if(newtime > top){
      cat( paste("Issue detected:  the batch time of" ,newtime, "seconds is above the cutoff for a normal time (" ,top, ") \n"))
    } else{
      cat( paste("No issue with time of" ,newtime, "seconds\n"))
    }
    
    
    
    }
  }
}






