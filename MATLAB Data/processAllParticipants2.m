function [ X, Y ] = processAllParticipants2 ( EEG )
%PROCESSALLPARTICIPANTS2 Processes all participants data
% Open all data sets in EEGLab
  
%%% Read and Separate Participant Data %%%

format compact;

participantSet = struct();

nSets = numel(EEG);
% get set of all set names
for i = 1:nSets
    name = EEG(i).setname;
    participant = name(1:3);
    participantSet.(participant).EEG = EEG(i);
end

% This should separate T's from P's

participants = fieldnames(participantSet);

% process each participants' data
for i = 1:numel(participants)
    if (participants{i}(1) == 'P')
        participants(i)                         %print out participant name
        participantSet.(participants{i}) = processOneParticipant(participantSet.(participants{i}));
    elseif (participants{i}(1) == 'T') 
        participants(i)                         %print out participant name
        participantSet.(participants{i}) = processOneTraining(participantSet.(participants{i}));
        
    elseif (participants{i}(1) == 'L')
        participants(i)
        participantSet.(participants{i}) = processOneTraining(participantSet.(participants{i}));
    elseif (participants{i}(1) == 'D')
        participants(i)
        participantSet.(participants{i}) = processOneTraining(participantSet.(participants{i}));
    elseif (participants{i}(1) == 'D')
    else
        e = 'Error of some sort'
    end
end

%[X, Y] = normalizeDataByFeature(participantSet);
[X, Y] = getNormalizedPerPerson(participantSet);
Y = Y';
% and now we have the whole set!
end

%%
function [ p ] = processOneTraining ( p )

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

%alpha       = pData.EEG(1).data;
%beta        = pData.EEG(2).data;
%events      = pData.EEG(1).event;
%nBands      = numel(pData.EEG);
%nChans      = size(alpha, 1);
%nSamps      = size(alpha, 2);
EEG         = p.EEG;
nEpochs     = size(EEG.data, 3);

%temp = zeros(1, nBands, nChans, nSamps);         

%%% Create Person Struct %%%
p               = struct('X', [], 'Y', []); 

%%% Get PSD %%%
p.psd   = getSumPSD (EEG.data);   % <nEpochs, nChans, nBands>
p.X     = getXfromPSD (p.psd);

for i = 1:nEpochs
   p.Y(i) = EEG.event(i).type; 
end

% Normalize the Participant's Data %

normalizedPerPerson             = normalize_per_person(p.X);
%normalizedByFeaturePerPerson    = normalize_training_per_person_and_feature(notNormalized);

%p.notNormalized                 = notNormalized;
p.normalizePerPerson            = normalizedPerPerson;
%p.normalizedByFeaturePerPerson  = normalizedByFeaturePerPerson;

end


%%
function [ PSD ] = getSumPSD( data )
% Run PSD of data and get alpha and beta values for each channel and epoch
% Returns one scalar value for each channel-epoch combo

nBands  = 2;                % alpha and beta
nChans  = size(data, 1);    % 6 channels
nEpochs = size(data, 3);    % Some epochs

PSD = zeros (nEpochs, nChans * nBands);

for i = 1:nChans
    for j = 1:nEpochs
        
        % run PSD
        pxx = log(pwelch(data(i,:,j), 250));
        
        % get alpha
        pxxA = pxx(8:13);
        PSD(i,j) = sum(pxxA);
        
        % get beta
        pxxB = pxx(13:29);
        PSD(i,j + 6) = sum(pxxB);
        
    end
end

end


%% 
function [ X ] = normalize_per_person ( X )
    [m, n] = size(X);
    
    X = reshape(X, [], 1);
    X = normalize_1D (X);
    X = reshape (X, m, n);
end


%% INCOMPLETE
function [ X ] = normalize_per_feature_per_person ( X )
   
end


%%
function [ matrix_normalized ] = normalize_1D ( matrix ) 

matrix_normalized = zeros(size(matrix, 1), 1);

mn = min(matrix);
mx = max(matrix);

den = mx-mn;

for i = 1:size(matrix,1)
    matrix_normalized(i,1) = (matrix(i,1) - mn) / den;
end
end


%%
function [ X, Y ] = normalizeDataByFeature ( participantSet )
    % For classification

participants    = fieldnames(participantSet);
nParticipants   = numel(participants);

index = 1;

for i = 1:nParticipants
    nTrials = size(participantSet.(participants{i}).X,1);
    front   = index;
    back    = index + nTrials - 1;
    
    X(front:back, :)    = participantSet.(participants{i}).X;
    Y(front:back)       = participantSet.(participants{i}).Y;
    
    index = index + nTrials;
end

for i = 1:size(X, 2)
    X(:,i)   = normalize_1D (X(:,i)); 
end

end


%%
function [ X ] = getXfromPSD ( psd )
for i = 1:6
    temp(:,i) = psd(:,i) ./ psd(:,6 + i);
end

for i = 1:3
    X(:,i) = temp(:,i) - temp(:,i+3);
end
end


%%
function [ X, Y ] = getNormalizedPerPerson ( participantSet )
participants    = fieldnames(participantSet);
nParticipants   = numel(participants);

index = 1;

for i = 1:nParticipants
    nTrials = size(participantSet.(participants{i}).normalizePerPerson,1);
    front   = index;
    back    = index + nTrials - 1;
    
    X(front:back, :)    = participantSet.(participants{i}).normalizePerPerson;
    Y(front:back)       = participantSet.(participants{i}).Y;
    
    index = index + nTrials;
end

for i = 1:numel(Y)
   if (Y(i) == 2)
       Y(i) = 4;
   end
end
end


