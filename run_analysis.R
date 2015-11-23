## GETTING & CLEANING DATA. Project.
#  November 22, 2015

##======================================================================

## Load packages:
 
library(plyr)           
library(reshape2)       

## Establish a path to files & set it up as the working directory:

path_2fs <- file.path("~/Desktop/_COURSES/_DATA_SCIENCE/_C-3_Getting_Cleaning_Data/Project/UCI HAR Dataset/")
setwd(path_2fs)

#---------------------------------------
## Files:

#A) DATA (summary statistics on measurements of 30 subjects, total):
#   - X_test.txt (acceleration & angular velocities on 9 test subjects)
#   - X_train.txt (acceleration & angular velocities on 21 training subjects)

#B) FACTORS (categorical data about subjects & activities):
#   - subject_test.txt (row labels for 9 test subjects)
#   - subject_train.txt (row labels for 21 training subjects)
#   - y_test.txt (row labels for 6 activities of test subjects)
#   - y_train.txt (row labels for 6 activities of training subjects)

#C) LABELS (names & tags):
#   - features.txt (variable names for summary statistics for all observations)
#   - activity_labels.txt (actual names for the six factorial activities)
#---------------------------------------

## Read files into R from above:

test_data <- read.table(file.path(path_2fs, "test/X_test.txt"))
train_data <- read.table(file.path(path_2fs, "train/X_train.txt"))
test_subjects <- read.table(file.path(path_2fs, "test/subject_test.txt"))
train_subjects <- read.table(file.path(path_2fs, "train/subject_train.txt"))
test_activity <- read.table(file.path(path_2fs, "test/y_test.txt"))
train_activity <- read.table(file.path(path_2fs, "train/y_train.txt"))
ssvar_names <- read.table(file.path(path_2fs, "features.txt"))
nameof_activity <- read.table(file.path(path_2fs, "activity_labels.txt"))
#---------------------------------------

# Clean up the variable names ("features"); i.e., no parenthesis, etc.
# (These names are very informative, no further cleaning necessary)

varnames_clean <- gsub("[()]", "", ssvar_names$V2)

#---------------------------------------

## Merge the two sets of data & factors(for test & training) into single data 
#  frames that will be combined later to form the main data frame, and add 
#  column (variable) names to them:

allthe_data <- rbind(test_data, train_data)
colnames(allthe_data) <- varnames_clean

allthe_subjects <- rbind(test_subjects, train_subjects)
colnames(allthe_subjects) <- "Subjects"

allthe_activities <- rbind(test_activity, train_activity)  
#Name its variable later
#---------------------------------------

## Substitute "allthe_activities" data from numbers to actual names 
#  & make it into a single-column data frame:

activities <- join(allthe_activities, nameof_activity, by = "V1", type = "left")
activities$V1 <- NULL               ## Discard the activity number (V1 column)
colnames(activities) <- "Activity"
#---------------------------------------

## Select the means and standard deviation variables (columns) from the data:
#  This is done by filtering the variable names in the "features.txt" data, now
#  "ssvar_names"

# Make a logical vector to locate strings matching to "mean" & "std":
select_cols <- grepl('mean+|std+', varnames_clean)

# Create the vector of names with the new selected variable (column) names:
select_vars <- as.character(varnames_clean[select_cols])

## Select the data from "allthe_data", based on these variable names selected:
selected_data <- allthe_data[, select_vars]
#---------------------------------------

## Combine the selected data with its factors (Subjects & Activity) into a single
#  data frame:

main_data <- cbind(allthe_subjects, activities, selected_data)
str(main_data)
#---------------------------------------

## Finally, reshape the data into a "tidy" dataset from which to obtain the
#  average of each variable for each activity and each subject:

#Melt the main_data set:
m_main_data <- melt(main_data, 
                    id = c("Subjects", "Activity"), 
                    measure.vars = select_vars)
str(m_main_data)                        # & check it out

#------------------------------ (This is not necessary but informative)-----
## Compute the mean of means for each subject,
subject_mmeans <- dcast(m_main_data, 
                        Subjects ~ variable, mean)

str(subject_mmeans)                     # & check it out

## Compute the mean of means for each Activity,
activity_mmeans <- dcast(m_main_data, 
                        Activity ~ variable, mean)

str(activity_mmeans)                    # & check it out
#----------------------------------------------------------------------------
## Compute the mean of means for each subject and each activity:

psubj_pact_mmeans <- dcast(m_main_data, 
                           Subjects + Activity ~ variable, 
                           mean)
str(psubj_pact_mmeans)

#Reorder by Subjects and Activity
per_subj_act_set <- psubj_pact_mmeans[order(psubj_pact_mmeans$Subjects, 
                                               psubj_pact_mmeans$Activity),]

head(per_subj_act_set, 12L)

## Output to "tidy" dataset file:

write.table(per_subj_act_set, 
            file = "tidy_dset.txt",
            sep="\t",
            row.names = FALSE)

#================================== FIN ================================


















