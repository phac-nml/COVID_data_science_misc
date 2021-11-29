######################
### To generate Sankey and the HTML output from the R markdown file
### This script calls the COVID19_assignmentThroughTime_report.Rmd to generate both the sankey and html report
### Please refer to the input settings in the Rmd file
#####################

library(rmarkdown)
require(googleVis)
require(ggplot2)
require(ggrepel)
require(dplyr)
require(here)

########
### Set your own input directory, example data is in the data folder
########
inputDir="W:/Projects/covid-19/analysis/Ongoing_Pangolin_IRIDA_Updates" ### NML only
#inputDir=here("data")


########
## acquiring folder names of pangolin results
########
timev<-dir(inputDir,pattern="^pangolin_analysis")
timevclean<-substr(gsub("pangolin_analysis_2021_","",timev),1,5) ## narrowing down to month_day

  
  ## should there be two runs on the same day, chose the later one by default
  repDates<-names(which(table(timevclean)>1))
  toskip<-sapply(repDates,function(y){ tmp<-which(y==timevclean);tmp[-length(tmp)]})
  timev<-timev[-toskip]
  timevclean<-timevclean[-toskip]


########
### select the subset of data to compare: choose one of the following, last5 is chosen by default
########
#selectT<-1:length(timev); typeselect="" # Plot all time points, no filter
#selectT<-sort(c(1,4,6,10,13,15,23)); typeselect="sampled" ## select a sub-sample
#selectT<-(length(timev)-1):length(timev); typeselect="last2" ## select the last two time points
selectT<-(length(timev)-4):length(timev); typeselect="last5" ## select the last five time points



########
## By default: the output directory is the latest pangolin output folder within your selected runs through name sorting
## You can set your own
########
outputDir=file.path(inputDir,tail(timev[selectT],1))



########
## You can choosing to show all lineages or a subset of lineages that had changes
########
# all
linFocus <- NULL;linFocusName=""
# Subset: If you only want to examine samples that have been assigned to a subset of lineages at time points selected. Use the script below
#linFocus <- c("AY.74","B.1.617.2","AY.45"); linFocusName=paste0("_",paste(linFocus,collapse="_"))


### maximum Sankey pixel in height, let this be
maxSankeyPx=5000 ## max 5000px, otherwise it's too long.

########
### run the Rmd file, saving both sankey plot and the html report in the output directory
### Please note the report is meant for all lineages and not a subset of lineages. When running a lineage subset, the html report file name has the lineages added to it.
########
render("scripts/COVID19_assignmentThroughTime_report.Rmd",output_file=paste0("COVID19_assignmentThroughTime_report_",typeselect,"_",linFocusName,".html"), output_dir = outputDir, params = list(output_dir = outputDir))

