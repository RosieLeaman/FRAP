% the input should be 2 MATRICES
% signals has as its ROWS the SIGNAL AT EACH TIMEPOINT
% times has as its ROWS the TIMEPOINTS corresponding to the same row of X
% these must have THE SAME DIMENSION

function [avgSignals,newTimes,errors] = calcAverage(signals,times)

% find out how many things we have to average over
n = size(signals,1);

% determine the maximum timepoint
% this is the minimum of the final column of T (do not want to
% extrapolate!)
m = min(times(:,end));

% create the 'query points' where we shall interpolate each to find their
% value
numQueries = 1000; % number of query points to be used
xq = linspace(1,m,numQueries);

% create the matrix to store the results
interpolated = zeros(n,numQueries+1);

% go through each signal and interpolate it at our query points
for i=1:n
    interpolated(i,2:end) = interp1(times(i,:),signals(i,:),xq);
    interpolated(i,1) = 1;
end

% create vectors to store average and errors

avgSignals = zeros(1,numQueries);
errors = zeros(1,numQueries);

% average the signals and find the errors
for i=1:numQueries
    avgSignals(i) = mean(interpolated(:,i));
    errors(i) = std(interpolated(:,i));
end

% return the average and the new timepoints
newTimes = xq;


