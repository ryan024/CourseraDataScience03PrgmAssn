---
title: "README"
author: "K Ryan"
date: "September 27, 2015"
---

This is an R Markdown document for the Programming Assignment. The files were downloaded from "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" directly from the website and unzipped using a Windows 7 64-bit machine.

The purpose of this assignment was to:
* Write a script called run_Analysis.R
* Write a markdown file.
* Write a codebook for the tidy dataset created by the script.

The run_Analysis.R script accomplishes the following:
* Merge the training and test sets to create one dataset
        The file downloaded from the above website had the data spread across several different files,
        in addition to the README.txt, features_info.txt and other files located in the unzipped UCI HAR Dataset
        folder there were 2 additional folders (train and test) that contained three different files.
        
        The first step to merge the 3 train data tables together into 1 trainging dataset.
        First by reading the table in:
        trainsubject <- read.table("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train/subject_train.txt")
        trainactivity <- read.table("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train/y_train.txt")
        traindata <- read.table("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train/X_train.txt")
        
        and then binding the columns together, with subject first, then activity, then the data:
        trainingdata <- cbind(trainsubject,trainactivity,traindata)
        
        The same was done for the 3 test data tables into 1 testing dataset.
        
        Since the README.txt file stated that there were different subjects in the test and train datasets the files
        were then "merged" together by using rbind.
        
        mergeTestTrainData <- rbind(testingdata,trainingdata)
        
        This gave me a dataset with 10299 rows and 563 columns.
        
* Extracts only the measurements on the mean and standard deviation for each measurement. 
        To extract the mean and standard deviation measurements I first chose to create a header file.
        The 1st column was subject and the 2nd was activity.  The rest of the columns were in the features.txt
        file in the UCI HAR Dataset folder.  Some of the column names in the features.txt file were repeated,
        so I chose to append a number at the end of the feature name.  This helped when I selected the subset.
        
        headerlist <- read.table("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/features.txt")
        headerlist <- mutate(headerlist, V3 = paste(V2,"_",V1,sep=""))
        header <- c("subject","activity",as.character(headerlist$V3))
        
        The header was then added to the merged dataset and the subject, activity, and any columns containg the
        words mean and std were subsetted out.
        
        colnames(mergeTestTrainData) <- header
        subsetMeanStd <- select(mergeTestTrainData,subject,activity,contains("mean"),contains("std"))
        
        This left a final dataset of 88 columns and 10299 rows.
        
* Uses descriptive activity names to name the activities in the data set
        
        The file activity_labels.txt gave the definition of what activity the numbers in the 2nd column referred to.
        
        I chose to subset each activity type out into its own table, created a new column with the descriptive
        activity label and select the columns I wanted, so that activity_label was still the 2nd column.
        
        An example of 1 subset:
        walkingTable <- subsetMeanStd %>% filter(activity == 1) %>% 
                mutate(activityLabel = "WALKING") %>% 
                select(subject, activityLabel, `tBodyAcc-mean()-X_1`:`fBodyBodyGyroJerkMag-std()_543`)
        
        After all 6 tables were created and relabeled, I then appended them back together using rbind:
        mergeLabeledTable <- rbind(walkingTable,upstairsTable,downstairsTable,sittingTable,standingTable,layingTable)
        
* Appropriately labels the data set with descriptive variable names.

        The header had descriptive names, but I chose to clean it up using a series of substitutions.
        
        One example: names(mergeLabeledTable) <- sub("^t","time",names(mergeLabeledTable))
        
        The substitutions I made included:
                removing (), ',', the _# that I had added
                expanding words like t and f at the start to time and frequency
                expanding Acc and Gyro to Accelerometer and Gyroscope, where the measurement came from
                expanding Mag to Magnitude

