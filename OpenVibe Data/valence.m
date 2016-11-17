function [ val ] = valence( alpha, beta )
%VALENCE Determines the valence of EEG data
%   Detailed explanation goes here

alpha = alpha .* alpha;
beta = beta .* beta;

aL = [alpha(1,:); alpha(3,:); alpha(5,:)];
aR = [alpha(2,:); alpha(4,:); alpha(6,:)];

bL = [beta(1,:); beta(3,:); beta(5,:)];
bR = [beta(2,:); beta(4,:); beta(6,:)];

aL = mean (aL);
aR = mean (aR);
bL = mean (bL);
bR = mean (bR);

val = aR/bR - aL/bL;

end

