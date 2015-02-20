ReadSubjectXY <- function(directory, set, activityNames, measurementHeaders){
    
    # Read in subject list, name column 'Sunject'
    subjectFile = file.path(directory, paste("subject_", set, ".txt", sep=""), sep="")
    dt_Subject <- data.table(read.table(subjectFile, stringsAsFactors=FALSE))
    setnames(dt_Subject, "V1", "Subject")
    dt_Subject$Subject <- as.numeric(dt_Subject$Subject) 
    
    # Read in Y file, replace number with description to allow reading in strings as factors
    YFile = file.path(directory, paste("y_", set, ".txt", sep=""), sep="")
    dt_Y <- data.table(read.table(YFile, stringsAsFactors=FALSE))
    setnames(dt_Y, "V1", "Activity")
    for(i in seq_along(dt_Y$Activity)){
        strin <- as.numeric(dt_Y$Activity[i])
        dt_Y$Activity[i] <- activityNames$V2[strin]
    }
    
    ## Load in the actual data
    XFile = file.path(directory, paste("X_", set, ".txt", sep=""), sep="")
    dt_X <- data.table(read.table(XFile, stringsAsFactors=FALSE))
    setnames(dt_X, measurementHeaders$V2)
    
    ## Glue it all together
    tableOut = cbind(dt_Subject, dt_Y, dt_X)##, origDataSet)
    tableOut
}

## Extract data relating to mean and std-dev of measurements
ExtractMeanAndStddev <- function(mergedData){
    testVector <- colnames(mergedData)
    ismean <- grepl("mean", testVector, fixed=TRUE)
    isstd <- grepl("std", testVector, fixed=TRUE)
    ## Make sure subject and activity remain
    ismean[1] <- TRUE
    ismean[2] <- TRUE
    
    ## Cull the weak
    cullVector <- logical(length(ismean))
    for(i in seq_along(ismean)){
        cullVector[i] <- ismean[i] || isstd[i]
    }
    prunedData <- subset(mergedData, select=cullVector)
    prunedData
}   

CreateTidyDataSet <- function(prunedData){
    ## Summarise the data by averaging across subject and activity
    tidyDataTable <- aggregate(prunedData, list(prunedData$Subject,prunedData$Activity), FUN=mean, na.rm=TRUE)
    tidyDataTable$Subject <- tidyDataTable$Group.1
    tidyDataTable$Activity <- tidyDataTable$Group.2
    numCols <- ncol(tidyDataTable)
    tidyDataTable <- tidyDataTable[,3:numCols]  
    numCols <- ncol(tidyDataTable)
    
    ## Add Descriptive Column Names
    colVector <- colnames(tidyDataTable)
    for(i in 3:81){
        colVector[i] <- paste("Mean_Of_", colVector[i], sep="")
    }
    setnames(tidyDataTable, colVector)
    
    ## Sort by Subject then Activity
    tidyDataTable <- tidyDataTable[order(tidyDataTable$Subject, tidyDataTable$Activity),]
    
    tidyDataTable
}

run_analysis <- function(){
    library(data.table)
    
    ## LOAD THE DATA FROM TEST AND TRAIN DATASETS
    dataDir <- "UCI HAR Dataset"
    
    featuresFile <- file.path(dataDir, "/", "features.txt", fsep = "")
    features <- data.table(read.table(featuresFile, stringsAsFactors=FALSE))
    activityFile <- file.path(dataDir, "/", "activity_labels.txt", fsep = "")
    activityLabels <- data.table(read.table(activityFile, stringsAsFactors=FALSE))
    
    directory <- file.path(dataDir, "/", "test", "/")
    dt_Test <- ReadSubjectXY(directory, "test", activityLabels, features)
    directory <- file.path(dataDir, "/", "train", "/")
    dt_Train <- ReadSubjectXY(directory, "train", activityLabels, features)
    
    ## MERGE TABLES TOGETHER
    mergedData <- rbind(dt_Test, dt_Train)
    mergedData <- unique(mergedData)
    
    ## Filter out any non mean or stdDev type variables
    prunedData <- ExtractMeanAndStddev(mergedData)
    
    ##Free up some memory
    dt_Test <- 0
    dt_Train <- 0
    mergedData <- 0
    
    ## Create the tidy Data Set with Descriptive Column Names
    tidyDataSet <- CreateTidyDataSet(prunedData)
    ##tidyDataSet - Use to produce the dataset in R
    
    ## Output required file
    write.table(tidyDataSet, "smartPhoneAccelData.txt", row.names=FALSE, sep=" ")
}