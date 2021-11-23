######################
### To generate Sankey and the HTML output from the R markdown file
### This script calls the COVID19_assignmentThroughTime_report.Rmd to generate both the sankey and html report
### Please refer to the input settings in the Rmd file
#####################

library(rmarkdown)


### Set your own input directory
#inputDir="W:/Projects/covid-19/analysis/Ongoing_Pangolin_IRIDA_Updates/" ### NML only
inputDir="K:/COVID_data_science_misc/LinAssignChange/data/"


## acquiring folder names of pangolin results
timev<-dir(inputDir,pattern="^pangolin_analysis")
timevclean<-substr(gsub("pangolin_analysis_2021_","",timev),1,5) ## narrowing down to month_day


## By default: specify the output directory as the latest pangolin output folder through sorting
## You can set your own
outputDir=paste0(inputDir,tail(timev,1))

## Choosing to show all lineages that had changes
linFocus <- NULL 
### If you only want to examine samples that have been assigned to a subset of lineages at time points selected. Use the script below
#linFocus <- c("AY.74","B.1.617.2","AY.45")


### select the subset of data to compare
#selectT<-1:length(timev); typeselect="" # Plot all time points, no filter
#selectT<-sort(c(1,4,6,10,13,15,23)); typeselect="sampled" ## select a sub-sample
#selectT<-(length(timev)-1):length(timev); typeselect="last2" ## select the last two time points
selectT<-(length(timev)-4):length(timev); typeselect="last5" ## select the last five time points


### maximum Sankey pixel in height, let this be
maxSankeyPx=5000 ## max 5000px, otherwise it's too long.


### run the Rmd file, saving both sankey plot and the html report in the output directory
render("scripts/COVID19_assignmentThroughTime_report.Rmd", output_dir = outputDir, params = list(output_dir = outputDir))

