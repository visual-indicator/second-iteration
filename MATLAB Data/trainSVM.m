function [] = trainSVM ( participantSet )

% 1. determine number of Training sets
% 2. build svm matrix with zeros (so it doesn't get slow as it grows and rewrites)
% 3. Find all participant sets (outer for loop)
% 4. lots of for loops to get all the data within processedData
% 5. save that data to the svm matrix  and save 
    
nParticipants = numel(participantSet);
participants = fieldnames(participantSet);

% For each Participant
for i = 1:nParticipants
    participant = participants(1);
    
    if (participant(1) == 'T')
        % it's training data 
        states      = fieldnames(participant.processedData);
        nStates     = numel(states);

        % For each State (for each participant)
        for j = 1:nStates
            state = participant.processedData.(states{j});
            nTrials = numel(state);
            
            % For each Trial (for each state for each participant)
            for k = 1:nTrials
               % get data within that trial and save to svmmatrix 
            end
        end
    else
        %its not training data
    end
end

end