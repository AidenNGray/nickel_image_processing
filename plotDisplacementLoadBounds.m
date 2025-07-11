function plotDisplacementLoadBounds(dataTable, forceBounds, color)
%PLOTDISPLACEMENTLOAD Plots relative displacement and absolute load values
%from sample computer at ALS 8.3.2
%   Data must be in tabular form with default var names. Use forceBounds
%   to set limits on force values. Must Color changes plot color. Must be
%   valid MATLAB color identifier.

if nargin < 2
    forceBounds = [0 300];
    color = rand(1,3);
elseif nargin < 3
    color = rand(1,3);
end

% Loading data
absDisplacement = dataTable.LoadingStageum;
force = dataTable.LoadCelllb;

% Selecting data within bounds
trueValues = (forceBounds(1) < force) & (force < forceBounds(2));
tempAbsDis = absDisplacement(trueValues);
relDisplacement = tempAbsDis - tempAbsDis(1);

% Plotting
plot(relDisplacement,force(trueValues), 'Color',color)

end