    %% Run this script after running Challenge for 3D reconstruction
   % read images
    myFolder = scene_path;
    if ~isfolder(myFolder)
        error('Error: The following folder does not exist:\n%s', myFolder);
    end
    filePattern = fullfile(myFolder, '*.png');
    pngFiles = dir(filePattern);
    if length(pngFiles) ~= 2
        error('Error: Number of .png files in directory must be exactly 2.');
    end
    I = cell(2,1);
    for k = 1 : 2
        baseFileName = pngFiles(k).name;
        fullFileName = fullfile(myFolder, baseFileName);
        write('Now reading %s\n', fullFileName);
        I{k} = imread(fullFileName);
    end
    % read calib.txt
    filePattern = fullfile(myFolder, '*calib.txt');
    txtFiles = dir(filePattern);
    if isempty(txtFiles)
        write('Error: No calib.txt files in directory found./n')
        write('Continuing without')
    else
        baseFileName = txtFiles.name;
        fullFileName = fullfile(myFolder, baseFileName);
        write('Now reading %s\n', fullFileName);
        data = importdata(fullFileName);
        for i = 1:size(data,1)
            eval(data{i});
        end
    end
    % 3D reconstruction, D is Disparity map, Substitue D for G for Ground
    % Truth 3D reconstruction
    reconstruct3d(D,cam0(1),baseline,doffs,cam0,I{1})