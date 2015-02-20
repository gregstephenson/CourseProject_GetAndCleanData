# CourseProject_GetAndCleanData

## Notes

* This repo produces a wide-format dataset. Each column contains a unique variable (subject, activity, ..79 mean/std variables..). Each row contains exactly one averaged record.

* Any variable expressing a mean or standard deviation is to be included due to the specification. In the real world, a 5 minute call to the client would be able to clarify exactly which fields are required. With that unavailable, it is better to over deliver than to waste the clients time sourcing additional data. 

* Activity codes are immediately converted to their string equivalents. This is to allow the dataset to be loaded with strings as factors without duplicating data.

* The merge of sets is accomplished by simply adding the Test and Train tables together, then removing duplicate entries with unique(). Testing the results against a sample of rows from the original data show every record remains in order and unique.

* Descriptive column names are added of the form Mean_Of_variable, Subject, and Activity. A full description is included in the codebook.

* Due to the use of aggregate() trying to average the activity names, the code produces warnings. This is tidied up in the following 3 lines, resulting in no corruption of the data. Existing NAs are stripped using na.rm=TRUE to prevent any numeric effect.

## Description of Code
The code is split into four functions:

* run_analysis() - This function controls the main flow of the script. The basic sequence of operation is to load the pre-existing data, merge the two sets together, remove any unnecessary variables, calculate the averages required, then output the required text file.

* ReadSubjectXY() - This function loads a set of pre-existing data (either Test or Train), and returns it as a data table. The variable names and activity labels are passed in from run_analysis(). Step 1 is to load the subject ids. Then the Activity Codes. These codes are immediately converted to their string equivalents.  Finally the numeric data is loaded. The matching dimensions allow the table to be assembled using cbind(). Descriptive column names are added.

* ExtractMeanAndStdDev() - This function searches the variable names for "mean" and "std", and returns a logical vector based on this. Any rows not containing mean or standard deviation data are then pruned from the set, reducing the number of variables from 560 to 79.

* CreateTidyDataSet() - This function uses aggregate() to average by subject and activity. Unfortunately this adds two additional columns, on for each group variable, to the set. These are removed, with their data copied into the now altered Subject and Activity fields. 