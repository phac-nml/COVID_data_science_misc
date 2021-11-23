# COVID_data_science_misc
Data science scripts on COVID related things

## Reporting Pangolin COVID19 Lineage assignment changes through time 
The Pangoline lineage assignment of a sample can sometimes change through time due to creation of new lineages, changes in the PangoLEARN model, etc.
The markdown file can be called to generate the Sankey visualization of changes in Pangolin lineage assignment through time, and report top changes in counts and proportions of lineages.

** Usage **
Use scripts in assignmentchange.r to call the markdown file to generate both the Sankey plot and document report.

**Input: **

  * inputDir = the folder that stores pangolin results from different runs in sub-folders in the "pangolin_analysis_2021_month_day" format, additional characters after 'day' are skipped.
    + (Default: At NML, set the inputDir to be the following folder from Natalie Knox "W:\\Projects\\covid-19\\analysis\\Ongoing_Pangolin_IRIDA_Updates\\")
  
  * outputDir: defaulted to the latest pangolin prediction folder under inputDir
  
  * selectT = the index of the runs to plot. See script below for example
  
  * typeselect = a corresponding output name for the selectT set
  
  * linFocus = NULL 
    + if you wanted to examine changes in samples of all lineages within time points of interest. 
    + Or set linFocus = c("AY.74","B.1.617.2","AY.45") for example if you only want to examine samples that have been assigned to specific lineages. Output name will concatenate the targeted lineages.
  
  * maxSankeyPx = 5000, maximum Sankey pixel in height
  
**Output: ** Output files are saved under outputDir

  * Sankey plot
  * Plots can be seen in the COVID19_assignmentThroughTime_report.html 
