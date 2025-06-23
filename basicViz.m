%% Making 3D volume

% Define folder containing images
folderPath = 'C:\Users\graya\Box\HE CT\sample 3\slice image\XY方向切片';

% Get list of all JPG files in folder
imageFiles = dir(fullfile(folderPath, '*.jpg'));

% Sort files by name
[~, idx] = sort({imageFiles.name});
imageFiles = imageFiles(idx);

% Read the first image to get size
firstSlice = imread(fullfile(folderPath, imageFiles(1).name));
[rows, cols, gray] = size(firstSlice);  % works if grayscale
numSlices = length(imageFiles);

% Preallocate 3D volume
volumeData = zeros(rows, cols, numSlices, 'uint8');  % change datatype if needed

bar = waitbar(0, 'Processing...');
% Loop through and read each slice
for k = 1:numSlices
    img = imread(fullfile(folderPath, imageFiles(k).name));
    if size(img,3) == 3
        img = rgb2gray(img); % convert to grayscale if needed
    end
    volumeData(:,:,k) = img;

    % Update progress
    waitbar(k/numSlices, bar, sprintf('Progress: %d%%', round((k/numSlices) * 100)))
end
close(bar)

%% Viz

volshow(volumeData);

%% Making medicalVolume object

info = struct( ...
    'PixelSpacing', [0.00055144 0.00055144], ...   % example: 0.1 mm per pixel
    'SliceThickness', 0.00055144, ...       % example: 0.1 mm between slices
    'ImageOrientationPatient', eye(2), ...
    'ImagePositionPatient', [0 0 0] ...
);

medVol = medicalVolume(volumeData, info);

% View interactively
medicalVolumeViewer(medVol);


%% Visualizing .raw files

% Path to raw file
filePath = 'C:\Users\graya\Box\HE CT\sample 3\2718-564-1986-0.55144-liewen.raw';

% Volume dimensions (example: 512x512x300)
volSize = [2718, 564, 1986];  % [rows, cols, slices]

% Data type
dataType = 'uint8';  % or 'int16', 'single', etc.

% Byte order
byteOrder = 'ieee-le';  % or 'ieee-be' if needed

% Open and read
fid = fopen(filePath, 'r');
volumeData = fread(fid, prod(volSize), dataType, 0, byteOrder);
fclose(fid);

% Reshape into 3D
volumeData = reshape(volumeData, volSize);
