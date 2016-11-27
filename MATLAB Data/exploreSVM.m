%load filtered data set
load('participantSet.mat');
%load('participantSetNotNormalized.mat');
%load('normalizedByFeature.mat');
%load('normalizedByFeatureVector.mat');

%rearrange data format for SVM
%X = matrix;
%Y = classifier;

%[X, Y] = trainSVM(participantSetNotNormalized);
[X, Y] = trainSVM(participantSet);

%only look at the firs 18 training sets
%Y = Y(1:18,:);
%X = X(1:18,:);

%set trainingSetNum based on X number of rows
trainingSetNum = size(X, 1);

%if linear svm = 0;
%if gaussian svm = 1;
svm = 1;


%%%%%%%%%%%%%%%%%%%%% #1 Alpha and beta value for each channel%%%%%%%%%%%%%%%%%%%%%%%

if (svm == 0)
    %train linear SVM
    Mdl = fitcecoc(X, Y);
elseif (svm == 1)
    %traing gaussian SVM
    t = templateSVM('Standardize',1,'KernelFunction','gaussian');
    Mdl = fitcecoc(X,Y,'Learners',t);
end

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
output = sprintf('Alpha and beta value for each channel: %.1f%%', accuracyRate1); 
disp(output);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #2 Right-left alpha symmetry%%%%%&%%%%%%%%%%%%%%%

X_LR_Alpha = zeros(trainingSetNum,3);

%special for #2
for i = 1:trainingSetNum
    X_LR_Alpha(i,1) = X(i,1)-X(i,2);
    X_LR_Alpha(i,2) = X(i,3)-X(i,4);
    X_LR_Alpha(i,3) = X(i,5)-X(i,6);
end

if (svm == 0)
    %train linear SVM
    Mdl = fitcecoc(X_LR_Alpha, Y);
elseif (svm == 1)
    %traing gaussian SVM
    t = templateSVM('Standardize',1,'KernelFunction','gaussian');
    Mdl = fitcecoc(X_LR_Alpha,Y,'Learners',t);
end

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
output = sprintf('Right-left alpha symmetry: %.1f%%', accuracyRate2); 
disp(output);

%%%%%%%%%%%%%%%%%%%%%%% #3 Right-left frontal(fp1-fp2) alpha symmetry%%%%%%%%%%%%%%%%%%%%%%

X_LR_frontalAlpha = zeros(trainingSetNum,1);

%special for #3
for i = 1:trainingSetNum
    X_LR_frontalAlpha(i,1) = X(i,1)-X(i,2);
end

if (svm == 0)
    %train linear SVM
    Mdl = fitcecoc(X_LR_frontalAlpha, Y);
elseif (svm == 1)
    %traing gaussian SVM
    t = templateSVM('Standardize',1,'KernelFunction','gaussian');
    Mdl = fitcecoc(X_LR_frontalAlpha,Y,'Learners',t);
end

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
output = sprintf('Right-left FRONTAL(fp1-fp2) alpha symmetry: %.1f%%', accuracyRate3); 
disp(output);

%%%%%%%%%%%%%%%%%%%%%%% #4 Right-left ratio for both alpha and beta%%%%%%%%%%%%%%%%%%%%%%

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

if (svm == 0)
    %train linear SVM
    Mdl = fitcecoc(X_LR_AlphaBeta, Y);
elseif (svm == 1)
    %traing gaussian SVM
    t = templateSVM('Standardize',1,'KernelFunction','gaussian');
    Mdl = fitcecoc(X_LR_AlphaBeta,Y,'Learners',t);
end

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
output = sprintf('Right-left ratio for both alpha and beta: %.1f%%', accuracyRate4); 
disp(output);

%%%%%%%%%%%%%%%%%%%%%%% #5 Ratio of beta/alpha for each channel%%%%%%%%%%%%%%%%%%%%%%

X_BetaAlphaRatio = zeros(trainingSetNum,6);

