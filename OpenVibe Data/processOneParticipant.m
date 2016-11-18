function [ p1 ] = processOneParticipant( EEG )
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
events      = EEG(1).event;     % Collection of events during set
nEpochs     = size(events,2);   % Declare the number of epochs
nSamples    = size(betaData,2); % Declare the number of samples in each trial
nChannels   = size(betaData,1); % Declare the number of channels used
nBands      = 2;
% TEMPORARY: allows us to only deal with ONE of each color
numEpochs = 5;

temp = zeros(2,6,2500);         

p1 = struct('yellow', temp, 'green', temp, 'blue', temp, 'red', temp, 'baseline', temp);

n = 1;

%%% Create Person Struct %%%



for i = 1:numEpochs
    if (events(i).type == YELLOW)
        p1.yellow(1,:,:) = EEG(1).data(:,:,n);
        p1.yellow(2,:,:) = EEG(2).data(:,:,n);
        n = n+1;
    elseif (events(i).type == BLUE)
        p1.blue(1,:,:) = EEG(1).data(:,:,n);
        p1.blue(2,:,:) = EEG(2).data(:,:,n);        
        n = n+1;
    elseif (events(i).type == GREEN)
        p1.green(1,:,:) = EEG(1).data(:,:,n);
        p1.green(2,:,:) = EEG(2).data(:,:,n);        
        n = n+1;
    elseif (events(i).type == RED)
        p1.red(1,:,:) = EEG(1).data(:,:,n);
        p1.red(2,:,:) = EEG(2).data(:,:,n);        
        n = n+1;
    elseif (events(i).type == BASELINE)
        p1.baseline(1,:,:) = EEG(1).data(:,:,n);
        p1.baseline(2,:,:) = EEG(2).data(:,:,n);
        n = n+1;
    elseif (events(i).type == WHOOPS)
        % this is to catch the events labeled '0' that weren't supposed to
        % exist :)
    else
        % ERROR
        % Print something to say that we messed up
    end
end


%%% Process Each Trial %%%

for i = 1:numEpochs
    % psd (alpha & beta separate) using pwelch()
    % normalize (alpha & beta separate)
    
end
end

