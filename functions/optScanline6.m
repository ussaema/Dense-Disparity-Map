function D = optScanline6(I1,I2,H,winSize,dmin,dmax,occlusionFill,uniquenessThreshold,distanceThreshold,median_length,postprocess,noiseFilter)
    global Myhandles;
    %% Compute disparities for each pixel
    g = floor(winSize/2);
    [m,n] = size(I1);
    % Allocate disparity space images
    dsi2 = nan(m,n,dmax-dmin+1);
    dsi1 = dsi2;
    % Allocate raw disparity map arrays
    D1 = nan(m,n);
    D = true(size(D1));
    isNotConsistent = false(size(D1));
    isNotUnique = false(size(D1));
    % Start raw BM
    %parfor_progress(dmax+1);
    % For all disparity levels
    write('Estimating disparities...')
    % start progress bar is 0.1
    update_waitbar(0.1,'Estimating disparities...')
    for d = dmin : dmax
        % Allocate cache for SSD
        cacheSad = zeros(1,n-d);
        % Cache for window (only substracted not yet summed ub absolute values)
        cache = (I2(2:winSize,1:n-d)-I1(2:winSize,1+d:n)).^2;
        % For all rows
        for i = g+1 : m-g
            % Get lower window part of whole row
            cacheLine = (I2(i+g,1:n-d)-I1(i+g,1+d:n)).^2;
            % Move previous window of whole row one row up
            cache(1:end-1,:) = cache(2:end,:);
            % Last row is new lower window part
            cache(end,:) = cacheLine;
            % Compute first SSD
            cacheSad(1:winSize) = sum(cache(:,1:winSize),1);
            sad = sum(cacheSad(1:winSize));
            % Store in DSI
            dsi1(i,g+1+d,d-dmin+1) = sad;
            dsi2(i,g+1,d-dmin+1) = sad;
            % For all columns
            for j = 1 : size(cacheSad,2)-winSize
                % Compute SSD of ONLY right part of window and store in
                % SSD cache
                cacheSad(winSize+j) = sum(cache(:,winSize+j),1);
                % Compute SSD by substracing the right part of previous window and
                % adding right of current window
                sad = sad + cacheSad(winSize+j) - cacheSad(j);
                % Store in DSI
                dsi1(i,g+1+d+j,d-dmin+1) = sad;
                dsi2(i,g+1+j,d-dmin+1) = sad;
            end
        end
        % parfor_progress; % Count
        update_waitbar(0.1 + 0.7* d/(dmax - dmin),'Estimating disparities...')
    end
    update_waitbar(0.89,'Estimating disparities done')
    write('done.\n')
    %  parfor_progress(0);
    
    % get global mininum for each pixel
    [M,D2] = min(dsi2,[],3);
    [~,D1] = min(dsi1,[],3);
    M = ~isnan(M);
    D1 = M.*D1;
    D2 = M.*D2;
    %% Post processing
    if postprocess == "on"
        update_waitbar(0.9,'Postprocessing/Refining...')
        write('Refining...')
       if noiseFilter
            if median_length ~= 1
                D1 = mymedfilt(D1,[median_length median_length]);
            end
            if median_length ~= 1
                D2 = mymedfilt(D2,[median_length median_length]); % 7ist best
            end
        end
        [~,ind] = sort(dsi1,3);
        % Check if disparities are unique (measure for the quality of the global minimum)
        if uniquenessThreshold ~= 0
            tol = (1+0.01*uniquenessThreshold);
            for i = g+1 : m-g
                for j = g+1 : n-g
                    if dsi1(i,j,ind(i,j,2)) < dsi1(i,j,ind(i,j,1))*tol
                        D(i,j) = false;
                        isNotUnique(i,j) = true;
                    end
                end
            end
        end
        % Smooth out disparity on sub-pixel level using quadratic
        % inpterpolation
        h = size(dsi1,3);
        for i = g+1 : m-g
            for j = g+1 : n-g
                c = dsi1(i,j,ind(i,j,1));
                dis = ind(i,j,1);
                if dis > 1 && dis < h && D(i,j) == true
                    a = dsi1(i,j,ind(i,j,1)+1);
                    b = dsi1(i,j,ind(i,j,1)-1);
                    if ~isnan(a) && ~isnan(b)
                        D1(i,j) = dis + (a-b)/(2*(2*c-b-a));
                    end
                end
            end
        end
        clearvars dsi1
        clearvars dsi2
        % Check if disparities in left and right pic are consistent with
        % respect to each other (should have same disparity, or within distanceThreshold)
        % If not, then fill these ecclusion with left neighbour disparity
        if distanceThreshold ~= inf
            if occlusionFill
                for i = g+1 : m-g
                    for j = g+1 : n-g
                        a = (D1(i,j));
                        if j-round(a) > 0 && D(i,j) == true
                            b = D2(i,j-round(a));
                            if abs(a-b) > distanceThreshold
                                D1(i,j) = D1(i,j-1);
                                isNotConsistent(i,j) = true;
                            else
                                continue;
                            end
                        end
                    end
                end
            else
                for i = g+1 : m-g
                    for j = g+1 : n-g
                        a = (D1(i,j));
                        if j-round(a) > 0 && D(i,j) == true
                            b = D2(i,j-round(a));
                            if abs(a-b) > distanceThreshold
                                D1(i,j) = 0;
                                isNotConsistent(i,j) = true;
                            else
                                continue;
                            end
                        end
                    end
                end
            end
        end
        D = D.*(D1+dmin-1);
        D(D<0) = 0;
        if distanceThreshold ~= inf && occlusionFill && noiseFilter
            % Median filter along y-axsis to remove streaking effects from filling oclusion
            outputPixelValue = D;
            streak = round(0.03*m);
            Z = isNotConsistent.*D;
            Z(1:streak,:) = 0;
            Z(end-streak:end,:) = 0;
            [row,col,val] = find(Z);
            for k = 1: length(val)
                i = row(k);
                j = col(k);
                if H(i,j) ~= 1
                    window1 = D(i-streak:i-1,j);
                    window2 = D(i+1:i+streak,j);
                    m1 = mean(window1);
                    m2 = mean(window2);
                    if abs(val(k)-m1)/m1 > 0.1 && abs(val(k)-m2)/m2 > 0.1
                        outputPixelValue(i,j) =  median([window1;window2]);
                    else
                        outputPixelValue(i,j) = D(i,j) ;
                    end
                end
            end
            D = outputPixelValue;
        end
        
        %         if uniquenessThreshold ~= 0
        %             %% Median filter to remove holes
        %             hole = round(0.05*n);
        %             median_hole = floor(hole/2);
        %             outputPixelValue = D;
        %             Z = isNotUnique.*D;
        %             Z(1:median_hole,:) = 0;
        %             Z(end-median_hole:end,:) = 0;
        %             Z(:,1:median_hole) = 0;
        %             Z(:,end-median_hole:end) = 0;
        %             [row,col,val] = find(Z);
        %             for k = 1 : length(val)
        %                 i = row(k);
        %                 j = col(k);
        %                 window = D(i-median_hole:i+median_hole,j-median_hole:j+median_hole);
        %                 outputPixelValue(i,j) = median(window,'all');
        %             end
        %             D = outputPixelValue;
        %         end
        %% Median filter to remove Salt and Pepper noise on areas
        if noiseFilter
            if median_length ~= 1
                D = mymedfilt(D,[median_length median_length],H);
            end
            if median_length ~= 1
                D = mymedfilt(D,[median_length median_length],H,1);
            end
        end
        %         if median_length ~= 1
        %             D = mymedfilt(D,[median_length 0],H);
        %         end
        %
        
        write('done.\n')
        %
        %         % Adjustment technique: reduces disparity of noise from overestimating dmax
        %         % to a more probable real dmax value, however doesn't remove the noise
        %         Z = ceil(D);
        %         q = max(Z(:));
        %         count = sum(D > q-1,'all');
        %         while count < 0.003*size(D(:),1) %% 0.02 WERT KANN OPTIMIERT WERDEN %%%
        %             Z(Z==q) = 0;
        %             q = max(Z(:));
        %             count = sum(D > q-1,'all');
        %         end
        %         D(D>q) = q;
        
        
    else
        
        % minus 1 because D is array of indices and array starts with index 1
        D = D.*(D1+dmin-1);
        D(D<0) = 0;
    end
end





