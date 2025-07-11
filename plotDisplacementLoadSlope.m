function plotDisplacementLoadSlope(dataTable, targetSlope, color, forceMax)
%PLOT_DIS_LOAD_SLOPE Starts curve based on target slope
%   Uses a likely inefficient algorithm to find slope between each data
%   point. targetSlope is the threshold to start. Should probably be 
%   something near young's modulus. forceMax is used to cut bad data 
%   points, 300 by default.

if nargin < 3
    color = rand(1,3);
    forceMax = 300;
elseif nargin < 4
    forceMax = 300;
end

% Loading data
absDisplacement = dataTable.LoadingStageum;
force = dataTable.LoadCelllb;

% Clearing bad data
trueValues = force < forceMax;
absDisplacement = absDisplacement(trueValues);
force = force(trueValues);

% Calculating slope
deltaY = diff(force);
deltaX = diff(absDisplacement);
slope = deltaY ./ deltaX;

% Grabbing target data
index = find(slope >= targetSlope,1);
force = force(index:end);
absDisplacement = absDisplacement(index:end);
relDisplacement = absDisplacement - absDisplacement(1);

% Plotting
plot(relDisplacement, force, 'Color', color)
end