function elongation = elongationCalc(dataTable)
%ELONGATION_CALC Corrects for elongation of apparatus
%   Hard coded algorithm to remove unwanted elongation from results.

% Load data
force = dataTable.LoadCellN;

% Cross sections - mm^2
holderShaftArea = (19.1^2) * pi;
holderFlangeArea = (42.1^2) * pi;
waterCoolerArea = (42.2^2) * pi;
railGuideArea = (83.4 - 6.35)^2 * sqrt(3) / 4;
loadCellArea = (25.2^2) * pi;
bigHunkArea = (41.25^2) * pi;
screwFlangeArea = (41.25^2) * pi;
screwBaseArea = (19.1^2) * pi;
screwArea = (9.4^2) * pi;

% Starting lengths - mm
holderBottomShaftLen = 51.55;
holderTopShaftLen = 75.55;
holderFlangeLen = 3.15;
waterCoolerLen = 20.75;
railGuideLen = 9.62; 
loadCellLen = 14;
bigHunkLen = 49.7;
screwFlangeLen = 7;
screwBaseLen = 41.7;
screwLen = 15.3;

% Young's moduli
stainlessSteel = 200;
aluminum = 69;

% Stress - MPa
holderShaftStress = force ./ holderShaftArea;
holderFlangeStress= force ./ holderFlangeArea;
waterCoolerStress = force ./ waterCoolerArea;
railGuideStress   = force ./ railGuideArea;
loadCellStress    = force ./ loadCellArea;
bigHunkStress     = force ./ bigHunkArea ;
screwFlangeStress = force ./ screwFlangeArea ;
screwBaseStress   = force ./ screwBaseArea;
screwStress       = force ./ screwArea;

% Elongation - mm
holderBottomShaftElong = (holderBottomShaftLen .* holderShaftStress) ./ stainlessSteel;
holderTopShaftElong = (holderTopShaftLen .* holderShaftStress) ./ stainlessSteel;
holderFlangeElong = (holderFlangeLen .* holderFlangeStress) ./ stainlessSteel;
% waterCoolerElong = (waterCoolerLen .* waterCoolerStress) ./ aluminum;
% railGuideElong = (railGuideLen .* railGuideStress) ./ aluminum;
% loadCellElong = (loadCellLen .* loadCellStress) ./ aluminum;
% bigHunkElong = (bigHunkLen .* bigHunkStress) ./ aluminum;
% screwFlangeElong = (screwFlangeLen .* screwFlangeStress) ./ stainlessSteel; % NEED TO CHECK MATERIAL
% screwBaseElong = (screwBaseLen .* screwBaseStress) ./ stainlessSteel;
% screwElong = (screwLen .* screwStress) ./ stainlessSteel;

% Total elongation - mm
% elongation = holderBottomShaftElong + holderTopShaftElong + ...
%              holderFlangeElong + waterCoolerElong + railGuideElong + ...
%              loadCellElong + bigHunkElong + screwFlangeElong + ...
%              screwBaseElong + screwElong;
elongation = holderBottomShaftElong + holderTopShaftElong + holderFlangeElong;