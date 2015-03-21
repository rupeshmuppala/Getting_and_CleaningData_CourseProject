## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Load: data column names
allFeatures <- read.table("./UCI HAR Dataset/features.txt")[,2]


# Load: activity labels
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Extract only the mean and standard deviation columns from the features vector.
  mean_std_Features <- grepl("mean|std", allFeatures)

# Load and process X_train & y_train data.
xTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")

subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(xTrain) = allFeatures

# Extract only the mean and standard deviation measurements of train data.
xTrain = xTrain[,mean_std_Features]

# Adding volunteer activity labels to yTrain
yTrain[,2] = activityLabels[yTrain[,1]]
names(yTrain) = c("Volunteer_Activity_ID", "Volunteer_Activity_Name")
names(subjectTrain) = "Subject"

# Bind train data
trainData <- cbind(as.data.table(subjectTrain), yTrain, xTrain)


# Load and process X_test & y_test data.
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
xTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./UCI HAR Dataset/test/y_test.txt")


names(xTest) = allFeatures

# Extract only the mean and standard deviation measurements of test data.
xTest = xTest[,mean_std_Features]

# Adding volunteer activity labels to yTest
yTest[,2] = activityLabels[yTest[,1]]
names(yTest) = c("Volunteer_Activity_ID", "Volunteer_Activity_Name")
names(subjectTest) = "Subject"

# Bind test data
testData <- cbind(as.data.table(subjectTest), yTest, xTest)

# Merge test and train data
mergeData = rbind(testData, trainData)

subjectActivities   = c("Subject", "Volunteer_Activity_ID", "Volunteer_Activity_Name")
dataLabels = setdiff(colnames(mergeData), subjectActivities)
meltData      = melt(mergeData, id = subjectActivities, measure.vars = dataLabels)

# Apply mean function to dataset using dcast function
tidyData   = dcast(meltData, Subject + Volunteer_Activity_Name ~ variable, mean)

write.table(tidyData, file = "./tidy_data.txt",row.names=FALSE)
