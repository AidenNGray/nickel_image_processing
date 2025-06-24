function blockedImg = convertLargeRawToBlockedImage(rawFilePath, dimensions, dataType, byteOrder, varargin)
% CONVERTLARGERAWTOBLOCKEDIMAGE Convert large .raw file to BlockedImage
%
% INPUTS:
%   rawFilePath - Path to the .raw file
%   dimensions  - [x, y, z] dimensions of the 3D image
%   dataType    - Data type string (e.g., 'uint16', 'single', 'double')
%   byteOrder   - Byte order ('ieee-le' for little-endian, 'ieee-be' for big-endian)
%
% OPTIONAL NAME-VALUE PAIRS:
%   'BlockSize'     - Block size for processing [default: [512, 512, 64]]
%   'OutputDir'     - Directory for output files [default: tempdir]
%   'Verbose'       - Display progress [default: true]
%   'Format'        - Output format 'tiff' or 'h5' [default: 'tiff']
%
% OUTPUT:
%   blockedImg - BlockedImage object
%
% EXAMPLE:
%   dimensions = [2718, 1024, 512];
%   blockedImg = convertLargeRawToBlockedImage('data.raw', dimensions, 'uint16', 'ieee-le');

% Parse input arguments
p = inputParser;
addRequired(p, 'rawFilePath', @(x) ischar(x) || isstring(x));
addRequired(p, 'dimensions', @(x) isnumeric(x) && length(x) == 3);
addRequired(p, 'dataType', @(x) ischar(x) || isstring(x));
addRequired(p, 'byteOrder', @(x) ischar(x) || isstring(x));
addParameter(p, 'BlockSize', [512, 512, 64], @(x) isnumeric(x) && length(x) == 3);
addParameter(p, 'OutputDir', tempdir, @(x) ischar(x) || isstring(x));
addParameter(p, 'Verbose', true, @islogical);
addParameter(p, 'Format', 'tiff', @(x) ismember(lower(x), {'tiff', 'h5'}));

parse(p, rawFilePath, dimensions, dataType, byteOrder, varargin{:});

% Extract parsed values
rawFile = p.Results.rawFilePath;
dims = p.Results.dimensions;
dtype = p.Results.dataType;
border = p.Results.byteOrder;
blockSize = p.Results.BlockSize;
outputDir = p.Results.OutputDir;
verbose = p.Results.Verbose;
outputFormat = lower(p.Results.Format);

% Validate inputs
if ~exist(rawFile, 'file')
    error('Raw file does not exist: %s', rawFile);
end

% Get file size and validate
fileInfo = dir(rawFile);
expectedSize = prod(dims) * getBytesPerElement(dtype);
if abs(fileInfo.bytes - expectedSize) > 1000  % Allow small tolerance
    warning('File size (%d bytes) differs from expected size (%d bytes)', ...
        fileInfo.bytes, expectedSize);
end

if verbose
    fprintf('Processing %s\n', rawFile);
    fprintf('Dimensions: %dx%dx%d\n', dims(1), dims(2), dims(3));
    fprintf('Data type: %s\n', dtype);
    fprintf('Block size: %dx%dx%d\n', blockSize(1), blockSize(2), blockSize(3));
    fprintf('Output format: %s\n', outputFormat);
end

% Create output directory
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outputPath = fullfile(outputDir, ['blocked_image_' timestamp]);
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

% Convert based on format
switch outputFormat
    case 'tiff'
        blockedImg = convertToBlockedTiff(rawFile, dims, dtype, border, blockSize, outputPath, verbose);
    case 'h5'
        blockedImg = convertToBlockedHDF5(rawFile, dims, dtype, border, blockSize, outputPath, verbose);
end

if verbose
    fprintf('BlockedImage created successfully!\n');
    fprintf('Image size: [%s]\n', num2str(blockedImg.Size));
    fprintf('Block size: [%s]\n', num2str(blockedImg.BlockSize));
    fprintf('Number of blocks: [%s]\n', num2str(blockedImg.NumBlocks));
    
    % Test reading a small region
    try
        testRegion = blockedImg(1:min(100, dims(1)), 1:min(100, dims(2)), 1:min(10, dims(3)));
        fprintf('Test read successful - sample value: %.2f\n', double(testRegion(1,1,1)));
    catch ME
        warning(sprintf('Test read failed: %s', ME.message));
    end
end

end

function blockedImg = convertToBlockedTiff(rawFile, dims, dtype, border, blockSize, outputPath, verbose)
% Convert raw file to blocked TIFF format using BlockedImageDatastore

