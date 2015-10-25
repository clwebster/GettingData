
#******************************************readSourceData*****************************************
#Author:      Clint Webster
#
#Purpose:     Processes train or test source data from: 
#             http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#             Source files are large and consume significant memory resources
#             Because of this, source files are processed in chunks of size specified.
#             Function is called during run_analysis function
#
#Input Vars:  dataset: specify either "train" or "test" to pull in related source files
#             chunksize:  specify number of source file lines to process during each iteration
#
#Return Var:  dataframe, of condensed train or test source data, return dataset contains
#             only mean and standard deviation feature columns
#             It also contains the related activity ID and subject ID values for each row
#*************************************************************************************************
readSourceData <- function(dataset, chunksize = 300){
  
  #set variables to define column widths and types for fixed with source file
  colwidths <- rep(16,561)
  coltypes <- rep("numeric",561)
  
  #file to read from
  fileName <- paste("./UCI HAR Dataset/",dataset,"/","X_",dataset,".txt",sep="")
  
  #temporary output file use to process large data file in chunks
  writeFileName <- "outtemp.txt"
  
  #get # of lines in source file
  con <- file(fileName,open = "r")
  filelen <- length(readLines(con))
  close(con)
  
  #initialize file connection in read mode
  con <- file(fileName,open = "r")
  
  #initialize loop tracking variable i
  i <- 0 
  
  #read from source file in chunks (# of lines) specified by "chunksize" function arg
  #had to take this approach to avoid consuming too much memory attempting to read large file
  while (i <= filelen){
    #read in rows from file
    tempin <- readLines(con,n=chunksize)
    
    #remove temp file if it already exists
    if (file.exists(writeFileName)) {
      file.remove(writeFileName)
    }
    
    #write to temp file
    conWrite <- file(writeFileName,open="w")
    writeLines(tempin,conWrite)
    close(conWrite)
    
    #read from temp file into dataframe
    #if not the first iteration through loop then append to dataframe
    if (i==0) {
      returnSet <- read.fwf(writeFileName,widths=colwidths,colClasses=coltypes)    
    } 
    else{
      returnSet <- rbind(returnSet,read.fwf(writeFileName,widths=colwidths,colClasses=coltypes))
    }
    
    #increment loop tracking variable by # of lines read
    i <- i+chunksize
  }
  
  close(con)
  
  #read in feature names from source file.
  features <- read.table(file="./UCI HAR Dataset/features.txt",header=FALSE,sep="")
  
  #rename colnames in returnSet to use feature names
  colnames(returnSet) <- features$V2
  
  #reduce result set to include only mean and std deviations feature columns
  #first use grep to find colnames
  meancols <- grep("-mean[(]",features$V2)
  stdcols <- grep("-std[()]",features$V2)
  colsToKeep <- c(meancols,stdcols)
  
  returnSet <- returnSet[,colsToKeep]
  
  #get activity ids for rows
  activityFile <- paste("./UCI HAR Dataset/",dataset,"/","y_",dataset,".txt",sep="")
  activities <- read.table(file=activityFile,header=FALSE,sep="")
  colnames(activities) <- c("ActivityID")
  
  #append ActivityID to data returnSet data frame
  returnSet$ActivityID <- activities$ActivityID
  
  #get subject ids for rows
  subjectFile <- paste("./UCI HAR Dataset/",dataset,"/","subject_",dataset,".txt",sep="")
  subjects <- read.table(file=subjectFile,header=FALSE,sep="")
  colnames(subjects) <- c("SubjectID")
  
  #append SubjectID to data returnSet data frame
  returnSet$SubjectID <- subjects$SubjectID
  
  return(returnSet)
}

#******************************************run_analysis*****************************************
#Author:      Clint Webster
#
#Purpose:     Processes data from: 
#             http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#             calls readSourceData to process source test and train files
#             It then combines test and train data into a single dataset
#             and joins in with an Activity control table to provide activity descriptions
#             Finally it provides a summary dataset grouped by Subject and Activity
#             For each group the average value of each feature column is provided
#
#Input Vars:  None
#
#Return Var:  Summary dataset grouped by Subject and Activity
#             For each group the average value of each feature column is provided.
#             return dataset is also written to a file named "run_analysis_out.txt"
#*************************************************************************************************
run_analysis <- function(){
  
  library(plyr)
  library(dplyr)
  
  #call function to read in both test and train source data in chunks
  linesPerChunk <- 300
  testds <- readSourceData("test", linesPerChunk)
  trainds <- readSourceData("train", linesPerChunk)
  
  #combine test and train datasets
  combined <- rbind(testds,trainds)
  
  #establish a control table for activity id values and related descriptions
  #this will allow a join in on activity ID to see related description
  actIDs <- c(1,2,3,4,5,6)
  actDescrs <- c("walking","walking upstairs","walking downstairs","sitting","standing","laying")
  activityCtl <- data.frame(actIDs,actDescrs)
  colnames(activityCtl) <- c("ActivityID","ActivityDescr")
  
  #join combined dataset with activity control table to get descrs
  combined <- join(combined,activityCtl, by="ActivityID")
  
  #group by Subject and Activity and provide the mean of each feature variable
  combGroup <- group_by(combined, SubjectID, ActivityID, ActivityDescr)
  
  combSummarized <-summarize_each(combGroup, funs(mean))
  
  #write summarized results to a table
  write.table(combSummarized, file = "run_analysis_out.txt",row.names=FALSE)
  
  return(combSummarized)
  
}
