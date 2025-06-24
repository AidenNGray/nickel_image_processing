% Your file parameters
rawFilePath = 'C:\Users\graya\Box\HE CT\sample 3\2718-564-1986-0.55144-liewen.raw';
dimensions = [2718, 564, 1986];  % [x, y, z] - note x > 2048
dataType = 'uint8';             % or 'single', 'double', etc.
byteOrder = 'ieee-le';           % or 'ieee-be'

% Convert to blocked image
blockedImg = convertLargeRawToBlockedImage(rawFilePath, dimensions, dataType, byteOrder, ...
    'Format', 'h5');

% Now you can work with it normally
roi = blockedImg(1:1000, 1:500, 1:100);  % Extract region of interest
filteredImg = apply(blockedImg, @(block) imgaussfilt3(block, 1));  % Apply filters