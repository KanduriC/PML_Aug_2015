library(caret)

## Load the training data into R
data<-read.csv('pml-training.csv', header=T)
data_test<-read.csv('pml-testing.csv', header=T)

## Remove the variables that contain missing values

nast<-sapply(1:ncol(data),function(i) if(sum(is.na(data[,i]))>0.7*nrow(data)){return(TRUE)}else{return(FALSE)})
data<-data[,!nast]

## Remove the variables that have near zero variance
nzv <- nearZeroVar(data, saveMetrics = T)
data<-data[,!nzv$nzv]

## Remove variables that exhibit high correlation with other features
cor_train<-cor(data.matrix(data[,1:ncol(data)-1]))
highCorr<-findCorrelation(cor_train,0.70)
data<-data[,-highCorr]
data<-data[,5:ncol(data)]

## Partition the data into training and validation datasets
inTrain<-createDataPartition(y=data$classe, p=0.6, list=FALSE)
training<-data[inTrain,]
testing<-data[-inTrain,]

## defining training control

train_control<-trainControl(method='repeatedcv', number=10, repeats=3, verboseIter = TRUE)

## train the model

model<-train(classe~.,data=training, trControl=train_control, method='rf')

## in-sample error

pred_train<-predict(model,newdata=training)
confusionMatrix(pred,training$classe)

## out-of-sample error

pred_test<-predict(model,newdata=testing)
confusionMatrix(pred1,testing$classe)

## Prediction on unknown test data and submission to course webpage

pred_unknown<-predict(model,newdata=data_test)

pml_write_files = function(x){
  n = length(x)
  for(i in 1:n){
    filename = paste0("problem_id_",i,".txt")
    write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
  }
}

pml_write_files(pred_unknown)