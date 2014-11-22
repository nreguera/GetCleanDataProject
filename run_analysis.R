# You have to load the following libraries before running the script
# library(data.table)
# library(reshape)
# And set up working directory
# setwd("C:/Project/")

# Import the data from the files to R variables
activity_labels=read.table("./activity_labels.txt")
features=read.table("./features.txt",stringsAsFactors=FALSE)
subject_test=read.table("./subject_test.txt")
subject_train=read.table("./subject_train.txt")
X_test=read.table("./X_test.txt")
Y_test=read.table("./Y_test.txt")
X_train=read.table("./X_train.txt")
Y_train=read.table("./Y_train.txt")

# Merge train and test sets
activities=rbind(Y_test,Y_train)
values=rbind(X_test,X_train)
subjects=rbind(subject_test,subject_train)

# Set up the names of the variables we are working with
# Name the activities using descriptive activity names
activities=merge(activities,activity_labels,by.x="V1",by.y="V1",all=TRUE)
activities$V1=NULL
names(activities) <- c("Activity")
# Label the names of the features variables
features_names=as.vector(features$V2)
names(values)=features_names
# Label the subjects variable
names(subjects)=c("Subject")

# Select features variables we are interested in: mean and standard deviation
select_cols=grep("-std()|-mean()",features$V2)
# Subset columns with the previous selected variables
subset_values=values[,select_cols]

# Join activities, subjects and values of variables in a new data frame
dataset=cbind(activities,subjects)
dataset=cbind(dataset,subset_values)

# Calculating the mean of the features variables of the dataset
# Change the dataset to table class to perform lapply function
setDT(dataset)
# Applying lapply function to the dataset to calculate the mean of the features variables, group by Activity and Subject
dataset=dataset[,lapply(.SD,mean),by=list(Activity,Subject)]

# Make a tidy dataset
# Melting the dataset to transform it in a long set
# Change the data class for dataset$Subject
dataset$Subject=as.factor(dataset$Subject)
dataset=melt(dataset,id=c("Activity","Subject"))
# Appropriately label the data set with descriptive variable names
names(dataset)[3:4]=c("Measurement","Mean")

# Generate the text file from the dataset melted
write.table(dataset,file="dataset.txt",row.name=FALSE)