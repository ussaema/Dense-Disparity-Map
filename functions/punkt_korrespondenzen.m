function Korrespondenzen = punkt_korrespondenzen(I1,I2,Mpt1,Mpt2,varargin)
    global Myhandles;
    global stereo_images;
    % In dieser Funktion sollen die extrahierten Merkmalspunkte aus einer
    % Stereo-Aufnahme mittels NCC verglichen werden um Korrespondenzpunktpaare
    % zu ermitteln.
    % window_length (numerisch, ungerade, > 1) Seitenlaenge des quadratischen Fensters um die Merkmalspunkte, welche untereinander verglichen werden (Standardwert = 25)
    % min_corr (numerisch, (0,1)) Unterer Schwellwert fuer die staerke der Korrelation zweier Merkmale (Standardwert = 0.95)
    % do_plot (logical) bestimmt, ob das Bild angezeigt wird oder nicht (Standardwert = False)
    
    %% Input parser
    p = inputParser;
    % Add required I1,I2,Mpt1,Mpt2
    addRequired(p,'I1');
    addRequired(p,'I2');
    addRequired(p,'Mpt1');
    addRequired(p,'Mpt2');
    % Add optional parameters
    defaultwindow_length = 25;
    addParameter(p,'window_length',defaultwindow_length,@(x)isnumeric(x)&&x>1&&mod(x,2)==1)
    default_min_corr = 0.95;
    addParameter(p,'min_corr',default_min_corr,@(x)isnumeric(x)&&x>0&&x<1)
    default_do_plot = false;
    addParameter(p,'do_plot',default_do_plot,@islogical)
    
    parse(p,I1,I2,Mpt1,Mpt2,varargin{:})
    window_length = p.Results.window_length;
    min_corr =  p.Results.min_corr;
    do_plot = p.Results.do_plot;
    
    % Convert Images to double
    I1 = double(I1);
    I2 = double(I2);
      
    %% Merkmalsvorbereitung
    win = floor(window_length/2);
    % vertical window_length
    v = window_length;
    vm = floor(v/2);
    % Filter Merkmale from Mpt1
    [m,n] = size(I1);
    % First Merkmale close to right and bottom border
    Mpt1 = Mpt1 + [win;vm];
    Mpt1(Mpt1>[n;m]) = 0;
    Mpt1 = Mpt1(:,all(Mpt1));
    % Second Merkmale close to left and upper border
    Mpt1 = Mpt1 - 2*[win;vm];
    Mpt1 (Mpt1 <[1;1]) = 0;
    Mpt1  = Mpt1 (:,all(Mpt1));
    Mpt1  = Mpt1  + [win;vm];
    
    % Filter Merkmale from Mpt2
    [m,n] = size(I2);
    % First Merkmale close to right and bottom border
    Mpt2 = Mpt2 + [win;vm];
    Mpt2(Mpt2>[n;m]) = 0;
    Mpt2 = Mpt2(:,all(Mpt2));
    % Second Merkmale close to left and upper border
    Mpt2 = Mpt2 - 2*[win;vm];
    Mpt2 (Mpt2 <[1;1]) = 0;
    Mpt2  = Mpt2 (:,all(Mpt2));
    Mpt2  = Mpt2  +[win;vm];
    
    %% Normierung
    l = window_length*v;
    win = floor(window_length/2);
    % For I1
    n = size(Mpt1,2);
    Mat_feat_1 = zeros(l,n);
    for i = 1 : n
        % Get Bildausschnitt
        W = double(I1(Mpt1(2,i)-vm : Mpt1(2,i)+vm , Mpt1(1,i)-win : Mpt1(1,i)+win));
        % Compute Mean
        mu = mean(W,'all');
        Wsub = W-mu;
        % Compute Standartdeviation
        sigma = std(W,0,'all')+1e-11;
        % Normalize
        W = Wsub/sigma;
        % Vectorize
        Mat_feat_1(:,i) = W(:);
    end
    
    % For I2
    n = size(Mpt2,2);
    Mat_feat_2 = zeros(l,n);
    for i = 1 : n
        % Get Bildausschnitt
        W = double(I2(Mpt2(2,i)-vm : Mpt2(2,i)+vm , Mpt2(1,i)-win : Mpt2(1,i)+win));
        % Compute Mean
        mu = mean(W,'all');
        Wsub = W-mu;
        % Compute Standartdeviation
        sigma = std(W,0,'all')+1e-11;
        % Normalize
        W = Wsub/sigma;
        % Vectorize
        Mat_feat_2(:,i) = W(:);
    end
        
    %% NCC Brechnung
    % Compute NCC_Matrix
    NCC_matrix = Mat_feat_2'*(Mat_feat_1./(window_length*v-1));
    % Set all entries smaller than min_corr to 0
    NCC_matrix(NCC_matrix < min_corr) = 0;
    % Sort in descending order
    [A,sorted_index] = sort(NCC_matrix(:),'descend');
    sorted_index = sorted_index(A~=0);
   %% Korrespondenz
    l  = length(sorted_index);
    [m,n] = size(NCC_matrix);
    Korrespondenzen = zeros(4,l);
    for i = 1 : l
        % Index to row and col index
         [x,y] = ind2sub([m,n],sorted_index(i));
         if NCC_matrix(x,y)
         % Save merkmal coordinates
         Korrespondenzen(:,i) = [Mpt1(:,y);Mpt2(:,x)];
         NCC_matrix(:,y) = 0;
         end
    end
    Korrespondenzen = Korrespondenzen(:,any(Korrespondenzen));
    Korrespondenzen(:,all(Korrespondenzen==0))=[];
    [~,ia1,~]=unique(Korrespondenzen(1:2,:)','rows','stable');
    Korrespondenzen=Korrespondenzen(:,ia1);
    [~,ia2,~]=unique(Korrespondenzen(3:4,:)','rows','stable');
    Korrespondenzen=Korrespondenzen(:,ia2);
    
    if do_plot
        m1 = Korrespondenzen(1:2,:);
        m2 = Korrespondenzen(3:4,:);
        figure
        % Display first image
        imshow(uint8(I1)); hold on;
        % Display second image with 50% transparency
        h = imshow(uint8(I2));
        set(h, 'AlphaData', 0.4)
        % Plot and connect corresponding Merkmale
            for i = 1 : size(Korrespondenzen,2)
                plot(m1(1,i),m1(2,i),'rx');
                plot(m2(1,i),m2(2,i),'gx');
                plot([m1(1,i),m2(1,i)],[m1(2,i),m2(2,i)],'b-');
            end
            hold off;

end