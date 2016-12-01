%load data
load('X_Lit_perFeature.mat');
load('X_Lit_perFeature.mat');

load('X_Lit_perParticipant.mat');
load('X_notLit_perParticipant.mat');

load('Y_Lit.mat');
load('Y_notLit.mat');

%sort data
X_lit_f = X_Lit_perFeature(1:12,:);
X_noLit_f = X_notLit_perFeature(1:12,:);

X_lit_p = X_Lit_perParticipant(1:12,:);
X_noLit_p = X_notLit_perParticipant(1:12,:);

Y_lit = Y_Lit(1:12,:);
Y_noLit = Y_notLit(1:12,:);

%prepare test data
X_lit_test_f = vertcat(X_Lit_perParticipant(16:18,:), X_Lit_perParticipant(22:24,:));
X_noLit_test_f = vertcat(X_notLit_perFeature(16:18,:), X_notLit_perFeature(22:24,:));

X_lit_test_p = vertcat(X_Lit_perFeature(16:18,:), X_Lit_perFeature(22:24,:));
X_noLit_test_p = vertcat(X_notLit_perParticipant(16:18,:), X_notLit_perParticipant(22:24,:));

Y_lit_test = vertcat(Y_Lit(16:18,:), Y_Lit(22:24,:));
Y_noLit_test = vertcat(Y_notLit(16:18,:), Y_notLit(22:24,:));

%train classification model
mdl_lit_f = fitclinear(X_lit_f, Y_lit, 'Learner', 'logistic');
mdl_noLit_f = fitclinear(X_noLit_f, Y_noLit, 'Learner', 'logistic');

mdl_lit_p = fitclinear(X_lit_p, Y_lit, 'Learner', 'logistic');
mdl_noLit_p = fitclinear(X_noLit_p, Y_noLit, 'Learner', 'logistic');

%prepare matrx to store predicted values
predicted_lit_f = zeros(size(X_lit_test_f, 1), 1);
predicted_noLit_f = zeros(size(X_noLit_test_f, 1), 1);

predicted_lit_p = zeros(size(X_lit_test_p, 1), 1);
predicted_noLit_p = zeros(size(X_noLit_test_p, 1), 1);

%BY FEARTURE. add column vector of 1 to test data to fit Matlab function
X_lit_test_f = [ones(size(X_lit_test_f, 1),1) X_lit_test_f(:,:)];

for i = 1:size(X_lit_test, 1)
    predicted_lit_f(i,1) = 1/(1+exp(-dot([mdl_lit_f.Bias; mdl_lit_f.Beta]', X_lit_test_f(i,:) )));
end

X_noLit_test_f = [ones(size(X_noLit_test_f, 1),1) X_noLit_test_f(:,:)];

for i = 1:size(X_noLit_test, 1)
    predicted_noLit_f(i,1) = 1/(1+exp(-dot([mdl_noLit_f.Bias; mdl_noLit_f.Beta]', X_noLit_test_f(i,:))));
end

%BY PARTICIPANT. add column vector of 1 to test data to fit Matlab function
X_lit_test_p = [ones(size(X_lit_test_p, 1),1) X_lit_test_p(:,:)];

for i = 1:size(X_lit_test, 1)
    predicted_lit_p(i,1) = 1/(1+exp(-dot([mdl_lit_p.Bias; mdl_lit_p.Beta]', X_lit_test_p(i,:) )));
end

X_noLit_test_p = [ones(size(X_noLit_test_p, 1),1) X_noLit_test_p(:,:)];

for i = 1:size(X_noLit_test, 1)
    predicted_noLit_p(i,1) = 1/(1+exp(-dot([mdl_noLit_p.Bias; mdl_noLit_p.Beta]', X_noLit_test_f(i,:))));
end


%take average of both set of predicted values and compare the two
disp('Data normalized by feature data:');
if (mean(predicted_lit_f) < mean(predicted_noLit_f))
    disp('Emotional responsed to video with green LED lights yields higher valence response to video without green LED lights');
    output = sprintf('With lights is %.4f%% and wihtout lights is %.4f%%', mean(predicted_lit_f), mean(predicted_noLit_f));
    disp(output);
elseif(mean(predicted_lit_f) > mean(predicted_noLit_f))
    disp('Emotional responsed to video without green LED lights yields higher valence response to video with green LED lights');
    output = sprintf('With lights is %.4f%% and wihtout lights is %.4f%%', mean(predicted_lit_f), mean(predicted_noLit_f));
    disp(output);
else
    disp('Average of emotional response to video with green LED lights and without green LED lights yield the same value');
end


disp('Data normalized by participant:');
if (mean(predicted_lit_p) < mean(predicted_noLit_p))
    disp('Emotional responsed to video with green LED lights yields higher valence response to video without green LED lights');
    output = sprintf('With lights is %.4f%% and without lights is %.4f%%', mean(predicted_lit_p), mean(predicted_noLit_p));
    disp(output);
elseif(mean(predicted_lit_p) > mean(predicted_noLit_p))
    disp('Data emotional responsed to video without green LED lights yields higher valence response to video with green LED lights');
    output = sprintf('With lights is %.4f%% and without lights is %.4f%%', mean(predicted_lit_p), mean(predicted_noLit_p));
    disp(output);
else
    disp('Average of emotional response to video with green LED lights and without green LED lights yield the same value');
end
    