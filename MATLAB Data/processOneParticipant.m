function [ p1, unclassified ] = processOneParticipant( EEG )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%%% Event codes %%%

YELLOW      = 5;
BLUE        = 7;
GREEN       = 1;
RED         = 2;
BASELINE    = 4;
WHOOPS      = 0;

%%% Constants and Input Data %%%

alphaData   = EEG(1).data;      % Alpha activity from all trials
betaData    = EEG(2).data;      % Beta activity from all trials
data        = EEG(1:2).data;    % Alpha and Beta activity from all trials
events      = EEG(1).event;     % Events from data set
nEpochs     = size(events,2);   % Declare the number of epochs
nSamples    = size(betaData,2); % Declare the number of samples in each trial
nChannels   = size(betaData,1); % Declare the number of channels used
nBands      = 2;
% TEMPORARY: allows us to only deal with ONE of each color
numEpochs = 5;

temp = zeros(2,6,2500);         

p1      = struct('data', [], 'unclassified', []); 
rawData = struct('yellow', temp, 'green', temp, 'blue', temp, 'red', temp, 'baseline', temp);

n = 1;

%%% Create Person Struct %%%



for i = 1:numEpochs
    if (events(i).type == YELLOW)
        rawData.yellow(1,:,:) = EEG(1).data(:,:,n);
        rawData.yellow(2,:,:) = EEG(2).data(:,:,n);
        n = n+1;
    elseif (events(i).type == BLUE)
        rawData.blue(1,:,:) = EEG(1).data(:,:,n);
        rawData.blue(2,:,:) = EEG(2).data(:,:,n);        
        n = n+1;
    elseif (events(i).type == GREEN)
        rawData.green(1,:,:) = EEG(1).data(:,:,n);
        rawData.green(2,:,:) = EEG(2).data(:,:,n);        
        n = n+1;
    elseif (events(i).type == RED)
        rawData.red(1,:,:) = EEG(1).data(:,:,n);
        rawData.red(2,:,:) = EEG(2).data(:,:,n);        
        n = n+1;
    elseif (events(i).type == BASELINE)
        rawData.baseline(1,:,:) = EEG(1).data(:,:,n);
        rawData.baseline(2,:,:) = EEG(2).data(:,:,n);
        n = n+1;
    elseif (events(i).type == WHOOPS)
        % this is to catch the events labeled '0' that weren't supposed to
        % exist :)
    else
        % ERROR
        % Print something to say that we messed up
    end
end

p1.data = rawData;


%%% Process Each Trial %%%

temp = zeros(2,6);
unclassified = struct('yellow', temp, 'green', temp, 'blue', temp, 'red', temp, 'baseline', temp);

unclassified.yellow      = getSumPSD(rawData.yellow);
unclassified.blue        = getSumPSD(rawData.blue);
unclassified.green       = getSumPSD(rawData.green);
unclassified.red         = getSumPSD(rawData.red);
unclassified.baseline    = getSumPSD(rawData.baseline);

% normalize data

unclassified = normalize(unclassified);

p1.unclassified = unclassified;

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
