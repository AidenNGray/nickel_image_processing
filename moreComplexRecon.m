%% Setup

% Define source and output paths
imageDir = 'C:\Users\graya\Box\HE CT\sample 3\slice image\XY方向切片';
outputTiff = fullfile('C:\Users\graya\MATLAB\Projects\nickel_image_processing\outputs', 'volume_blocked.tif');

% Define block size (adjust depending on your system)
blockSize = [128 128 32];

% Get sorted list of image files
imageFiles = dir(fullfile(imageDir, '*.jpg'));
[~, idx] = sort({imageFiles.name});
imageFiles = imageFiles(idx);

% Read metadata from first slice
sample = imread(fullfile(imageDir, imageFiles(1).name));
if size(sample,3) == 3
    sample = rgb2gray(sample);
end
[rows, cols] = size(sample);
numSlices = numel(imageFiles);

% Predefine the full volume size
volumeSize = [rows, cols, numSlices];

% Create blocked image object on disk
tempBlockedPath = fullfile(tempdir, 'blocked_volume_temp');
bim = createNewBlockedImage( ...
    fullfile(tempBlockedPath, 'volume.bim'), ...
    [rows, cols, numSlices], ...
    'BlockSize', blockSize, ...
    'ClassUnderlying', 'uint8');

%% Processing

% Loop over Z in block-sized chunks
for zStart = 1:blockSize(3):numSlices
    zEnd = min(zStart + blockSize(3) - 1, numSlices);
    blockDepth = zEnd - zStart + 1;
    
    % Preallocate this block
    block = zeros(rows, cols, blockDepth, 'uint8');
    
    for k = 1:blockDepth
        idx = zStart + k - 1;
        img = imread(fullfile(imageDir, imageFiles(idx).name));
        if size(img,3) == 3
            img = rgb2gray(img);
        end
        block(:,:,k) = img;
    end
    
    % Write this block into the blockedImage
    bim(:, :, zStart:zEnd) = block;
end

writeBlockedImage(bim, outputTiff, ...
    'Compression', 'lzw', ...
    'Overwrite', true);
