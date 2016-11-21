function [ unclassifiedX, Y ] = Fir_iter_OneParticipant( EEG )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%%% Event codes %%%

NEUTRAL      = 2;
HAPPY        = 1;
SAD          = 3;

%%% Constants and Input Data %%%

alphaData   = EEG(1).data;      % Alpha activity from all trials
betaData    = EEG(2).data;      % Beta activity from all trials
data        = EEG(1:2).data;    % Alpha and Beta activity from all trials
events      = EEG(1).event.type;% Events from data set
nEpochs     = size(events,2);   % Declare the number of epochs
nSamples    = size(betaData,2); % Declare the number of samples in each trial
nChannels   = size(betaData,1); % Declare the number of channels used
nBands      = 2;
% TEMPORARY: allows us to only deal with ONE of each color
%numEpochs = 5;

temp = zeros(2,6,2500);         

%p1      = struct('data', [], 'unclassified', []); 
rawData = struct('trainingSet1', temp, 'trainingSet2', temp, 'trainingSet3', temp, 'trainingSet4', temp, 'trainingSet5', temp, 'trainingSet6', temp, 'trainingSet7', temp, 'trainingSet8', temp, 'trainingSet9', temp);

%%% Create Person Struct %%%

rawData.trainingSet1(1,:,:) = alphaData(:,:,1);
rawData.trainingSet1(2,:,:) = EEG(2).data(:,:,1);
rawData.trainingSet2(1,:,:) = EEG(1).data(:,:,2);
rawData.trainingSet2(2,:,:) = EEG(2).data(:,:,2);
rawData.trainingSet3(1,:,:) = EEG(1).data(:,:,3);
rawData.trainingSet3(2,:,:) = EEG(2).data(:,:,3);
rawData.trainingSet4(1,:,:) = EEG(1).data(:,:,4);
rawData.trainingSet4(2,:,:) = EEG(2).data(:,:,4);
rawData.trainingSet5(1,:,:) = EEG(1).data(:,:,5);
rawData.trainingSet5(2,:,:) = EEG(2).data(:,:,5);
rawData.trainingSet6(1,:,:) = EEG(1).data(:,:,6);
rawData.trainingSet6(2,:,:) = EEG(2).data(:,:,6);
rawData.trainingSet7(1,:,:) = EEG(1).data(:,:,7);
rawData.trainingSet7(2,:,:) = EEG(2).data(:,:,7);
rawData.trainingSet8(1,:,:) = EEG(1).data(:,:,8);
rawData.trainingSet8(2,:,:) = EEG(2).data(:,:,8);
rawData.trainingSet9(1,:,:) = EEG(1).data(:,:,9);
rawData.trainingSet9(2,:,:) = EEG(2).data(:,:,9);

%p1.data = rawData;

%%% Process Each Trial %%%

temp = zeros(2,6);
unclassified = struct('trainingSet1', temp, 'trainingSet2', temp, 'trainingSet3', temp, 'trainingSet4', temp, 'trainingSet5', temp, 'trainingSet6', temp, 'trainingSet7', temp, 'trainingSet8', temp, 'trainingSet9', temp);

%rawData(for each)
for i = 1:9
    unclassified(i) = getSumPSD(rawData(i));
end


% normalize data - look at it LATER

normalized = normalize(unclassified);

unclassifiedX = zeros(size(events, 1), numel(normalized.trainingSet1)); 

unclassifiedX(1,:) = [ normalized.trainingSet1(1,:) normalized.trainingSet1(2,:) ];
unclassifiedX(2,:) = [ normalized.trainingSet2(1,:) normalized.trainingSet1(2,:) ];
unclassifiedX(3,:) = [ normalized.trainingSet3(1,:) normalized.trainingSet1(2,:) ];
unclassifiedX(4,:) = [ normalized.trainingSet4(1,:) normalized.trainingSet1(2,:) ];
unclassifiedX(5,:) = [ normalized.trainingSet5(1,:) normalized.trainingSet1(2,:) ];
unclassifiedX(6,:) = [ normalized.trainingSet6(1,:) normalized.trainingSet1(2,:) ];
unclassifiedX(7,:) = [ normalized.trainingSet7(1,:) normalized.trainingSet1(2,:) ];
unclassifiedX(8,:) = [ normalized.trainingSet8(1,:) normalized.trainingSet1(2,:) ];
unclassifiedX(9,:) = [ normalized.trainingSet9(1,:) normalized.trainingSet1(2,:) ];
        
Y = zeros(size(events, 1), 1);

%convert events to int to Y
for i = 1:size(events,1)
    Y(i) = str2double(events(i,1));
end

end


%%
function [ PSD ] = getSumPSD( data )

PSD = zeros(2,6);           % Will hold the sums of psd's for each (band, channel)

% Alpha 
for j = 1:6
    pxx = log(pwelch(data(1,j,:), 250));
    pxx = pxx(8:13);
    PSD(1,j) = sum(pxx);
end

% Beta
for j = 1:6
    pxx = log(pwelch(data(2,j,:), 250));
    pxx = pxx(13:29);
    PSD(2,j) = sum(pxx);
end

end


%%
function [ unclassified ] = normalize ( unclassified )

colors              = fieldnames(unclassified);
[nBands, nChans]    = size (unclassified.(colors{1}));
nColors             = numel (colors);
valsPerColor        = nBands * nChans;

matrix = zeros(nColors * valsPerColor, 1);

% unfold data
for i = 1:nColors
    front   = (i - 1) * valsPerColor + 1;
    back    = (i) * valsPerColor;
    
    matrix(front:back) = reshape(unclassified.(colors{1}), valsPerColor, 1);
end

matrix_normalized = normalize_1D (matrix);

% fold data back up
for i = 1:nColors
    front   = (i - 1) * valsPerColor + 1;
    back    = (i) * valsPerColor;
    
    temp    = matrix_normalized(front:back);
    unclassified.(colors{i}) = reshape(temp, nBands, nChans);
end

end


%% 
function [ matrix_normalized ] = normalize_1D ( matrix ) 

matrix_normalized = zeros(size(matrix, 1), 1);

min = matrix(1,1);
max = matrix(1,1);

%get min
for i = 2:size(matrix,1)
    if(matrix(i,1) < min)
        min = matrix(i,1);
    end
end

%get max
for i = 2:size(matrix,1)
    if(matrix(i,1) > max)
        max = matrix(i,1);
    end
end

den = max-min;

for i = 1:size(matrix,1)
    matrix_normalized(i,1) = (matrix(i,1) - min) / den;
end
end
