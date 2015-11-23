# getting_cleaning_data_project
Project.
This repo is part of the Getting & Cleaning Data Project. The CodeBook file explains the steps and comments on the data.

The script, without comments is as follows:
#-----------------------
library(plyr)           
library(reshape2)     

path_2fs <- file.path("~/mypath/UCI HAR Dataset/")
setwd(path_2fs)

test_data <- read.table(file.path(path_2fs, "test/X_test.txt"))
train_data <- read.table(file.path(path_2fs, "train/X_train.txt"))
test_subjects <- read.table(file.path(path_2fs, "test/subject_test.txt"))
train_subjects <- read.table(file.path(path_2fs, "train/subject_train.txt"))
test_activity <- read.table(file.path(path_2fs, "test/y_test.txt"))
train_activity <- read.table(file.path(path_2fs, "train/y_train.txt"))
ssvar_names <- read.table(file.path(path_2fs, "features.txt"))
nameof_activity <- read.table(file.path(path_2fs, "activity_labels.txt"))

allthe_data <- rbind(test_data, train_data)
colnames(allthe_data) <- varnames_clean

allthe_subjects <- rbind(test_subjects, train_subjects)
colnames(allthe_subjects) <- "Subjects"

allthe_activities <- rbind(test_activity, train_activity)  

activities <- join(allthe_activities, nameof_activity, by = "V1", type = "left")
activities$V1 <- NULL               ## Discard the activity number (V1 column)
colnames(activities) <- "Activity"

select_cols <- grepl('mean+|std+', varnames_clean)
select_vars <- as.character(varnames_clean[select_cols])
selected_data <- allthe_data[, select_vars]

main_data <- cbind(allthe_subjects, activities, selected_data)
str(main_data)

m_main_data <- melt(main_data, 
                    id = c("Subjects", "Activity"), 
                    measure.vars = select_vars)
str(m_main_data)                        # & check it out
psubj_pact_mmeans <- dcast(m_main_data, 
                           Subjects + Activity ~ variable, 
                           mean)
str(psubj_pact_mmeans)
per_subj_act_set <- psubj_pact_mmeans[order(psubj_pact_mmeans$Subjects, 
                                               psubj_pact_mmeans$Activity),]
write.table(per_subj_act_set, 
            file = "tidy_dset.txt",
            sep="\t",
            row.names = FALSE)




