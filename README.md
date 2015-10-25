#Readme for Getting and Cleaning Data Course Project
---
title: "run_analysis"
author: "Clint Webster"
date: "October 24, 2015"


##Overview
The run_analysis.R source file contains 2 functions:
* run_analysis - primary function to perform all steps to transform data into final summary dataset
* readSourceData - helper function used to read from source files and perform core processing of train and test source data

Source data for this project was obtained from:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

This is a direct link to the dataset used:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

##Process Details
The process takes the following steps:
1. Calls readSourceData function to process source test and train files in chunks. Processes in chunks to handle large file that are memory intensive.

2. readSourceData is called once for train data and once for test data. Train and test data sets are processed in exactly the same way:
  + Source train.txt or test.txt data file read in
  + Variable columns labelled using names in features.txt
  + Dataset pared down to only include feature variables columns related to mean and standard deviation measurements
  + Activity ID's read in from source y_test/train source files and appended to resultset
  + Subject ID's read in from source subjet_test/train source files and appended to resultset

3. Processed train and test resultsets from readSourceData steps above are combined into a single dataset

4. Dataset joins with Activity ID based control dataset to provid descriptive text for each activity

5. A final summary dataset is provided that groups by Subject and Activity. For each group the average value of each feature column is provided.  The final summary dataset is also written out to a file named 'run_analysisout.txt'

