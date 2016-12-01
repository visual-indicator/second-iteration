function [ participantSet ] = processAllParticipants ( EEG )
%PROCESSALLPARTICIPANTS Processes all participants data
% Open all data sets in EEGLab
  
%%% Read and Separate Participant Data %%%

format compact;

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
        participants(i)                         %print out participant name
        participantSet.(participants{i}) = processOneParticipant(participantSet.(participants{i}));
    else 
        participants(i)                         %print out participant name
        participantSet.(participants{i}) = processOneTraining(participantSet.(participants{i}));
    end
end

participantSet = normalizeDataByFeature(participantSet);

% and now we have the whole set!
end

%%
function [ p ] = processOneParticipant( pData )
%PROCESSONEPARTICIPANT Bad explanation
% Continuing to not explain things

%%% Event codes %%%

YELLOW      = 5;
YELLOWCHAR  = '5';
BLUE        = 7;
BLUECHAR    = '7';
GREEN       = 1;
GREENCHAR   = '1';
RED         = 2;
REDCHAR     = '2';
BASELINE    = 4;
BASELINECHAR='4';

%%% Constants and Input Data %%%

alpha   = pData.EEG(1).data;
beta    = pData.EEG(2).data;
events  = pData.EEG(1).event;
nBands  = 2;
nChans  = 6;
nSamps  = 2500;
% TEMPORARY: allows us to only deal with ONE of each color
numEpochs = size(alpha, 3);

temp = zeros(nBands, nChans, nSamps);         

%%% Create Person Struct %%%
p            = struct('filteredData', []); 
filteredData = struct('yellow', temp, 'green', temp, 'blue', temp, 'red', temp, 'baseline', temp);

n = 1;

for i = 1:numEpochs
    if (events(i).type == YELLOW || events(i).type == YELLOWCHAR)
        filteredData.yellow(1,:,:) = alpha(:,:,n);
        filteredData.yellow(2,:,:) = beta(:,:,n);
        n = n+1;
    elseif (events(i).type == BLUE || events(i).type == BLUECHAR)
        filteredData.blue(1,:,:) = alpha(:,:,n);
        filteredData.blue(2,:,:) = beta(:,:,n);        
        n = n+1;
    elseif (events(i).type == GREEN || events(i).type == GREENCHAR)
        filteredData.green(1,:,:) = alpha(:,:,n);
        filteredData.green(2,:,:) = beta(:,:,n);        
        n = n+1;
    elseif (events(i).type == RED || events(i).type == REDCHAR)
        filteredData.red(1,:,:) = alpha(:,:,n);
        filteredData.red(2,:,:) = beta(:,:,n);        
        n = n+1;
    elseif (events(i).type == BASELINE || events(i).type == BASELINECHAR)
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
notNormalized = struct('yellow', temp, 'green', temp, 'blue', temp, 'red', temp, 'baseline', temp);

notNormalized.yellow      = getSumPSD(filteredData.yellow);
notNormalized.blue        = getSumPSD(filteredData.blue);
notNormalized.green       = getSumPSD(filteredData.green);
notNormalized.red         = getSumPSD(filteredData.red);
notNormalized.baseline    = getSumPSD(filteredData.baseline);

% normalize data 

normalizedPerPerson             = normalize_colors(notNormalized);
%normalizedByFeaturePerPerson    = normalize_colors_per_person(notNormalized);

p.notNormalized         = notNormalized;
p.normalizePerPerson    = normalizedPerPerson;

end


%% 
function [ p ] = processOneTraining ( pData )

%%% Event Codes %%%

HAPPY       = 1;
HAPPYCHAR   = '1';
NEUTRAL     = 2;
NEUTRALCHAR = '2';
SAD         = 3;
SADCHAR     = '3';
BASELINE    = 4;
BASELINECHAR='4';

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
filteredData    = struct('happy', [], 'neutral', [], 'sad', [], 'baseline', []);

j   = 1;
h   = 0;
n   = 0;
s   = 0; 
b   = 0;

%%% Restructure Filtered Data %%%

