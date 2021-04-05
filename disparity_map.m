function [D, R, T] = disparity_map(scene_path,varargin)
    % This function receives the path to a scene folder and calculates the
    % disparity map of the included stereo image pair. Also, the Euclidean
    % motion is returned as Rotation R and Translation T.
    addpath('./functions');
    %% Input parser
    p = inputParser;
    addRequired(p,'scene_path');
    % Window size for SSD (if not set maniually, then it will be set later
    defaultBlockSize = [];
    addParameter(p,'blockSize',defaultBlockSize,@(x)isnumeric(x))
    % Window size for median filter
    defaultMedian_length = [];
    addParameter(p,'median_length',defaultMedian_length,@(x)isnumeric(x))
    % Tolerance for uniqnuess of a disparity (quality of the minimum cost), set 0
    % to turn off
    default_uniquenessThreshold = 1;
    addParameter(p,'tauUnique',default_uniquenessThreshold,@(x)isnumeric(x)&&x>=0)
    % Tolerance for consistency of disparity in both pictures (same feature
    % should have same disparity, set "inf" to turn off)
    default_distanceThreshold = 1;
    addParameter(p,'tauDist',default_distanceThreshold,@(x)isnumeric(x)&&x>0)
    % Fill Occlusion true, false
    default_occlusionFill = true;
    addParameter(p,'occlusionFill',default_occlusionFill,@islogical)
    % Filter noise true, false
    default_noiseFilter = true;
    addParameter(p,'noiseFilter',default_noiseFilter,@islogical)
    % Preprcoss Image ("off","sobel","normalize","histeq")
    default_preprocess = "histeq";
    addParameter(p,'preprocess',default_preprocess,@isstring)
    % Postprcoss Image (median filter, occlusionFill, uniqueness, consitency)
    % ("on","off")
    default_postprocess = "on";
    addParameter(p,'postprocess',default_postprocess,@isstring)
    % Set a threshold for the input image width (in pixels), if larger than customMaxWidth
    % then the input image gets scaled down to customMaxWidth for disparity
    % calculation, however, output disparity map will be same size as input image
    default_customMaxWidth = 700;
    addParameter(p,'customMaxWidth',default_customMaxWidth,@(x)isnumeric(x)&&x>0)
    % Disparity interval of the input images as a fraction of the image
    % width
    default_disparityInterval = [];
    addParameter(p,'disparityInterval',default_disparityInterval,@(x)isnumeric(x))
    % If true then plot feature correspondeces for min/max disparity
    % estimation
    default_do_plot = false;
    addParameter(p,'do_plot',default_do_plot,@islogical)
    
    parse(p,scene_path,varargin{:})
    blockSize = p.Results.blockSize;
    tauUnique = p.Results.tauUnique;
    tauDist = p.Results.tauDist;
    median_length = p.Results.median_length;
    occlusionFill = p.Results.occlusionFill;
    preprocess = p.Results.preprocess;
    postprocess = p.Results.postprocess;
    customMaxWidth = p.Results.customMaxWidth;
    disparityInterval = p.Results.disparityInterval;
    noiseFilter = p.Results.noiseFilter;
    do_plot = p.Results.do_plot;
    
    if ~isempty(disparityInterval) && (~isequal(size(disparityInterval), size(zeros(1,2)))...
            || disparityInterval(1) >= disparityInterval(2) ...
            || disparityInterval(1) < 0 ...
            || disparityInterval(2) >1)
        error(['disparityInterval lie in the interval [0 1], have size 1x2 and '...
            'value at disparityInterval(1) must be smaller than disparityInterval(2)']);
    end
    if ~isempty(blockSize) && (blockSize<0 || mod(blockSize,2) ~= 1)
        error('blockSize must be postive and odd number')
    end
    if ~isempty(median_length) && median_length<1
        error('median_length must be postive integer')
    end
    %%  Load Images
    % Update the progress bar
    update_waitbar(0,'Load stereo views ....')
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
        K1 = cam0;
        K2 = cam1;
    end
    
    % Grayscale
    I1gray = rgb_to_gray(I{1});
    I2gray = rgb_to_gray(I{2});
    % Check image size if too large then reduce
    origSize = size(I{1});
    ratio = origSize(1)/origSize(2);
    
    if origSize(2)>customMaxWidth
        width = customMaxWidth;
        scale = [ratio*width/origSize(1) width/origSize(2)];
        I1 = imageResize(I1gray,scale);
        I2 = imageResize(I2gray,scale);
    else
        I1 = I1gray;
        I2 = I2gray;
        width = origSize(2);
    end
    %% Compute R,T (Preferable not to change anything in this section)
    update_waitbar(0.03,'Computing rotation and translation...')
    n = 300;
    R = [];
    T = [];
    if origSize(2)>n
        scale = [ratio*n/origSize(1) n/origSize(2)];
        I1gray = imageResize(I1gray,scale);
        I2gray = imageResize(I2gray,scale);
        if exist('K1','var') && exist('K2','var')
            K1(1,1) = K1(1,1)*ratio*n/origSize(1);
            K1(1,3) = K1(1,3)*ratio*n/origSize(1);
            K1(2,2) = K1(2,2)*n/origSize(2);
            K1(2,3) = K1(2,3)*n/origSize(2);
            K2(1,1) = K2(1,1)*ratio*n/origSize(1);
            K2(1,3) = K2(1,3)*ratio*n/origSize(1);
            K2(2,2) = K2(2,2)*n/origSize(2);
            K2(2,3) = K2(2,3)*n/origSize(2);
        end
    else
        n = origSize(2);
    end
    seg_length = floor(0.01*n);
    if mod(seg_length,2) == 0
        seg_length = seg_length+1;
    end
    win_length = floor(0.1*n);
    if mod(win_length,2) == 0
        win_length = win_length+1;
    end
    tile_size = [round(0.1333*n),round(0.1333*n)];
    
    % Merkmalspunkte extrahieren
    Mpt1 = harris_detektor(I1gray,'segment_length',seg_length,'k',0.04,'min_dist',round(0.0267*n),'N',round(0.0133*n),'tile_size',tile_size,'do_plot',false,'tau',1e4);
    Mpt2 = harris_detektor(I2gray,'segment_length',seg_length,'k',0.04,'min_dist',round(0.0267*n),'N',round(0.0133*n),'tile_size',tile_size,'do_plot',false,'tau',1e4);
    
    % Korrespondenzpunkte berechnen
    Korrespondenzen = punkt_korrespondenzen(I1gray,I2gray,Mpt1,Mpt2,'window_length',win_length,'min_corr', 0.8, 'do_plot',do_plot);
     flag = 1;
    if size(Korrespondenzen,2) < 8
        write('Not enough feature correspondeces found for computing R and T (need atleast 8)')
        write('Continuing without calculating R and T')
        flag = 0;
    end
    
    % Robuste Korrespondenzen finden
    if exist('K1','var') && exist('K2','var') && flag
    Korrespondenzen_robust = F_ransac(Korrespondenzen, 'tolerance', 0.1,'epsilon',0.5,'p',0.99);
    if  size(Korrespondenzen_robust,2) < 8
        write('No robust correspondences found for computing R,T\n')
        write('Continuing with randomly picked feature correspondences')
        select = randperm(size(Korrespondenzen,2));
        Korrespondenzen_robust = Korrespondenzen(:,select(1:8));
    end
    
    % Essentielle Matrix mithilfe des normalisierten Achtpunktalgorithmus ausrechen
    E = achtpunktalgorithmus(Korrespondenzen_robust,K1,K2);
    
    % Moegliche T und R berechnen
    [T1, R1, T2, R2] = TR_aus_E(E);
    
    % Beste Kombination herausfinden
    [T, R] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen_robust,K1,K2);
    
    if exist('baseline','var')
        T=T*baseline*0.001;
    else
        write('No baseline found.')
    end
    
    % Zeige euklidische Transformation
