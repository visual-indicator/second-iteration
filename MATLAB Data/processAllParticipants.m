function [ participantSet ] = processAllParticipants ( EEG )
%PROCESSALLPARTICIPANTS Processes all participants data
% Open all data sets in EEGLab

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

participants = fieldnames(participantSet);

% process each participants' data
for i = 1:numel(participants)
   participantSet.(participants{i}) = processOneParticipant(participantSet.(participants{i}));
end

% and now we have the whole set!
end


%%
function [ p ] = processOneParticipant( pData )
%function [ p1 ] = processOneParticipant ( participantNumber, alphaData, betaData, events )
%PROCESSONEPARTICIPANT Bad explanation
% Continuing to not explain things

%%% Event codes %%%

YELLOW      = 5;
BLUE        = 7;
GREEN       = 1;
RED         = 2;
BASELINE    = 4;
WHOOPS      = 0;

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
p       = struct('data', [], 'processedData', []); 
rawData = struct('yellow', temp, 'green', temp, 'blue', temp, 'red', temp, 'baseline', temp);

n = 1;

for i = 1:numEpochs
    if (events(i).type == YELLOW)
        rawData.yellow(1,:,:) = alpha(:,:,n);
        rawData.yellow(2,:,:) = beta(:,:,n);
        n = n+1;
    elseif (events(i).type == BLUE)
        rawData.blue(1,:,:) = alpha(:,:,n);
        rawData.blue(2,:,:) = beta(:,:,n);        
        n = n+1;
    elseif (events(i).type == GREEN)
        rawData.green(1,:,:) = alpha(:,:,n);
        rawData.green(2,:,:) = beta(:,:,n);        
        n = n+1;
    elseif (events(i).type == RED)
        rawData.red(1,:,:) = alpha(:,:,n);
        rawData.red(2,:,:) = beta(:,:,n);        
        n = n+1;
    elseif (events(i).type == BASELINE)
        rawData.baseline(1,:,:) = alpha(:,:,n);
        rawData.baseline(2,:,:) = beta(:,:,n);
        n = n+1;
    elseif (events(i).type == WHOOPS)
        % this is to catch the events labeled '0' that weren't supposed to
        % exist :)
    else
        % ERROR
        % Print something to say that we messed up
    end
end

p.data = rawData;


%%% Process Each Trial %%%

temp = zeros(nBands, nChans);
processedData = struct('yellow', temp, 'green', temp, 'blue', temp, 'red', temp, 'baseline', temp);

processedData.yellow      = getSumPSD(rawData.yellow);
processedData.blue        = getSumPSD(rawData.blue);
processedData.green       = getSumPSD(rawData.green);
processedData.red         = getSumPSD(rawData.red);
processedData.baseline    = getSumPSD(rawData.baseline);

% normalize data

processedData = normalize(processedData);

p.processedData = processedData;

end


%% 
function [] = processOneTraining ( pData )

alpha   = pData.EEG(1).data;
beta    = pData.EEG(2).data;
events  = pData.EEG(1).event;
nBands  = 2;
nChans  = 6;
nSamps  = 2500;

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
function [ processedData ] = normalize ( processedData )

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
