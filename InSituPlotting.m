% Plotting data from aluminum tests in the in-situ load frame
% Strain rate: 7.62 um/s

%load("AlData.mat")
load("noHsampleD.mat")

%% Test 1
% 70 um incriments

absDisplacement = TimeScan4986.LoadingStageum;
relDisplacement = absDisplacement - absDisplacement(1);
strain = relDisplacement/1500;
force = TimeScan4986.LoadCelllb;

% Need to verify these numbers
width = 1.5; %mm
depth = .4; %mm
area = width*depth;
stress = force./area;

% Plotting
figure;
plot(absDisplacement,force)
xlabel("Absolute Displacement")
ylabel("Force (lb)")
hold on;

%% Test 2
% Continuous, 2.5 mm move followed by 1.5 mm move
% Issues with labview, 2.5 mm move broken into 3 sections
% This plot is only from the time after labview reset

absDisplacement2 = aluminumData.continuous.LoadingStageum;
relDisplacement2 = absDisplacement2 - absDisplacement2(1);
force2 = aluminumData.continuous.LoadCellN;

% Need to verify these numbers
width = 1.5; %mm
depth = .91; %mm
area = width*depth;
stress2 = force2./area;

% Plotting
plot(relDisplacement2,stress2)
legend("70um Incriments","Continuous","Location","northwest")
hold off;