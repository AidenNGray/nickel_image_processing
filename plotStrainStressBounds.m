function plotStrainStressBounds(dataTable, crossSection, gaugeLength, forceBounds, color)
%PLOTDISPLACEMENTLOAD Plots relative displacement and absolute load values
%from sample computer at ALS 8.3.2
%   Data must be in tabular form with default var names. Use forceBounds
%   to set limits on force values. Must Color changes plot color. Must be
%   valid MATLAB color identifier.

if nargin < 4
    forceBounds = [0 300];
    color = rand(1,3);
elseif nargin < 5
    color = rand(1,3);
end

% Loading data
absDisplacement = dataTable.LoadingStageum;
force = dataTable.LoadCellN;

% Selecting data within bounds
trueValues = (forceBounds(1) * 4.448 < force) & (force < forceBounds(2) * 4.448);
force = force(trueValues);
tempAbsDis = absDisplacement(trueValues);
relDisplacement = tempAbsDis - tempAbsDis(1);

aparatusElong = elongationCalc(dataTable);
sampleElong = (relDisplacement*1000) - aparatusElong(trueValues);

% Computing stress & strain
stress = force ./ crossSection;
strain = sampleElong ./ gaugeLength;

% Plotting
plot(strain, stress, 'Color', color)

end