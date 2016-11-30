%load files amanda has
%3 happy and 3 baseline for two participant for each lit and not lit
%to do, if use
load('X_Lit.mat');
load('Y_Lit.mat');
load('X_notLit.mat');
load('Y_notLit.mat');


%X_noLit;
%Y_noLit;

X_lit = X_Lit(1:12,:);
Y_lit = Y_Lit(1:12,:);
X_noLit = X_notLit(1:12,:);
Y_noLit = Y_notLit(1:12,:);

X_lit_test = vertcat(X_Lit(17:18,:), X_Lit(22:24,:));
Y_lit_test = vertcat(X_Lit(17:18,:), X_Lit(22:24,:));
X_noLit_test = vertcat(X_notLit(17:18,:), X_notLit(22:24,:));
Y_noLit_test = vertcat(Y_notLit(17:18,:), Y_notLit(22:24,:));

mdl_lit = fitclinear(X_lit, Y_lit, 'Learner', 'logistic');
mdl_noLit = fitclinear(X_noLit, Y_noLit, 'Learner', 'logistic');

%load experiment participant value and predict it using model
%testSet_lit
%testSet_noLit

%predict numerical value;

predicted_lit = zeros(size(X_lit_test, 1), 1);
predicted_lit_dis = zeros(size(X_lit_test, 1), 1);
predicted_noLit = zeros(size(X_noLit_test, 1), 3);
predicted_noLit_dis = zeros(size(X_noLit_test, 1), 3);

%%%%%%%%%%%%%%%%%depending on which one we want%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X_lit_test_a = [ones(size(X_lit_test, 1),1) X_lit_test(:,:)];

for i = 1:size(X_lit_test, 1)
    predicted_lit(i,1) = 1/(1+exp(-dot([mdl_lit.Bias; mdl_lit.Beta]', X_lit_test_a(i,:) )));
    predicted_lit_dis(i,1) = predict(mdl_lit, X_lit_test(i,:));
end

X_noLit_test_a = [ones(size(X_noLit_test, 1),1) X_noLit_test(:,:)];

for i = 1:size(X_noLit_test, 1)
    predicted_noLit(i,1) = 1/(1+exp(-dot([mdl_noLit.Bias; mdl_noLit.Beta]', X_noLit_test_a(i,:))));
    predicted_noLit_dis(i,1) = predict(mdl_noLit, X_noLit_test(i,:));
end



%take average of both set of predicted values and compare the two
if (mean(predicted_lit) < mean(predicted_noLit))
    disp('lit yields happier results than not lit');
    output = sprintf('lit is %.1f%% and no lit is %.1f%%', mean(predicted_lit), mean(predicted_noLit));
    disp(output);
elseif(mean(predicted_lit) > mean(predicted_noLit))
    disp('no lit yields happier results than lit');
    output = sprintf('lit is %.1f%% and no lit is %.1f%%', mean(predicted_lit), mean(predicted_noLit));
    disp(output);
end

    