function plotDisplacementStressSlope(dataTable, crossSection, targetSlope, color, forceMax)
%PLOT_DIS_LOAD_SLOPE Starts curve based on target slope
%   Uses a likely inefficient algorithm to find slope between each data
%   point. targetSlope is the threshold to start. Should probably be 
%   something near young's modulus. forceMax is used to cut bad data 
%   points, 300 by default.

if nargin < 4
    color = rand(1,3);
    forceMax = 300;
elseif nargin < 5
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

slope(isinf(slope)) = 0; % Fixing where displacement doesn't change

% Grabbing target data
ix = 0;
index = 0;
while max(index) < 5000 % Hacky way to get around bad data at start
    ix = ix + 1;
    index = find((slope >= targetSlope) & (slope < 100),ix);
    if ix >= length(slope)
        break % Hopefully avoid infinite loop
    end
end
    
force = force(index(ix):end);
absDisplacement = absDisplacement(index(ix):end);
relDisplacement = absDisplacement - absDisplacement(1);

stress = (force*4.448) ./ crossSection;

% Plotting
plot(relDisplacement, stress, 'Color', color)
end