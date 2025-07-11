% Plotting in situ data

load("inSituLoadingData.mat")
inSituLoadingData = rmfield(inSituLoadingData,'SampleNoH_1');

%% Plotting displacement vs load
figure;
hold on;
samples = fieldnames(inSituLoadingData);
for i = 1:numel(samples)
    currentTable = inSituLoadingData.(samples{i});
    plotDisplacementLoad(currentTable)
end
xlabel("Relative Displacement");
ylabel("Force (lb)");
title("In Situ Force Data")
legend(samples, "Location","northwest")

hold off;
