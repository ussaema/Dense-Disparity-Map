function reconstruct3d(DisparityMap,focalLength,baseline,doffs,calMatrix,Image)
    global Myhandles;
    
    %% 3D Reconstruction of a rectified stereo scene
    % DisparityMap: disparity map
    % focalLength: focal length in pixels
    % baseline: camera baseline in mm
    % doffs: x-difference of principal points
    % calMatrix: calibration matrix of the camera
    % Image: Color/Gray Image of corresponding Disparity Map 
    % Line 60 - 64 are for limiting x and y axis, comment out if not wished
    
    f = focalLength;
    D = double(DisparityMap);
    D = 255*(D-min(D(:)))/(max(D(:))-min(D(:)));
    D(D==0) = NaN;
    % Compute depth z in worldcoordinates
    z = baseline*f./(D + doffs);
    z = z(:);
    % Compute x and y ind worldcoordinates
    [row,col] = ind2sub(size(D),1:numel(D));
    imCoor = calMatrix\[col;row;ones(1,numel(D))];
    x = imCoor(1,:)'.*(z/f);
    y = imCoor(2,:)'.*(z/f);
    % Under the assumpation that calibration matrix and baseline is given
    % in mm, rescale
    z = z*0.001;
    
    % Get RGB color from image
    if size(Image,3) > 1
        R = Image(:,:,1);
        R = R(:);
        G = Image(:,:,2);
        G = G(:);
        B = Image(:,:,3);
        B = B(:);
        
        RGB = double([R,G,B])/255;
    else
        RGB =  Image(:,:,3);
        RGB = RGB(:);
    end
    
    % Plot max 200000 samples, comment out if not wished
    if numel(D)>200000
        step = round(numel(D)/200000);
        take = false(size(x));
        for i = 1 :step: length(x)
            take(i) = true;
        end
    else
        take = true(size(x));
    end
    x = x(take);
    y = y(take);
    z = z(take);
    RGB=RGB(take,:);
    A = [x,y,z,RGB];
    % Set axis limits and remove all value extending these limits, can
    % change if too small
    for i = 1 :length(x)
        if x(i)>1 || y(i)>1 || x(i)<-1 || y(i)<-1
            A(i,:) = nan;
        end
    end
    x = A(:,1);
    y = A(:,2);
    z = A(:,3);
    RGB = A(:,4:end);
    S = 5;
    % Acutal plot
    if isempty(Myhandles)
        figure()
        scatter3(x,y,z,S,RGB,'.')
    else
        
        h=Myhandles.disparity_map;
        if ~ishandle(h)
            figure()
            scatter3(x,y,z,S,RGB,'.')
            return
        else
            axis(h);
            scatter3(x,y,z,S,RGB,'.')
        end
    end
    
end
    % Make reconstruction more robust aganst potential noise from too small
    % by removing
    % those comment out if not wished
%     notnan = sum(~isnan(D),'all');
%     Z = ceil(D);
%     q = min(Z(:));
%     count = nansum(D < q,'all');
%     while count < 0.02*notnan %% 0.02 WERT KANN OPTIMIERT WERDEN %%%
%         Z(Z==q) = nan;
%         q = min(Z(:));
%         count = nansum(D < q,'all');
%     end
%     D(D<q) = 0;
    % end removing noise
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
