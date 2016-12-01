function [ svmMatrix, svmClassifier ] = getNormalizeByFeature_Color ( participantSet )
% TRAINSVM Output the data within participantSet as a matrix and vector
% Usage: [svmMatrix, svmClassifier] = trainSVM(participantSet);

% For classification

HAPPY           = 1;
NEUTRAL         = 2;
SAD             = 3;

nChans          = 6;
nBands          = 2;
nColors         = 3;
nTrials         = 3;
nParticipants   = numel(fieldnames(participantSet));
participants    = fieldnames(participantSet);

% Initialize nTrainingSets
nTestingSets   = 0;

% Count the number of Training Sets
for i = 1:nParticipants
	name = cell2mat(participants(1));
    
    if (name(1) == 'P')
        nTestingSets = nTestingSets + 1;
    end 
end

% Create svmMatrix
%  NOTE: Even if the data doesn't match this exactly, it will prevent us from
%  having to re-create a matrix EVERY time. A few times wouldn't be too bad
nRows           = nTestingSets * nColors * nTrials;
nCols           = nChans * nBands;
svmMatrix       = zeros (nRows, nCols);
svmClassifier   = zeros (nRows, 1);

index = 1;

% For each Participant
for i = 1:nParticipants
    name = cell2mat(participants(i));
    participant = participantSet.(name);
    
    if (name(1) == 'P')
        % it's training data 
        colors  = fieldnames (participant.notNormalized);      %%%%%% NORMALIZEBYFEATURE DOES NOT EXIST %%%%%
        nColors = numel (colors);

        % For each State (for each participant)
        for j = 1:nColors
            color = participant.notNormalized.(colors{j});     %%%%%% NORMALIZEBYFEATURE DOES NOT EXIST %%%%%
            
            % get data within that trial and save to svmmatrix
            temp                    = zeros (2*nChans, 1);
            temp(1:nChans)          = color(1,:);           % Alpha
            temp(nChans+1:2*nChans) = squeeze(color(2,:));           % Beta
            svmMatrix(index, :)     = temp;
            svmClassifier(index)    = j;
            index                   = index + 1;
        end
    else
        %its not training data
    end
end

end

