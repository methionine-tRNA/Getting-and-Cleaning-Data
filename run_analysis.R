#loads required package
library(dplyr)

#downloads required files if necessary
if(!file.exists("UCI HAR Dataset.zip")) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "UCI HAR Dataset.zip", mode = "wb")
}

#unzips file if directory does not exist
if(!file.exists("UCI HAR Dataset")) {
  unzip("UCI HAR Dataset.zip")
}

#assigns names to training and test data
trainingsubjects <- read.table(file.path("UCI HAR Dataset", "train", "subject_train.txt"))
trainingvalues <- read.table(file.path("UCI HAR Dataset", "train", "X_train.txt"))
trainingactivities <- read.table(file.path("UCI HAR Dataset", "train", "y_train.txt"))
testsubjects <- read.table(file.path("UCI HAR Dataset", "test", "subject_test.txt"))
testvalues <- read.table(file.path("UCI HAR Dataset", "test", "X_test.txt"))
testactivities <- read.table(file.path("UCI HAR Dataset", "test", "y_test.txt"))

#assigns name to activity labels
activities <- read.table(file.path("UCI HAR Dataset", "activity_labels.txt"))

#assigns column name to activities
colnames(activities) <- c("activityid", "activitylabel")

#assigns name to features data
features <- read.table(file.path("UCI HAR Dataset", "features.txt"))

#combine the tables
training <- cbind(trainingsubjects, trainingvalues, trainingactivities)
test <- cbind(testsubjects, testvalues, testactivities)
maintable <- rbind(training, test)

#give column names to the combined table
colnames(maintable) <- c("subject", features[, 2], "activity")

#removes unnecessary columns and put data in appropriate columns
usedcolumns <- grepl("mean|sd|subject|activity", colnames(maintable))
maintable <- maintable[, usedcolumns]

#puts the names of the factors instead of the values
maintable$activity <- factor(maintable$activity, levels = activities[, 1], labels = activities[, 2])

#cleaning up untidy column names
colnames(maintable) <- gsub("^f", "frequencydomain", colnames(maintable))
colnames(maintable) <- gsub("^t", "timedomain", colnames(maintable))

#group the table by subject and activity
maintable2 <- group_by(maintable, subject, activity)

#summarize the grouped table by mean
finaltable <- summarise_each(maintable2,list(mean = mean))

#exports the table as a text file
write.table(finaltable, "tidy_data.txt", row.names = FALSE)


