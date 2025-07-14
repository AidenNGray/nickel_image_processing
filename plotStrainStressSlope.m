function plotStrainStressSlope(dataTable, crossSection, gaugeLength, targetSlope, color, forceMax)
%PLOT_DIS_LOAD_SLOPE Starts curve based on target slope
%   Uses a likely inefficient algorithm to find slope between each data
%   point. targetSlope is the threshold to start. Should probably be 
%   something near young's modulus. forceMax is used to cut bad data 
%   points, 300 by default.

if nargin < 5
    color = rand(1,3);
    forceMax = 300;
elseif nargin < 6
    forceMax = 300;
end

% Loading data
absDisplacement = dataTable.LoadingStageum;
forceLB = dataTable.LoadCelllb;
forceN = dataTable.LoadCellN;

% Clearing bad data
trueValues = forceLB < forceMax;
absDisplacement = absDisplacement(trueValues);
forceLB = forceLB(trueValues);
forceN = forceN(trueValues);

tempDataTable.LoadCellN = forceN;

% Calculating slope
deltaY = diff(forceLB);
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
    
forceN = forceN(index(ix):end);
absDisplacement = absDisplacement(index(ix):end);
relDisplacement = absDisplacement - absDisplacement(1);

aparatusElong = elongationCalc(tempDataTable); % mm
sampleElong = (relDisplacement./1000) - aparatusElong(index(ix):end); % Weird incompatible size issue

% stress & strain
stress = forceN ./ crossSection;
strain = sampleElong ./ gaugeLength;

% Plotting
plot(strain, stress, 'Color', color)
end