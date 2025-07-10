function plotDisplacementLoad(dataTable, startingIndex, color)
%PLOTDISPLACEMENTLOAD Plots relative displacement and absolute load values
%from sample computer at ALS 8.3.2
%   Data must be in tabular form with default var names. Use startingIndex
%   to shift data or chop off early data. Color changes plot color. Must be
%   valid MATLAB color identifier.

if nargin < 2
    startingIndex = 1;
    color = rand(1,3);
elseif nargin < 3
    color = rand(1,3);
end

% Loading data
absDisplacement = dataTable.LoadingStageum(startingIndex:end);
relDisplacement = absDisplacement - absDisplacement(1);
force = dataTable.LoadCelllb(startingIndex:end);

trueValues = force < 300;


% Plotting
plot(relDisplacement(trueValues),force(trueValues), 'Color',color)

end