%     write('Rotation Matrix:\n');
%     write('%+5.3f %+5.3f %+5.3f\n',R);
%     write('\nTranslation Vector:\n');
%     write('%+4.2f m\n',T);
    Korrespondenzen = Korrespondenzen_robust;
    end
    
    %% Minimal and maximal disparity check/estimation
    update_waitbar(0.05,'Compute max and min dispratiy')
    if isempty(disparityInterval)
        x1 = Korrespondenzen(1:2,:);
        x2 = Korrespondenzen(3:4,:);
        disparities = (x1(1,:) - x2(1,:))*width/n;
        disparities(disparities<0) = nan;
        if isempty(disparities)
            write('No confident min/max disparties found')
            dmax = round(0.4*width);
            dmin = 0;
            if exist('ndisp','var') && dmax > (ndisp-1)*width/n
                dmax = (ndisp-1)*width/n;
            end
        else
            dmax = round(1.3*max(disparities));
            dmin = 0;
            if exist('ndisp','var') && dmax > (ndisp-1)*width/n
                dmax = (ndisp-1)*width/n;
            end
            if dmax > width
                dmax = max(disparities);
            end
        end
        write('Maximum disparity is set to %4.2f percent of image width.', (round(dmax/width*100,2)));
    else
        dmax = round(disparityInterval(2)*width);
        dmin = 0;
    end
    
    %% Preprocess Image
    update_waitbar(0.08,'Preprocessing...')
    seg_length = floor(0.01*n);
    if mod(seg_length,2) == 0
        seg_length = seg_length+1;
    end
    if seg_length < 3
        seg_length = 3;
    end
    H = harrisLabel(I1,'segment_length',seg_length,'k',0.04);
    if preprocess == "sobel"
        I1 = double(gradientImage(I1));
        I2 = double(gradientImage(I2));
        
    elseif preprocess == "normalize"
        I1 = double(normalizeImage(I1));
        I2 = double(normalizeImage(I2));
    elseif preprocess == "histeq"
        
        I1 = double(histEqualization(I1));
        I2 = double(histEqualization(I2));
    elseif preprocess == "off"
        
        I1 = double(I1);
        I2 = double(I2);
    else
        error('Preprocess selection invalid')
    end
    
    %% Compute disparity map
    update_waitbar(0.1,'Compute disparity map...')
    if isempty(blockSize) && preprocess == "sobel"
        blockSize = floor(0.01*width);
        if mod(blockSize,2) == 0
            blockSize = blockSize+1;
        end
        if blockSize < 3
            blockSize = 3;
        end
    end
    if isempty(blockSize)
        blockSize = floor(0.004*width);
        if mod(blockSize,2) == 0
            blockSize = blockSize+1;
        end
        if blockSize < 3
            blockSize = 3;
        end
    end
    if isempty(median_length)
        median_length = round(0.005*width);
        if median_length < 2
            median_length = 2;
        end
    end
    D = optScanline6(I1,I2,H,blockSize,dmin,dmax,occlusionFill,tauUnique,tauDist,median_length,postprocess,noiseFilter);
    % Normalize
    D = D*(255/max(D,[],'all'));
    
    
    %% Plot left pic disparity map
    Dmap = uint8(D);
    Dmap = image2origsize(Dmap,origSize);
    D = Dmap;
    
    %waitbar done
    update_waitbar(1,'Done :)')
end
