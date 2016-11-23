function [ participantSet ] = processAllParticipants ( EEG )
%PROCESSALLPARTICIPANTS Processes all participants data
% Open all data sets in EEGLab
  
%%% Options %%%

% Normalize by person (default) or by feature (set below to TRUE)
normalizeByFeature = false;


%%% Read and Separate Participant Data %%%

participantSet = struct();

nSets = numel(EEG);
% get set of all set names
for i = 1:nSets
   % check names for A or B
   name = EEG(i).setname;
   if (numel(name) == 4)
      % it is alpha or betaz
      if (name(4) == 'A')
          % it's alpha
          % then add it to the participant or create the participant
          participant = name(1:2);
          participantSet.(participant).EEG(1) = EEG(i);
      elseif (name(4) == 'B')
          % it's beta
          participant = name(1:2);
          participantSet.(participant).EEG(2) = EEG(i);
      end
   else
       % it's not filtered data
   end
end
% This should separate T's from P's

participants = fieldnames(participantSet);

% process each participants' data
for i = 1:numel(participants)
    if (participants{i}(1) == 'P')
        participants(i)
        participantSet.(participants{i}) = processOneParticipant(participantSet.(participants{i}), normalizeByFeature);
    else 
        participants(i)
        participantSet.(participants{i}) = processOneTraining(participantSet.(participants{i}), normalizeByFeature);
    end
end

if (normalizeByFeature)
    % load the processedData of each participant, normalize each row, then
    % put it back
end

% and now we have the whole set!
end

%%
function [ p ] = processOneParticipant( pData, normalizeByFeature )
%PROCESSONEPARTICIPANT Bad explanation
% Continuing to not explain things

%%% Event codes %%%

YELLOW      = 5;
BLUE        = 7;
GREEN       = 1;
RED         = 2;
BASELINE    = 4;

%%% Constants and Input Data %%%

alpha   = pData.EEG(1).data;
beta    = pData.EEG(2).data;
events  = pData.EEG(1).event;
nBands  = 2;
nChans  = 6;
nSamps  = 2500;
% TEMPORARY: allows us to only deal with ONE of each color
numEpochs = 5;

temp = zeros(nBands, nChans, nSamps);         

%%% Create Person Struct %%%
p       = struct('filteredData', [], 'processedData', []); 
filteredData = struct('yellow', temp, 'green', temp, 'blue', temp, 'red', temp, 'baseline', temp);

n = 1;

for i = 1:numEpochs
    if (events(i).type == YELLOW)
        filteredData.yellow(1,:,:) = alpha(:,:,n);
        filteredData.yellow(2,:,:) = beta(:,:,n);
        n = n+1;
    elseif (events(i).type == BLUE)
        filteredData.blue(1,:,:) = alpha(:,:,n);
        filteredData.blue(2,:,:) = beta(:,:,n);        
        n = n+1;
    elseif (events(i).type == GREEN)
        filteredData.green(1,:,:) = alpha(:,:,n);
        filteredData.green(2,:,:) = beta(:,:,n);        
        n = n+1;
    elseif (events(i).type == RED)
        filteredData.red(1,:,:) = alpha(:,:,n);
        filteredData.red(2,:,:) = beta(:,:,n);        
        n = n+1;
    elseif (events(i).type == BASELINE)
        filteredData.baseline(1,:,:) = alpha(:,:,n);
        filteredData.baseline(2,:,:) = beta(:,:,n);
        n = n+1;
    else
        % ERROR
        % Print something to say that we messed up
    end
end

p.filteredData = filteredData;


%%% Process Each Trial %%%

temp = zeros(nBands, nChans);
processedData = struct('yellow', temp, 'green', temp, 'blue', temp, 'red', temp, 'baseline', temp);

processedData.yellow      = getSumPSD(filteredData.yellow);
processedData.blue        = getSumPSD(filteredData.blue);
processedData.green       = getSumPSD(filteredData.green);
processedData.red         = getSumPSD(filteredData.red);
processedData.baseline    = getSumPSD(filteredData.baseline);

% normalize data 

if (normalizeByFeature == false)
    processedData = normalize_colors(processedData);
end

p.processedData = processedData;

end


%% 
function [ p ] = processOneTraining ( pData, normalizeByFeature )

