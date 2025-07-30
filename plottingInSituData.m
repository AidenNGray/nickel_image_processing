%% Loading data

load("inSituLoadingData.mat")
inSituLoadingData = rmfield(inSituLoadingData,'SampleNoH_1');

%% Baseline
figure;
colors = ['r' 'b' 'g'];
samples = fieldnames(inSituLoadingData);

hold on;
for i = 1:numel(samples)
    currentTable = inSituLoadingData.(samples{i});
    plotDisplacementLoadBounds(currentTable, [-300 300], colors(i))
end
xlabel("Relative Displacement");
ylabel("Force (lb)");
title("Baseline In Situ Force Data - Displacement vs Force")
legend(samples, "Location","southeast")

hold off;

%% Displacement vs Load
% Configs
tiledlayout(2, 3)
colors = ['r' 'b' 'g'];
samples = fieldnames(inSituLoadingData);
forceBounds = [3 300; 5 300; -10 300]; 
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
forceBounds = [3 300; 5 300; -10 300]; % in pounds
targetSlope = [20 30 40]; % in pounds / um
lengths = 1.5; % mm
widths = [.4 .46 .355]; % mm

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
% Configs
figure;
tiledlayout(2, 3)
colors = ['r' 'b' 'g'];
samples = fieldnames(inSituLoadingData);
forceBounds = [20 300; 30 300; 40 300]; % in pounds
targetSlope = [20 30 40]; % in pounds / um
lengths = 1.5; % mm
widths = [.4 .46 .355]; % mm
gaugeLength = 7.62; % mm

% Cross sections
crossSections = lengths .* widths;

% Plotting displacement vs load with min/max force bounds
for fb = 1:length(forceBounds)
    nexttile
    hold on;
    for i = 1:numel(samples)
        currentTable = inSituLoadingData.(samples{i});
        plotStrainStressBounds(currentTable, crossSections(i), gaugeLength, forceBounds(fb,:), colors(i))
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
        plotStrainStressSlope(currentTable, crossSections(i), gaugeLength, targetSlope(ts), colors(i))
    end
    xlabel("'Strain' (mm/mm)");
    ylabel("Stress (MPa)");
    title(sprintf("In Situ Force Data w/ Slope Target (%.1f lb/um)", targetSlope(ts)))
    legend(samples, "Location","southeast")

    hold off;
end

%% Poster draft plots
% Configs
colors = {[134 31 65] ./ 256, [0 118 168] ./ 256, [100 167 11] ./ 256};
samples = fieldnames(inSituLoadingData);
forceBounds = [3 300];
lengths = 1.5; % mm
widths = [.4 .46 .355]; % mm

% Cross sections
crossSections = lengths .* widths;

% Plotting displacement vs load with min/max force bounds
for i = 1:numel(samples)
    figure;
    currentTable = inSituLoadingData.(samples{i});
    plotDisplacementStressBounds(currentTable, crossSections(i), forceBounds, colors{i})

    xlabel("Relative Displacement (um)");
    ylabel("Stress (MPa)");
    title(sprintf("%s w/ Force Bounds (%dlb -> %dlb)",samples{i},forceBounds))
    ylim([0 1400])
end

%% Displacement vs stress
% Configs
colors = ['r' 'b' 'g'];
samples = fieldnames(inSituLoadingData);
forceBounds = [2.6 300]; % in pounds
lengths = 1.5; % mm
widths = [.43 .46 .355]; % mm

% Cross sections
crossSections = lengths .* widths;

% Plotting displacement vs load with min/max force bounds
figure;
hold on;
for i = 1:numel(samples)
    currentTable = inSituLoadingData.(samples{i});
    plotDisplacementStressBounds(currentTable, crossSections(i), forceBounds, colors(i))
end
xlabel("Relative Displacement (um)");
ylabel("Stress (MPa)");
title(sprintf("In Situ Force Data w/ Force Bounds (%.0flb -> %.0flb)",forceBounds))
legend(samples, "Location","southeast")

hold off;

