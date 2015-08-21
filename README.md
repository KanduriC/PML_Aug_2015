# PML_Aug_2015
This repository contains the data, R code and project report for Practical Machine Learning course on Coursera.

## Background

Using devices such as Jawbone Up, Nike FuelBand, and Fitbit it is now possible to collect a large amount of data about personal activity relatively inexpensively. These type of devices are part of the quantified self movement – a group of enthusiasts who take measurements about themselves regularly to improve their health, to find patterns in their behavior, or because they are tech geeks. One thing that people regularly do is quantify how much of a particular activity they do, but they rarely quantify how well they do it. In this project, your goal will be to use data from accelerometers on the belt, forearm, arm, and dumbell of 6 participants. They were asked to perform barbell lifts correctly and incorrectly in 5 different ways. More information is available from the website here: http://groupware.les.inf.puc-rio.br/har (see the section on the Weight Lifting Exercise Dataset). 

## Data 

The training data for this project are available [here.](https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv) 
The test data are available [here.](https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv)
The data for this project come from this source: http://groupware.les.inf.puc-rio.br/har. 

## Goal

The goal of this project is to predict the manner in which they did the exercise. This is the "classe" variable in the training set. We may use any of the other variables to predict with.

## Reading data

In this project, I am going to use 'caret' package for building a predictive model. First, this package has been loaded into R and then the training and test data were read into R.

	library(caret)
	data<-read.csv('pml-training.csv', header=T)
	data_test<-read.csv('pml-testing.csv', header=T)

## Feature selection

Feature selection largely influences the training time and the model performance.  Therefore, it is crucial to retain the important features and remove the uninteresting features. Examples of such uninteresting features include those that contain lot of missing values, those that exhibit high correlation with other features (redundancy), and those with variance near zero. 

### Variables with missing values

Here, I excluded all those variables with more than 70% of missing values (NAs)

	nast<-sapply(1:ncol(data),function(i) if(sum(is.na(data[,i]))>0.7*nrow(data)){return(TRUE)}else{return(FALSE)})
	data<-data[,!nast]

### Near zero variance

All those variables with variance near zero were excluded.

	nzv <- nearZeroVar(data, saveMetrics = T)
	data<-data[,!nzv$nzv]

### Redundant features

All those fatures that exhibit high correlation (correlation coefficient > 0.70) with other features (not with the outcome variable classe) were also excluded. Also some features like the username and time-stamps that are not requred for prediction were also eliminated.

	cor_train<-cor(data.matrix(data[,1:ncol(data)-1]))
	highCorr<-findCorrelation(cor_train,0.70)
	data<-data[,-highCorr]
	data<-data[,5:ncol(data)]

## Data partition

The provided training data has been further partitioned into training and test datasets in 60:40 ratio.

	inTrain<-createDataPartition(y=data$classe, p=0.6, list=FALSE)
	training<-data[inTrain,]
	testing<-data[-inTrain,]

## Cross Validation

For cross validation, 3 repeats of 10-fold cross validation method was used while training the model. 

    train_control<-trainControl(method='repeatedcv', number=10, repeats=3, verboseIter = TRUE)

## Training the model

Due to the popularity of the higher accuracy of ensemble methods, I chose to use a widely used ensemble method, the random forests, to train the model.

	model<-train(classe~.,data=training, trControl=train_control, method='rf')

### In-sample error

	pred_train<-predict(model,newdata=training)
	confusionMatrix(pred,training$classe)
        	
        Confusion Matrix and Statistics

	          Reference
	Prediction    A    B    C    D    E
	         A 3348    0    0    0    0
	         B    0 2279    0    0    0
	         C    0    0 2054    0    0
	         D    0    0    0 1930    0
	         E    0    0    0    0 2165

	Overall Statistics
                                     
	               Accuracy : 1          
	                 95% CI : (0.9997, 1)
	    No Information Rate : 0.2843     
	    P-Value [Acc > NIR] : < 2.2e-16  
                                     
	                  Kappa : 1          
	 Mcnemar's Test P-Value : NA         

	Statistics by Class:

	                     Class: A Class: B Class: C Class: D Class: E
	Sensitivity            1.0000   1.0000   1.0000   1.0000   1.0000
	Specificity            1.0000   1.0000   1.0000   1.0000   1.0000
	Pos Pred Value         1.0000   1.0000   1.0000   1.0000   1.0000
	Neg Pred Value         1.0000   1.0000   1.0000   1.0000   1.0000
	Prevalence             0.2843   0.1935   0.1744   0.1639   0.1838
	Detection Rate         0.2843   0.1935   0.1744   0.1639   0.1838
	Detection Prevalence   0.2843   0.1935   0.1744   0.1639   0.1838
	Balanced Accuracy      1.0000   1.0000   1.0000   1.0000   1.0000

### Out-of-sample error

The trained model exhibited an accuracy of 99.67% and the estimated out of sample error rate is 0.33%.

	pred_test<-predict(model,newdata=testing)
	confusionMatrix(pred1,testing$classe)

	Confusion Matrix and Statistics

	          Reference
	Prediction    A    B    C    D    E
	         A 2229    2    0    0    0
	         B    0 1516    9    3    0
	         C    0    0 1355    5    0
	         D    1    0    4 1278    0
	         E    2    0    0    0 1442
	
	Overall Statistics
	                                          
	               Accuracy : 0.9967          
	                 95% CI : (0.9951, 0.9978)
	    No Information Rate : 0.2845          
	    P-Value [Acc > NIR] : < 2.2e-16       
 	                                         
 	                 Kappa : 0.9958          
	 Mcnemar's Test P-Value : NA              
	
	Statistics by Class:
	
	                     Class: A Class: B Class: C Class: D Class: E
	Sensitivity            0.9987   0.9987   0.9905   0.9938   1.0000
	Specificity            0.9996   0.9981   0.9992   0.9992   0.9997
	Pos Pred Value         0.9991   0.9921   0.9963   0.9961   0.9986
	Neg Pred Value         0.9995   0.9997   0.9980   0.9988   1.0000
	Prevalence             0.2845   0.1935   0.1744   0.1639   0.1838
	Detection Rate         0.2841   0.1932   0.1727   0.1629   0.1838
	Detection Prevalence   0.2843   0.1947   0.1733   0.1635   0.1840
	Balanced Accuracy      0.9991   0.9984   0.9949   0.9965   0.9998

## Prediction on test data and submission

The trained model has been used to predict the classe variable of the unknown test data with 100% accuracy. The answers have been submitted to the course webpage.

    pred_unknown<-predict(model,newdata=data_test)

    pml_write_files = function(x){
      n = length(x)
      for(i in 1:n){
        filename = paste0("problem_id_",i,".txt")
        write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
      }
    }

    pml_write_files(pred_unknown)