* From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

        The second dataset was created using the dplyr package:
        tidy_set <- mergeLabeledTable %>% group_by (subject,activityLabel) %>% summarize_each(funs(mean))
        First the dataset was grouped by subject and activity level and then the rest of the columns were summarized.
        
        The dataset was then written out to a text file:
        write.table(tidy_set,"./tidy_dataset.txt",row.names=FALSE)
        
        To read the dataset back in you need the following command 
        (adapted from David Hood's post: A really long advice thread)
        data <- read.table(file_path, header = TRUE)
        
One thing I did play around with, that didn't make it into the script, was downloading the zip file directly from R. The code I used:

if(!file.exists("./data/)){dir.create("./data)} #based on the professor's slides
fileURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

temp <- tempfile() #create a temporary location for the zipped contents

download.file(fileURL,temp,mode='wb')

list.files <- unzip(temp,list=TRUE) #you can list the contents, this give a numbered that can then be used to download files:

                 Name   Length                Date
1                           UCI HAR Dataset/activity_labels.txt       80 2012-10-10 15:55:00
2                                  UCI HAR Dataset/features.txt    15785 2012-10-11 13:41:00
3                             UCI HAR Dataset/features_info.txt     2809 2012-10-15 15:44:00
4                                    UCI HAR Dataset/README.txt     4453 2012-12-10 10:38:00
5                                         UCI HAR Dataset/test/        0 2012-11-29 17:01:00
6                        UCI HAR Dataset/test/Inertial Signals/        0 2012-11-29 17:01:00
7     UCI HAR Dataset/test/Inertial Signals/body_acc_x_test.txt  6041350 2012-11-29 15:08:00
8     UCI HAR Dataset/test/Inertial Signals/body_acc_y_test.txt  6041350 2012-11-29 15:08:00
9     UCI HAR Dataset/test/Inertial Signals/body_acc_z_test.txt  6041350 2012-11-29 15:08:00
10   UCI HAR Dataset/test/Inertial Signals/body_gyro_x_test.txt  6041350 2012-11-29 15:09:00
11   UCI HAR Dataset/test/Inertial Signals/body_gyro_y_test.txt  6041350 2012-11-29 15:09:00
12   UCI HAR Dataset/test/Inertial Signals/body_gyro_z_test.txt  6041350 2012-11-29 15:09:00
13   UCI HAR Dataset/test/Inertial Signals/total_acc_x_test.txt  6041350 2012-11-29 15:08:00
14   UCI HAR Dataset/test/Inertial Signals/total_acc_y_test.txt  6041350 2012-11-29 15:09:00
15   UCI HAR Dataset/test/Inertial Signals/total_acc_z_test.txt  6041350 2012-11-29 15:09:00
16                        UCI HAR Dataset/test/subject_test.txt     7934 2012-11-29 15:09:00
17                              UCI HAR Dataset/test/X_test.txt 26458166 2012-11-29 15:25:00
18                              UCI HAR Dataset/test/y_test.txt     5894 2012-11-29 15:09:00
19                                       UCI HAR Dataset/train/        0 2012-11-29 17:01:00
20                      UCI HAR Dataset/train/Inertial Signals/        0 2012-11-29 17:01:00
21  UCI HAR Dataset/train/Inertial Signals/body_acc_x_train.txt 15071600 2012-11-29 15:08:00
22  UCI HAR Dataset/train/Inertial Signals/body_acc_y_train.txt 15071600 2012-11-29 15:08:00
23  UCI HAR Dataset/train/Inertial Signals/body_acc_z_train.txt 15071600 2012-11-29 15:08:00
24 UCI HAR Dataset/train/Inertial Signals/body_gyro_x_train.txt 15071600 2012-11-29 15:09:00
25 UCI HAR Dataset/train/Inertial Signals/body_gyro_y_train.txt 15071600 2012-11-29 15:09:00
26 UCI HAR Dataset/train/Inertial Signals/body_gyro_z_train.txt 15071600 2012-11-29 15:09:00
27 UCI HAR Dataset/train/Inertial Signals/total_acc_x_train.txt 15071600 2012-11-29 15:08:00
28 UCI HAR Dataset/train/Inertial Signals/total_acc_y_train.txt 15071600 2012-11-29 15:08:00
29 UCI HAR Dataset/train/Inertial Signals/total_acc_z_train.txt 15071600 2012-11-29 15:08:00
30                      UCI HAR Dataset/train/subject_train.txt    20152 2012-11-29 15:09:00
31                            UCI HAR Dataset/train/X_train.txt 66006256 2012-11-29 15:25:00
32                            UCI HAR Dataset/train/y_train.txt    14704 2012-11-29 15:09:00

You can then pull out the data tables for test, train, and features to save to your computer.  
write.table((read.table(unz(temp, list.files$Name[31]))),"./data/X_train.txt",row.names=FALSE,col.names=FALSE)

I didn't use this in the script because I had already downloaded and unzipped the folder, and you need the README.txt and features_info.txt that can't be read in as tables.

The codebook for the final tidy dataset created in step 4 (not the dataset with the averages of the column) is included in the github repo as Codebook.md.