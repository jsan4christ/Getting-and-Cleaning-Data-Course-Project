## Assignment: Getting and Cleaning Data Course Project##
library(reshape2)##Load library reshape2

filename <- "dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
      fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
      download.file(fileURL, filename) #Not using curl as it does not exist on my computer, otherwise download.file(fileURL, filename, method="curl"). 
}  
if (!file.exists("UCI HAR Dataset")) { 
      unzip(filename) 
}

# Load activity labels + features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainData <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
testData <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
combinedData <- rbind(trainData, testData)
colnames(combinedData) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
combinedData$activity <- factor(combinedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
combinedData$subject <- as.factor(combinedData$subject)

combinedData.melted <- melt(combinedData, id = c("subject", "activity"))
combinedData.mean <- dcast(combinedData.melted, subject + activity ~ variable, mean)

write.table(combinedData.mean, "tidyDataSet.txt", row.names = FALSE, quote = FALSE)