% Calculate number of blocks needed
numBlocks = ceil(dims ./ blockSize);
totalBlocks = prod(numBlocks);

if verbose
    fprintf('Converting to TIFF format...\n');
    fprintf('Will create %d blocks total\n', totalBlocks);
end

% Create a single large TIFF file instead of multiple blocks
tiffFilename = fullfile(outputPath, 'image_data.tif');

% Open raw file
fid = fopen(rawFile, 'r', border);
if fid == -1
    error('Could not open raw file: %s', rawFile);
end

try
    if verbose
        fprintf('Writing to single TIFF file: %s\n', tiffFilename);
    end
    
    % Process slice by slice to create a single TIFF file
    for z = 1:dims(3)
        if verbose && mod(z, 50) == 0
            fprintf('Processing slice %d/%d (%.1f%%)\n', z, dims(3), 100*z/dims(3));
        end
        
        % Read entire slice
        slice = readRawSlice(fid, dims, dtype, z);
        
        % Write slice to TIFF
        if z == 1
            imwrite(slice, tiffFilename, 'WriteMode', 'overwrite', 'Compression', 'none');
        else
            imwrite(slice, tiffFilename, 'WriteMode', 'append', 'Compression', 'none');
        end
    end
    
    fclose(fid);
    
    % Create BlockedImageDatastore
    bids = blockedImageDatastore(tiffFilename, 'BlockSize', blockSize);
    
    % Create BlockedImage from datastore
    blockedImg = blockedImage(bids);
    
catch ME
    fclose(fid);
    rethrow(ME);
end

end

function blockedImg = convertToBlockedHDF5(rawFile, dims, dtype, border, blockSize, outputPath, verbose)
% Convert raw file to blocked HDF5 format

h5Filename = fullfile(outputPath, 'blocked_image.h5');
datasetName = '/image';

if verbose
    fprintf('Converting to HDF5 format...\n');
    fprintf('Output file: %s\n', h5Filename);
end

% Create HDF5 file with chunked dataset
h5create(h5Filename, datasetName, dims, 'DataType', dtype, 'ChunkSize', blockSize);

% Open raw file
fid = fopen(rawFile, 'r', border);
if fid == -1
    error('Could not open raw file: %s', rawFile);
end

% Calculate number of blocks
numBlocks = ceil(dims ./ blockSize);
totalBlocks = prod(numBlocks);
blockCount = 0;

try
    % Process each block
    for bz = 1:numBlocks(3)
        for by = 1:numBlocks(2)
            for bx = 1:numBlocks(1)
                blockCount = blockCount + 1;
                
                if verbose && mod(blockCount, 10) == 0
                    fprintf('Processing block %d/%d (%.1f%%)\n', ...
                        blockCount, totalBlocks, 100*blockCount/totalBlocks);
                end
                
                % Calculate block boundaries
                startPos = [(bx-1)*blockSize(1)+1, (by-1)*blockSize(2)+1, (bz-1)*blockSize(3)+1];
                endPos = [min(bx*blockSize(1), dims(1)), min(by*blockSize(2), dims(2)), min(bz*blockSize(3), dims(3))];
                actualBlockSize = endPos - startPos + 1;
                
                % Read block data
                blockData = readRawBlock(fid, dims, dtype, startPos, actualBlockSize);
                
                % Write block to HDF5
                h5write(h5Filename, datasetName, blockData, startPos, actualBlockSize);
            end
        end
    end
    
    fclose(fid);
    
    % Create BlockedImage from HDF5 file
    blockedImg = blockedImage(h5Filename, datasetName);
    
catch ME
    fclose(fid);
    if exist(h5Filename, 'file')
        delete(h5Filename);
    end
    rethrow(ME);
end

end

function blockData = readRawBlock(fid, dims, dtype, startPos, blockSize)
% Read a block of data from the raw file

% Pre-allocate block data
blockData = zeros(blockSize, dtype);

% Calculate strides
elementsPerSlice = dims(1) * dims(2);
elementsPerRow = dims(1);
bytesPerElement = getBytesPerElement(dtype);

% Read block slice by slice
for z = 1:blockSize(3)
    currentZ = startPos(3) + z - 1;
    
    for y = 1:blockSize(2)
        currentY = startPos(2) + y - 1;
        
        % Calculate file position for this row
        filePos = ((currentZ - 1) * elementsPerSlice + (currentY - 1) * elementsPerRow + (startPos(1) - 1)) * bytesPerElement;
        
        % Seek to position and read row
        fseek(fid, filePos, 'bof');
        rowData = fread(fid, blockSize(1), dtype);
        
        % Handle partial reads at boundaries
        if length(rowData) < blockSize(1)
            paddedData = zeros(blockSize(1), 1, dtype);
            paddedData(1:length(rowData)) = rowData;
            rowData = paddedData;
        end
        
        % Store in block data
        blockData(:, y, z) = rowData;
    end
