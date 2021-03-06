#!/usr/bin/env Rscript
require(gridExtra)
require(ggplot2)

histfunc <- function() {
  datafile <- '/Users/frbl/vault/Datasets/HoeGekIsNL/Diary_v1/mad_diary_2014-12-13.csv'
  dataset = read.csv(datafile, sep=';')
  
  # Convert to the correct format
  dataset$mad_diary_completed_at<-strptime(dataset$mad_diary_completed_at, "%d-%m-%Y %H:%M:%S")
  dataset$mad_diary_invited_at<-strptime(dataset$mad_diary_invited_at, "%d-%m-%Y %H:%M:%S")
  dataset$mad_diary_started_at<-strptime(dataset$mad_diary_started_at, "%d-%m-%Y %H:%M:%S")
  
  # Calculate the difference
  dataset$completed_at_invited_at <- unclass(difftime(dataset$mad_diary_completed_at, dataset$mad_diary_invited_at, units="secs"))
  dataset$started_at_invited_at <- unclass(difftime(dataset$mad_diary_started_at, dataset$mad_diary_invited_at, units="secs"))
  dataset$completed_at_started_at <- unclass(difftime(dataset$mad_diary_completed_at, dataset$mad_diary_started_at, units="secs"))
  
  # Test is the set is a subset
  are_subsets <- all((!is.na(dataset$started_at_invited_at) & !is.na(dataset$completed_at_invited_at)) == !is.na(dataset$started_at_invited_at))
  are_subsets <- are_subsets && all((!is.na(dataset$completed_at_started_at) & !is.na(dataset$completed_at_invited_at)) == !is.na(dataset$completed_at_started_at)) == TRUE
  
  if(are_subsets) {
    # Remove all measurements > 1 hour, and convert to minutes
    started_at_invited_at <- subset(dataset$started_at_invited_at, dataset$completed_at_invited_at < 3600)/60
    completed_at_started_at <- subset(dataset$completed_at_started_at, dataset$completed_at_invited_at < 3600)/60
    completed_at_invited_at <- subset(dataset$completed_at_invited_at, dataset$completed_at_invited_at < 3600)/60
    
    # Remove NA
    completed_at_invited_at <- completed_at_invited_at[!is.na(completed_at_invited_at)]
    started_at_invited_at <- started_at_invited_at[!is.na(started_at_invited_at)]
    completed_at_started_at <- completed_at_started_at[!is.na(completed_at_started_at)]
    
    if(all(completed_at_invited_at > 0) &&
          all(started_at_invited_at > 0) &&
          all(completed_at_started_at > 0)){
      print('All date differences are positive')
    }
    
    printstats(completed_at_invited_at, 'completed_at_invited_at')
    printstats(started_at_invited_at, 'started_at_invited_at')
    printstats(completed_at_started_at, 'completed_at_started_at')
    

    x_data <- c(started_at_invited_at,
                completed_at_started_at,
                completed_at_invited_at)

    y_data <- c(rep('started_at_invited_at', length(started_at_invited_at)), 
                rep('completed_at_started_at', length(completed_at_started_at)), 
                rep('completed_at_invited_at', length(completed_at_invited_at)))

    x_data <- c(completed_at_started_at)
    y_data <- rep('completed_at_started_at', length(completed_at_started_at))

    dat <- data.frame(xx = x_data,
                      yy = y_data)

    margin <- 50
    p3 <- ggplot(dat, aes(x=xx)) + 
            geom_histogram(data = subset(dat,yy='completed_at_started_at'), 
                            breaks=seq(0, 0+18, by = 0.5), col='black', fill="#5E81AC") + 
                            #breaks=seq(0, 0+18, by = 0.5), col='black', fill="#CC6677") + 
            theme(panel.background = element_rect(fill = 'transparent', colour = 'black', size=1)) +
            theme(axis.text.y = element_text(colour = "black") ) +
            labs(x="Time in minutes", y="Frequency") +
            #theme( plot.margin = unit( c(0.1,0.1,0.1,0.1) , "in" ) )+
            scale_y_continuous(limits = c(-30,1550 + margin), expand = c(0, 0)) +
            scale_x_continuous( expand = c(0.01, 0)) +
            theme(axis.text.x = element_text(colour = "black") ) +
            theme(axis.title.x = element_text(vjust = -0.5)) +
            theme(legend.title = element_blank())+
            theme(legend.position="bottom")+
            theme(legend.background = element_rect(colour="transparent"))+
            theme(legend.key = element_rect(fill = "transparent", colour = "transparent")) +
            theme(legend.key.size= unit(3,"lines"))
    p3
  }
}

printstats <- function(dataset, name) {
  print(name)
  print('Mean:')
  print(mean(dataset))
  print('STDev:')
  print(sd(dataset))
  print('Median:')
  print(median(dataset))
  print('Range:')
  print(range(dataset))
  print('')
}
pdf(file = "time-to-complete-questionnaire-in-hgi.pdf", width=5, height=3)
plot(histfunc())
dev.off()

tikzDevice::tikz('time-to-complete-questionnaire-in-hgi.tex', standAlone = FALSE, width=5, height=3)
plot(histfunc())
dev.off()

