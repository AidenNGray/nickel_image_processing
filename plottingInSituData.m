%% Loading data

load("inSituLoadingData.mat")
inSituLoadingData = rmfield(inSituLoadingData,'SampleNoH_1');

%% Displacement vs Load
% Configs
tiledlayout(2, 3)
colors = ['r' 'b' 'g'];
samples = fieldnames(inSituLoadingData);
forceBounds = [20 300; 30 300; 40 300]; 
targetSlope = [20 30 40]; 

% Plotting displacement vs load with min/max force bounds
for fb = 1:length(forceBounds)
    nexttile
    hold on;
    for i = 1:numel(samples)
        currentTable = inSituLoadingData.(samples{i});
        plotDisplacementLoadBounds(currentTable, forceBounds(fb,:), colors(i))
    end
    xlabel("Relative Displacement");
    ylabel("Force (lb)");
    title(sprintf("In Situ Force Data w/ Force Bounds (%dlb -> %dlb)",forceBounds(fb,:)))
    legend(samples, "Location","southeast")

    hold off;
end

% Plotting displacement vs load with slope
for ts = 1:length(targetSlope)
    nexttile
    hold on;
    for i = 1:numel(samples)
        currentTable = inSituLoadingData.(samples{i});
        plotDisplacementLoadSlope(currentTable, targetSlope(ts), colors(i))
    end
    xlabel("Relative Displacement");
    ylabel("Force (lb)");
    title(sprintf("In Situ Force Data w/ Slope Target (%.1f lb/um)", targetSlope(ts)))
    legend(samples, "Location","southeast")

    hold off;
end

%% Displacement vs stress
% Configs
figure;
tiledlayout(2, 3)
colors = ['r' 'b' 'g'];
samples = fieldnames(inSituLoadingData);
forceBounds = [20 300; 30 300; 40 300]; % in pounds
targetSlope = [20 30 40]; % in pounds / mm
lengths = 1.5;
widths = [.4 .46 .355];

% Cross sections
crossSections = lengths .* widths;

% Plotting displacement vs load with min/max force bounds
for fb = 1:length(forceBounds)
    nexttile
    hold on;
    for i = 1:numel(samples)
        currentTable = inSituLoadingData.(samples{i});
        plotDisplacementStressBounds(currentTable, crossSections(i), forceBounds(fb,:), colors(i))
    end
    xlabel("Relative Displacement (um)");
    ylabel("Stress (MPa)");
    title(sprintf("In Situ Force Data w/ Force Bounds (%dlb -> %dlb)",forceBounds(fb,:)))
    legend(samples, "Location","southeast")

    hold off;
end

% Plotting displacement vs load with slope
for ts = 1:length(targetSlope)
    nexttile
    hold on;
    for i = 1:numel(samples)
        currentTable = inSituLoadingData.(samples{i});
        plotDisplacementStressSlope(currentTable, crossSections(i), targetSlope(ts), colors(i))
    end
    xlabel("Relative Displacement (um)");
    ylabel("Stress (MPa)");
    title(sprintf("In Situ Force Data w/ Slope Target (%.1f lb/um)", targetSlope(ts)))
    legend(samples, "Location","southeast")

    hold off;
end

%% "Strain" vs stress