for i = 1:nEpochs
    if (events(i).type == HAPPY || events(i).type == HAPPYCHAR)
        h = h+1;
        filteredData.happy(h,1,:,:) = alpha(:,:,j);
        filteredData.happy(h,2,:,:) = beta(:,:,j);
        j = j+1;
    elseif (events(i).type == NEUTRAL || events(i).type == NEUTRALCHAR)
        n = n+1;
        filteredData.neutral(n,1,:,:) = alpha(:,:,j);
        filteredData.neutral(n,2,:,:) = beta(:,:,j);        
        j = j+1;
    elseif (events(i).type == SAD || events(i).type == SADCHAR)
        s = s+1;
        filteredData.sad(s,1,:,:) = alpha(:,:,j);
        filteredData.sad(s,2,:,:) = beta(:,:,j);  
        j = j+1;
    elseif (events(i).type == BASELINE || events(i).type == BASELINECHAR)
        b = b+1;
        filteredData.baseline(b,1,:,:) = alpha(:,:,j);
        filteredData.baseline(b,2,:,:) = beta(:,:,j);  
        j = j+1;
    else 
        str = 'Something went wrong...'
    end
end

p.filteredData = filteredData;

%%% Process Data %%%

%notNormalized = struct('happy', zeros(h, nBands, nChans), 'neutral', zeros(n, nBands, nChans), 'sad', zeros(s, nBands, nChans));
notNormalized = struct('happy', [], 'neutral', [], 'sad', [], 'baseline', []);

labels  = fieldnames(notNormalized);

% Get PSD %
nLabels = size(labels,1);
for i = 1:nLabels
    nTrials = size(filteredData.(labels{i}),1);
    filteredData.(labels{i});
    
    for j = 1:nTrials
        %processedData.(labels{i})(j,:,:) = filteredData.happy(1,1,:,:);
        temp = squeeze(filteredData.(labels{i})(j,:,:,:));
        notNormalized.(labels{i})(j,:,:) = getSumPSD(temp);
    end
end

% Normalize the Participant's Data %

normalizedPerPerson             = normalize_training(notNormalized);
normalizedByFeaturePerPerson    = normalize_training_per_person_and_feature(notNormalized);

p.notNormalized                 = notNormalized;
p.normalizePerPerson            = normalizedPerPerson;
p.normalizedByFeaturePerPerson  = normalizedByFeaturePerPerson;

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
nBands      = size (processedData.(states{1}), 2); 
nChans      = size (processedData.(states{1}), 3);
nPerState   = nTrials * nBands * nChans;
nElements   = nStates * nPerState;

matrix = zeros(nElements, 1);

% unfold data
for i = 1:nStates
    
    nTrials     = size(processedData.(states{i}),1);
    nPerState   = nTrials * nBands * nChans;
    
    front       = (i - 1) * nPerState + 1;
    back        = (i) * nPerState;
    
    matrix(front:back) = reshape(processedData.(states{i}), nPerState, 1);
end

matrix_normalized = normalize_1D (matrix);

% fold data back up
for i = 1:nStates
    nTrials     = size(processedData.(states{i}),1);
    nPerState   = nTrials * nBands * nChans;
    
    front   = (i - 1) * nPerState + 1;
    back    = (i) * nPerState;
    
    processedData.(states{i}) = reshape(matrix_normalized(front:back), nTrials, nBands, nChans);
end

end


%% TODO: finish this function maybe someday
function [ normalized ] = normalize_training_per_person_and_feature( notNormalized )

states      = fieldnames(notNormalized);
nStates     = numel (states);
nTrials     = size (notNormalized.(states{1}), 1);
nBands      = size (notNormalized.(states{1}), 2); 
nChans      = size (notNormalized.(states{1}), 3);
nPerState   = nTrials * nBands * nChans;

matrix = zeros(nTrials, nBands * nChans);

index = 1;

% unfold data
for i = 1:nStates
    
    nTrials = size(notNormalized.(states{i}),1);
    front   = index;
    back    = index + nTrials;
    
    matrix(front:back,1:nChans)             = squeeze(notNormalized.(states{i})(:,1,:));
    matrix(front:back,nChans+1:2*nChans)    = squeeze(notNormalized.(states{i})(:,2,:));
end

for i = 1:size(matrix,2)
    matrix_normalized = normalize_1D(matrix(:,i));
end

index = 1;

% TODO: fold data back up
for i = 1:nStates
    nTrials     = size(notNormalized.(states{i}),1);
    nPerState   = nTrials * nBands * nChans;
    
    front   = index;
    back    = index + nTrials;
    
    normalized.(states{i})(:,1,:) = matrix_normalized(front:back,1:nChans);
    normalized.(states{i})(:,2,:) = matrix_normalized(front:back,1:nChans);
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


