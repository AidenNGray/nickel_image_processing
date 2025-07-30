function plotDisplacementStressBounds(dataTable, crossSection, forceBounds, color)
%PLOTDISPLACEMENTLOAD Plots relative displacement and absolute load values
%from sample computer at ALS 8.3.2
%   Data must be in tabular form with default var names. Use forceBounds
%   to set limits on force values. Must Color changes plot color. Must be
%   valid MATLAB color identifier.

if nargin < 3
    forceBounds = [0 300];
    color = rand(1,3);
elseif nargin < 4
    color = rand(1,3);
end

% Loading data
absDisplacement = dataTable.LoadingStageum;
forceLB = dataTable.LoadCelllb;
forceN = dataTable.LoadCellN;

% Selecting data within bounds
startIx = 2500; % Avoid bad data to start
trueValues = (forceBounds(1) < forceLB(startIx:end)) & (forceLB(startIx:end) < forceBounds(2));

forceN = forceN(startIx:end);
force = forceN(trueValues);

absDisplacement = absDisplacement(startIx:end);
absDisplacement = absDisplacement(trueValues);
relDisplacement = absDisplacement - absDisplacement(1);

% Computing stress
stress = force ./ crossSection;

% Plotting
plot(relDisplacement, stress, 'Color', color, 'LineWidth',3)

end