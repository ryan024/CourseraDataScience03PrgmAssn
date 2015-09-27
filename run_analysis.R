### You should create one R script called run_analysis.R that does the following. 
###     1.	Merges the training and the test sets to create one data set.
###     2.	Extracts only the measurements on the mean and standard deviation 
###             for each measurement. 
###     3.	Uses descriptive activity names to name the activities in the data set
###     4.	Appropriately labels the data set with descriptive variable names. 
###     5.	From the data set in step 4, creates a second, independent tidy data 
###             set with the average of each variable for each activity and each subject.

library(dplyr)


#Pull the subject, activity label, and data files from the train folder)
trainsubject <- read.table("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train/subject_train.txt")
trainactivity <- read.table("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train/y_train.txt")
traindata <- read.table("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train/X_train.txt")

#Pull the subject, activity label, and data files from the test folder)
testsubject <- read.table("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/test/subject_test.txt")
testactivity <- read.table("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/test/y_test.txt")
testdata <- read.table("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/test/X_test.txt")

#Merge the 3 training files together: Subject in first column, activity in second column, data in rest of columns
trainingdata <- cbind(trainsubject,trainactivity,traindata)

#Merge the 3 testing files together: Subject in first column, activity in second column, data in rest of columns
testingdata <- cbind(testsubject,testactivity,testdata)

#Testing and training tables have the same number and order of columns, so merge them together to get complete 
#dataset.  Merge by binding the the tables together with rbind
mergeTestTrainData <- rbind(testingdata,trainingdata)

#Get column names for the data columns from the features.txt table
headerlist <- read.table("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/features.txt")
#Some of the column names are the same, so I'm appending the 1st and 2nd column together
headerlist <- mutate(headerlist, V3 = paste(V2,"_",V1,sep=""))
#Create a header for the table with subject as column 1, activity as column 2 and features list as rest
header <- c("subject","activity",as.character(headerlist$V3))

#Give the merged table the header
colnames(mergeTestTrainData) <- header

#Subset out the subject, activity, mean columns, and std columns
subsetMeanStd <- select(mergeTestTrainData,subject,activity,contains("mean"),contains("std"))


#subset table by activity, create new value with activity label (based on activity_labels.txt), reorder columns
walkingTable <- subsetMeanStd %>% filter(activity == 1) %>% 
                mutate(activityLabel = "WALKING") %>% 
                select(subject, activityLabel, `tBodyAcc-mean()-X_1`:`fBodyBodyGyroJerkMag-std()_543`)

upstairsTable <- subsetMeanStd %>% filter(activity == 2) %>% 
                mutate(activityLabel = "WALKING_UPSTAIRS") %>% 
                select(subject, activityLabel, `tBodyAcc-mean()-X_1`:`fBodyBodyGyroJerkMag-std()_543`)

downstairsTable <- subsetMeanStd %>% filter(activity == 3) %>% 
                mutate(activityLabel = "WALKING_DOWNSTAIRS") %>% 
                select(subject, activityLabel, `tBodyAcc-mean()-X_1`:`fBodyBodyGyroJerkMag-std()_543`)

sittingTable <- subsetMeanStd %>% filter(activity == 4) %>% 
                mutate(activityLabel = "SITTING") %>% 
                select(subject, activityLabel, `tBodyAcc-mean()-X_1`:`fBodyBodyGyroJerkMag-std()_543`)

standingTable <- subsetMeanStd %>% filter(activity == 5) %>% 
                mutate(activityLabel = "STANDING") %>% 
                select(subject, activityLabel, `tBodyAcc-mean()-X_1`:`fBodyBodyGyroJerkMag-std()_543`)

layingTable <- subsetMeanStd %>% filter(activity == 6) %>% 
                mutate(activityLabel = "LAYING") %>% 
                select(subject, activityLabel, `tBodyAcc-mean()-X_1`:`fBodyBodyGyroJerkMag-std()_543`)

#merge activity subset tables back together
mergeLabeledTable <- rbind(walkingTable,upstairsTable,downstairsTable,sittingTable,standingTable,layingTable)


#Clean up the column names by a series by substitution
#Remove ()
names(mergeLabeledTable) <- sub("(","",names(mergeLabeledTable), fixed = TRUE)
names(mergeLabeledTable) <- sub(")","",names(mergeLabeledTable), fixed = TRUE)
names(mergeLabeledTable) <- sub(")","",names(mergeLabeledTable), fixed = TRUE)
#Remove _# at the end of name
names(mergeLabeledTable) <- sub("_.*","",names(mergeLabeledTable))
#Change t at start to time
names(mergeLabeledTable) <- sub("^t","time",names(mergeLabeledTable))
#Change f at start to frequency
names(mergeLabeledTable) <- sub("^f","frequency",names(mergeLabeledTable))
#Change Acc to Accelerometer
names(mergeLabeledTable) <- sub("Acc","Accelerometer",names(mergeLabeledTable),fixed=TRUE)
#Change Gyro to Gyroscope
names(mergeLabeledTable) <- sub("Gyro","Gyroscope",names(mergeLabeledTable),fixed=TRUE)
#Change Mag to Magnitude
names(mergeLabeledTable) <- sub("Mag","Magnitude",names(mergeLabeledTable),fixed=TRUE)
#Replace , with _
names(mergeLabeledTable) <- sub(",","_",names(mergeLabeledTable),fixed=TRUE)

#Create the 2nd tidy dataset with the means by subject and activity
tidy_set <- mergeLabeledTable %>% group_by (subject,activityLabel) %>% summarize_each(funs(mean))

#Write the tidy_set out to a table
write.table(tidy_set,"./tidy_dataset.txt",row.names=FALSE)