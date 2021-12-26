library(data.table)
library(reshape2)
## download and unzip data files
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, "dataset.zip")
unzip(zipfile = "dataset.zip")

## Objective 2.
## setting up filters to only extract values with mean and std
## load features tabels


features <- fread("UCI HAR Dataset/features.txt",
                  col.names = c("tag", "feature_labels"))
features_mean_std_index <- grep("(mean|std)\\(\\)", features[, feature_labels])
features_mean_std <- features[features_mean_std_index,feature_labels]
features_mean_std <- gsub("[()]", "", features_mean_std)

## load train data
train <- fread("UCI HAR Dataset/train/X_train.txt")
train1 <- select(train, features_mean_std_index) 
# Objective 4: Appropriately labels the data set with descriptive variable names. 
train1 <- setnames(train1, features_mean_std)
train_activity = fread("UCI HAR Dataset/train/y_train.txt", col.names = "Activity")
train_subjects = fread("UCI HAR Dataset/train/subject_train.txt", col.names = "Subject")
## merging the subject IDs, activity codes and measurements into one data table
train1 <- cbind(train_subjects, train_activity, train1)

## load test data
test <- fread("UCI HAR Dataset/test/X_test.txt")
test1 <- select(test, features_mean_std_index) 
# Objective 4: Appropriately labels the data set with descriptive variable names. 
test1 <- setnames(test1, features_mean_std)
test_activity = fread("UCI HAR Dataset/test/y_test.txt", col.names = "Activity")
test_subjects = fread("UCI HAR Dataset/test/subject_test.txt", col.names = "Subject")
## merging the subject IDs, activity codes and measurements into one data table
test1 <- cbind(test_subjects, test_activity, test1)

## Objective 1) Merging the training data and test data to create 1 data set
combined_data <- rbind(train1, test1)

## Objective 3: Uses descriptive activity names to name the activities in the data set
## Converting activity number tags to descriptive names
## reading activity key
activity <- fread("UCI HAR Dataset/activity_labels.txt",
                  col.names = c("activity_tag", "activity"))
combined_data$Activity_description <- factor(combined_data$Activity, 
                                      levels = activity$activity_tag, 
                                      labels = activity$activity)
##ref: https://cran.r-project.org/web/packages/table1/vignettes/table1-examples.html#using-abbreviated-code-to-specify-a-custom-renderer

## Objective 5: From the data set in step 4, creates a second, independent tidy
## data set with the average of each variable for each activity and each subject.
sorted_byactivity <- melt(combined_data, id = c("Subject", "Activity_description"), measure.vars = features_mean_std)

average_activity <- dcast(sorted_byactivity, Subject + Activity_description ~ variable, mean)

write.csv(average_activity, file = "RProject_average_activity.csv", )