%%
function [ participantSet ] = normalizeDataByFeature ( participantSet )
    % For classification

nChans          = 6;
nBands          = 2;
nStates         = 3;
nTrials         = 3;
nParticipants   = numel(fieldnames(participantSet));
participants    = fieldnames(participantSet);

% Initialize nTrainingSets
nTrainingSets   = 0;

% Count the number of Training Sets
for i = 1:nParticipants
	name = cell2mat(participants(1));
    
    if (name(1) == 'T')
        nTrainingSets = nTrainingSets + 1;
    end 
end

% Create svmMatrix
%  NOTE: Even if the data doesn't match this exactly, it will prevent us from
%  having to re-create a matrix EVERY time. A few times wouldn't be too bad
nRows           = nTrainingSets * nStates * nTrials;
nCols           = nChans * nBands;
data            = zeros (nRows, nCols);

index = 1;

% Add each Training Set (video/1st iteration)
for i = 1:nParticipants
    name = cell2mat(participants(i));
    participant = participantSet.(name);
    
    if (name(1) == 'T')
        % it's training data 
        states  = fieldnames (participant.notNormalized);
        nStates = numel (states);

        % For each State (for each participant)
        for j = 1:nStates
            state = participant.notNormalized.(states{j});
            nTrials = size(state,1);
            
            % For each Trial (for each state for each participant)
            for k = 1:nTrials
                temp                    = zeros (2*nChans, 1);
                temp(1:nChans)          = state(k,1,:);
                temp(nChans+1:2*nChans) = state(k,2,:);
                data(index, :)          = temp;
                index                   = index + 1;
            end
        end
    else
        %its not training data
    end
end

% Add each Testing set (colors/2nd iteration)
for i = 1:nParticipants
    name = cell2mat(participants(i));
    participant = participantSet.(name);
    
    if (name(1) == 'P')
        % it's testing data 
        colors  = fieldnames (participant.notNormalized);
        nColors = numel (colors);

        % For each State (for each participant)
        for j = 1:nColors
            color                   = participant.notNormalized.(colors{j});
            temp                    = zeros (2*nChans, 1);
            temp(1:nChans)          = color(1,:);
            temp(nChans+1:2*nChans) = color(2,:);
            data(index, :)          = temp;
            index                   = index + 1;
        end
    else
        %its not training data
    end
end

%%% Normalize data %%%

for i = 1:size(data,2)
   data(:,i) = normalize_1D(data(:,i)); 
end

index = 1;

% Put normalized training data back (video/1st iteration)
for i = 1:nParticipants
    name = cell2mat(participants(i));
    participant = participantSet.(name);
    
    if (name(1) == 'T')
        % it's training data 
        states  = fieldnames (participant.notNormalized);
        nStates = numel (states);

        % pre-allocate the right quantity of data
        participant.normalizeByFeature = participant.notNormalized;
        
        % For each State (for each participant)
        for j = 1:nStates
            state = participant.notNormalized.(states{j});
            nTrials = size(state,1);
            
            % For each Trial (for each state for each participant)
            for k = 1:nTrials
                % get data within that trial and save to svmmatrix
                participant.normalizeByFeature.(states{j})(k,1,:) = data (index,1:nChans);
                participant.normalizeByFeature.(states{j})(k,2,:) = data (index, nChans+1:2*nChans);
                index = index + 1;
            end
        end
        participantSet.(participants{i}).normalizeByFeature = participant.normalizeByFeature;
    else
        %its not training data
    end
end

% Put normalized testing data back (colors/2nd iteration)
for i = 1:nParticipants
    name = cell2mat(participants(i));
    participant = participantSet.(name);
    
    if (name(1) == 'P')
        % it's training data 
        colors  = fieldnames (participant.notNormalized);
        nStates = numel (colors);

        % pre-allocate the right quantity of data
        participant.normalizeByFeature = participant.notNormalized;
        
        % For each State (for each participant)
        for j = 1:nStates
            % get data within that trial and save to svmmatrix
            participant.normalizeByFeature.(colors{j})(1,:) = data (index,1:nChans);
            participant.normalizeByFeature.(colors{j})(2,:) = data (index, nChans+1:2*nChans);
            index = index + 1;
        end
        participantSet.(participants{i}).normalizeByFeature = participant.normalizeByFeature;
    else
        %its not training data
    end
end

end