end

end

function writeBlockToTiff(filename, blockData, dtype)
% Write block data to multi-page TIFF file

% Convert data type if necessary for TIFF compatibility
if strcmp(dtype, 'single') || strcmp(dtype, 'double')
    % Normalize floating point data to 16-bit
    minVal = min(blockData(:));
    maxVal = max(blockData(:));
    if maxVal > minVal
        blockData = uint16((double(blockData) - minVal) / (maxVal - minVal) * 65535);
    else
        blockData = uint16(blockData);
    end
end

% Write each slice as a TIFF page
for z = 1:size(blockData, 3)
    slice = blockData(:, :, z);
    if z == 1
        imwrite(slice, filename, 'WriteMode', 'overwrite');
    else
        imwrite(slice, filename, 'WriteMode', 'append');
    end
end

end

function bytes = getBytesPerElement(dataType)
% Get number of bytes per element for different data types

switch lower(dataType)
    case {'uint8', 'int8'}
        bytes = 1;
    case {'uint16', 'int16'}
        bytes = 2;
    case {'uint32', 'int32', 'single'}
        bytes = 4;
    case {'uint64', 'int64', 'double'}
        bytes = 8;
    otherwise
        error('Unsupported data type: %s', dataType);
end

end

% Utility function to test the blocked image
function testBlockedImage(blockedImg, verbose)
% Test various operations on the blocked image

if nargin < 2
    verbose = true;
end

if verbose
    fprintf('\n=== Testing BlockedImage ===\n');
end

try
    % Test 1: Basic properties
    if verbose
        fprintf('Image size: [%s]\n', num2str(blockedImg.Size));
        fprintf('Block size: [%s]\n', num2str(blockedImg.BlockSize));
        fprintf('Data type: %s\n', class(blockedImg));
    end
    
    % Test 2: Read a small region
    dims = blockedImg.Size;
    testSize = min([100, 100, 10], dims);
    testRegion = blockedImg(1:testSize(1), 1:testSize(2), 1:testSize(3));
    
    if verbose
        fprintf('Test region size: [%s]\n', num2str(size(testRegion)));
        fprintf('Sample values: [%.2f, %.2f, %.2f]\n', ...
            double(testRegion(1,1,1)), double(testRegion(end,end,end)), double(testRegion(50,50,1)));
    end
    
    % Test 3: Compute basic statistics on a subset
    stats = struct();
    stats.min = min(testRegion(:));
    stats.max = max(testRegion(:));
    stats.mean = mean(testRegion(:));
    stats.std = std(double(testRegion(:)));
    
    if verbose
        fprintf('Statistics (test region):\n');
        fprintf('  Min: %.2f\n', double(stats.min));
        fprintf('  Max: %.2f\n', double(stats.max));
        fprintf('  Mean: %.2f\n', double(stats.mean));
        fprintf('  Std: %.2f\n', stats.std);
        fprintf('Test completed successfully!\n');
    end
    
catch ME
    if verbose
        fprintf('Test failed: %s\n', ME.message);
    end
    rethrow(ME);
end

end

% Example usage function
function example_usage()
% Example of how to use the converter

% Define your file parameters
rawFilePath = 'your_large_file.raw';  % Replace with your file path
dimensions = [2718, 1024, 512];       % Replace with your dimensions [x, y, z]
dataType = 'uint16';                  % Replace with your data type
byteOrder = 'ieee-le';                % Replace with your byte order

% Convert to BlockedImage (HDF5 format recommended for large files)
blockedImg = convertLargeRawToBlockedImage(rawFilePath, dimensions, dataType, byteOrder, ...
    'BlockSize', [512, 512, 64], ...
    'Format', 'h5', ...
    'Verbose', true);

% Test the blocked image
testBlockedImage(blockedImg);

% Example operations:
% Get a region of interest (this will work even though x > 2048)
roi = blockedImg(1:1000, 1:500, 1:100);

% Apply processing to blocks
% result = apply(blockedImg, @(block) imgaussfilt3(block, 1));

% Compute statistics on the full image (may take time)
% meanValue = mean(blockedImg, 'all');

fprintf('\nConversion complete! You can now work with your large image.\n');

end