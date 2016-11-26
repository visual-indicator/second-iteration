%load filtered data set
load('participantSet.mat');

%rearrange data format for SVM
[X, Y] = trainSVM(participantSet);

%only look at the firs 18 training sets
Y = Y(1:18,:);
X = X(1:18,:);

%set trainingSetNum based on X number of rows
trainingSetNum = size(X, 1);

%train linear SVM
%Mdl = fitcecoc(X, Y);

%traing gaussian SVM
t = templateSVM('Standardize',1,'KernelFunction','gaussian');
Mdl = fitcecoc(X,Y,'Learners',t);


%%%%%%%%%%%%%%%%%%%%% #1 Alpha beta value for each channel%%%%%%%%%%%%%%%%%%%%%%%

predictedResultONE = zeros(trainingSetNum,1);

for i = 1:trainingSetNum
    predictedResultONE(i,1) = predict(Mdl, X(i,:));
end

numCorrect = 0;

for i = 1:trainingSetNum
    if(predictedResultONE(i,1) == Y(i,1))
        numCorrect = numCorrect + 1;
    end
end

accuracyRate1 = 100 * numCorrect/trainingSetNum;

%print accuracy rate
output = sprintf('Alpha and Beta for each channel: %.1f%%', accuracyRate1); 
disp(output);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #2 Left/Right alpha symmetry%%%%%&%%%%%%%%%%%%%%%

X_LR_Alpha = zeros(trainingSetNum,3);

%special for #2
for i = 1:trainingSetNum
    X_LR_Alpha(i,1) = X(i,1)-X(i,2);
    X_LR_Alpha(i,2) = X(i,3)-X(i,4);
    X_LR_Alpha(i,3) = X(i,5)-X(i,6);
end

%train SVM
Mdl = fitcecoc(X_LR_Alpha, Y);

%get training results
predictedResultTWO = zeros(trainingSetNum,1);

for i = 1:trainingSetNum
    predictedResultTWO(i,1) = predict(Mdl, X_LR_Alpha(i,:));
end

%get percentage of accuracy rate
numCorrect = 0;

for i = 1:trainingSetNum
    if(predictedResultTWO(i,1) == Y(i,1))
        numCorrect = numCorrect + 1;
    end
end

accuracyRate2 = 100 * numCorrect/trainingSetNum;

%print accuracy rate
output = sprintf('Left and right ratio for Alpha: %.1f%%', accuracyRate2); 
disp(output);

%%%%%%%%%%%%%%%%%%%%%%% #3 Left/Right frontal(fp1-fp2) alpha symmetry%%%%%%%%%%%%%%%%%%%%%%

X_LR_frontalAlpha = zeros(trainingSetNum,1);

%special for #3
for i = 1:trainingSetNum
    X_LR_frontalAlpha(i,1) = X(i,1)-X(i,2);
end

%train SVM
Mdl = fitcecoc(X_LR_frontalAlpha, Y);

%get training results
predictedResultTHREE = zeros(trainingSetNum,1);

for i = 1:trainingSetNum
    predictedResultTHREE(i,1) = predict(Mdl, X_LR_frontalAlpha(i,:));
end

%get percentage of accuracy rate
numCorrect = 0;

for i = 1:trainingSetNum
    if(predictedResultTHREE(i,1) == Y(i,1))
        numCorrect = numCorrect + 1;
    end
end

accuracyRate3 = 100 * numCorrect/trainingSetNum;

%print accuracy rate
output = sprintf('Left and right ratio for FRONTAL Alpha (fp1-fp2): %.1f%%', accuracyRate3); 
disp(output);

%%%%%%%%%%%%%%%%%%%%%%% #4 Left/Right ratio for alpha and beta%%%%%%%%%%%%%%%%%%%%%%

X_LR_AlphaBeta = zeros(trainingSetNum,6);

%special for #4
for i = 1:trainingSetNum
    X_LR_AlphaBeta(i,1) = X(i,1)-X(i,2);
    X_LR_AlphaBeta(i,2) = X(i,3)-X(i,4);
    X_LR_AlphaBeta(i,3) = X(i,5)-X(i,6);
    X_LR_AlphaBeta(i,4) = X(i,7)-X(i,8);
    X_LR_AlphaBeta(i,5) = X(i,9)-X(i,10);
    X_LR_AlphaBeta(i,6) = X(i,11)-X(i,12);
end

%train SVM
Mdl = fitcecoc(X_LR_AlphaBeta, Y);

%get training results
predictedResultFOUR = zeros(trainingSetNum,1);

for i = 1:trainingSetNum
    predictedResultFOUR(i,1) = predict(Mdl, X_LR_AlphaBeta(i,:));
end

%get percentage of accuracy rate
numCorrect = 0;

for i = 1:trainingSetNum
    if(predictedResultFOUR(i,1) == Y(i,1))
        numCorrect = numCorrect + 1;
    end
end

accuracyRate4 = 100 * numCorrect/trainingSetNum;

%print accuracy rate
output = sprintf('Left and right ratio for Alpha and Beta: %.1f%%', accuracyRate4); 
disp(output);

%%%%%%%%%%%%%%%%%%%%%%% #5 Ratio between beta and alpha for each channel%%%%%%%%%%%%%%%%%%%%%%

X_AlphaBeta = zeros(trainingSetNum,6);

%special for #5
for i = 1:trainingSetNum
    X_AlphaBeta(i,1) = X(i,7)-X(i,1);
    X_AlphaBeta(i,2) = X(i,8)-X(i,2);
    X_AlphaBeta(i,3) = X(i,9)-X(i,3);
    X_AlphaBeta(i,4) = X(i,10)-X(i,4);
    X_AlphaBeta(i,5) = X(i,11)-X(i,5);
    X_AlphaBeta(i,6) = X(i,12)-X(i,6);
end

%train SVM
Mdl = fitcecoc(X_AlphaBeta, Y);

%get training results
predictedResultFIVE = zeros(trainingSetNum,1);

for i = 1:trainingSetNum
    predictedResultFIVE(i,1) = predict(Mdl, X_AlphaBeta(i,:));
end

%get percentage of accuracy rate
numCorrect = 0;

for i = 1:trainingSetNum
    if(predictedResultFIVE(i,1) == Y(i,1))
        numCorrect = numCorrect + 1;
    end
end

accuracyRate5 = 100 * numCorrect/trainingSetNum;

%print accuracy rate
output = sprintf('Ratio between Alpha and Beta for each channel: %.1f%%', accuracyRate5); 
disp(output);