%special for #5
for i = 1:trainingSetNum
    X_BetaAlphaRatio(i,1) = X(i,7)/X(i,1);
    X_BetaAlphaRatio(i,2) = X(i,8)/X(i,2);
    X_BetaAlphaRatio(i,3) = X(i,9)/X(i,3);
    X_BetaAlphaRatio(i,4) = X(i,10)/X(i,4);
    X_BetaAlphaRatio(i,5) = X(i,11)/X(i,5);
    X_BetaAlphaRatio(i,6) = X(i,12)/X(i,6);
end

if (svm == 0)
    %train linear SVM
    Mdl = fitcecoc(X_BetaAlphaRatio, Y);
elseif (svm == 1)
    %traing gaussian SVM
    t = templateSVM('Standardize',1,'KernelFunction','gaussian');
    Mdl = fitcecoc(X_BetaAlphaRatio,Y,'Learners',t);
end

%get training results
predictedResultFIVE = zeros(trainingSetNum,1);

for i = 1:trainingSetNum
    predictedResultFIVE(i,1) = predict(Mdl, X_BetaAlphaRatio(i,:));
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
output = sprintf('Ratio of beta/alpha for each channel: %.1f%%', accuracyRate5); 
disp(output);

%%%%%%%%%%%%%%%%%%%%%%% #6 Ratio of alpha/beta for each channel%%%%%%%%%%%%%%%%%%%%%%

X_AlphaBetaRatio = zeros(trainingSetNum,6);

%special for #5
for i = 1:trainingSetNum
    X_AlphaBetaRatio(i,1) = X(i,1)/X(i,7);
    X_AlphaBetaRatio(i,2) = X(i,2)/X(i,8);
    X_AlphaBetaRatio(i,3) = X(i,3)/X(i,9);
    X_AlphaBetaRatio(i,4) = X(i,4)/X(i,10);
    X_AlphaBetaRatio(i,5) = X(i,5)/X(i,11);
    X_AlphaBetaRatio(i,6) = X(i,6)/X(i,12);
end

if (svm == 0)
    %train linear SVM
    Mdl = fitcecoc(X_AlphaBetaRatio, Y);
elseif (svm == 1)
    %traing gaussian SVM
    t = templateSVM('Standardize',1,'KernelFunction','gaussian');
    Mdl = fitcecoc(X_AlphaBetaRatio,Y,'Learners',t);
end

%get training results
predictedResultSIX = zeros(trainingSetNum,1);

for i = 1:trainingSetNum
    predictedResultSIX(i,1) = predict(Mdl, X_AlphaBetaRatio(i,:));
end

%get percentage of accuracy rate
numCorrect = 0;

for i = 1:trainingSetNum
    if(predictedResultSIX(i,1) == Y(i,1))
        numCorrect = numCorrect + 1;
    end
end

accuracyRate6 = 100 * numCorrect/trainingSetNum;

%print accuracy rate
output = sprintf('Ratio of alpha/beta for each channel: %.1f%%', accuracyRate6); 
disp(output);


%%%%%%%%%%%%%%%%%%%%%%% #7 valence = ?F4/?F4-?F3/?F3 %%%%%%%%%%%%%%%%%%%%%%

X_special = zeros(trainingSetNum,1);

%special for #5
for i = 1:trainingSetNum
    X_special(i,1) = X(i,4)/X(i,10) - X(i,3)/X(i,9);
end

if (svm == 0)
    %train linear SVM
    Mdl = fitcecoc(X_special, Y);
elseif (svm == 1)
    %traing gaussian SVM
    t = templateSVM('Standardize',1,'KernelFunction','gaussian');
    Mdl = fitcecoc(X_special,Y,'Learners',t);
end

%get training results
predictedResultSeven = zeros(trainingSetNum,1);

for i = 1:trainingSetNum
    predictedResultSeven(i,1) = predict(Mdl, X_special(i,:));
end

%get percentage of accuracy rate
numCorrect = 0;

for i = 1:trainingSetNum
    if(predictedResultSeven(i,1) == Y(i,1))
        numCorrect = numCorrect + 1;
    end
end

accuracyRate7 = 100 * numCorrect/trainingSetNum;

%print accuracy rate
output = sprintf('valence = aF4/bF4-aF3/bF3: %.1f%%', accuracyRate7); 
disp(output);