%%% Event Codes %%%

HAPPY       = 1;
NEUTRAL     = 2;
SAD         = 3;

%%% Constants and Input Data %%%

alpha       = pData.EEG(1).data;
beta        = pData.EEG(2).data;
events      = pData.EEG(1).event;
nBands      = numel(pData.EEG);
nChans      = size(alpha, 1);
nSamps      = size(alpha, 2);
nEpochs     = size(alpha, 3);

temp = zeros(1, nBands, nChans, nSamps);         

%%% Create Person Struct %%%
p               = struct('filteredData', [], 'processedData', []); 
filteredData    = struct('happy', temp, 'neutral', temp, 'sad', temp);

j   = 1;
h   = 0;
n   = 0;
s   = 0; 

%%% Restructure Filtered Data %%%

for i = 1:nEpochs
    if (events(i).type == HAPPY)
        h = h+1;
        filteredData.happy(h,1,:,:) = alpha(:,:,j);
        filteredData.happy(h,2,:,:) = beta(:,:,j);
        j = j+1;
    elseif (events(i).type == NEUTRAL)
        n = n+1;
        filteredData.neutral(n,1,:,:) = alpha(:,:,j);
        filteredData.neutral(n,2,:,:) = beta(:,:,j);        
        j = j+1;
    elseif (events(i).type == SAD)
        s = s+1;
        filteredData.sad(s,1,:,:) = alpha(:,:,j);
        filteredData.sad(s,2,:,:) = beta(:,:,j);  
        j = j+1;
    else
        % ERROR
        % Print something to say that we messed up
    end
end

p.filteredData = filteredData;

%%% Process Data %%%

processedData = struct('happy', zeros(h, nBands, nChans), 'neutral', zeros(n, nBands, nChans), 'sad', zeros(s, nBands, nChans));

labels  = fieldnames(processedData);

% Get PSD %
nLabels = size(labels,1);
for i = 1:nLabels
    nTrials = size(filteredData.(labels{i}),1);
    filteredData.(labels{i});
    
    for j = 1:nTrials
        %processedData.(labels{i})(j,:,:) = filteredData.happy(1,1,:,:);
        temp = squeeze(filteredData.(labels{i})(j,:,:,:));
        processedData.(labels{i})(j,:,:) = getSumPSD(temp);
    end
end

% Normalize the Participant's Data %
if (normalizeByFeature == false)
    processedData = normalize_training(processedData);
end

p.processedData = processedData;

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
function [ processedData ] = normalize_colors ( processedData )

colors              = fieldnames(processedData);
[nBands, nChans]    = size (processedData.(colors{1}));
nColors             = numel (colors);
valsPerColor        = nBands * nChans;

matrix = zeros(nColors * valsPerColor, 1);

% unfold data
for i = 1:nColors
    front   = (i - 1) * valsPerColor + 1;
    back    = (i) * valsPerColor;
    
    matrix(front:back) = reshape(processedData.(colors{1}), valsPerColor, 1);
end

matrix_normalized = normalize_1D (matrix);

% fold data back up
for i = 1:nColors
    front   = (i - 1) * valsPerColor + 1;
    back    = (i) * valsPerColor;
    
    temp    = matrix_normalized(front:back);
    processedData.(colors{i}) = reshape(temp, nBands, nChans);
end

end


%%
function [ processedData ] = normalize_training( processedData )

states      = fieldnames(processedData);
nStates     = numel (states);
nTrials     = size (processedData.(states{1}), 1);
%nTrials     = 3;
nBands      = size (processedData.(states{1}), 2); 
nChans      = size (processedData.(states{1}), 3);
nPerState   = nTrials * nBands * nChans;
nElements   = nStates * nPerState;

matrix = zeros(nElements, 1);

% unfold data
for i = 1:nStates
    
    front   = (i - 1) * nPerState + 1;
    back    = (i) * nPerState;
    
    matrix(front:back) = reshape(processedData.(states{i}), nPerState, 1);
end

matrix_normalized = normalize_1D (matrix);

% fold data back up
for i = 1:nStates
    front   = (i - 1) * nPerState + 1;
    back    = (i) * nPerState;
    
    processedData.(states{i}) = reshape(matrix_normalized(front:back), nTrials, nBands, nChans);
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
