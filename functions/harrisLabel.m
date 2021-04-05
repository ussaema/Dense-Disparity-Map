function Z = harrisLabel(input_image, varargin)
% Harris-Detektor, der Merkmalspunkte aus dem Bild extrahiert
% segment_length (numerisch, ungerade, >1): steuert die Groesse des Bildsegments (Standardwert: 15)
% k (numerisch, [0,1]): gewichtet zwischen Ecken- und Kantenprioritaet (In der Literatur wird
% oftmals k = 0.05 gesetzt)
% tau (numerisch, > 0): legt den Schwellenwert zur Detektion einer Ecke fest (Standardwert: ) 
% do_plot (logical): bestimmt, ob das Bild angezeigt wird oder nicht (Standardwert: False)
% min_dist (numerisch, >=1): ist der minimale Pixelabstand zweier Merkmale (Standardwert: 20)
% tile_size (numerisch): definiert die Kachelgroesse, je nach Eingabe entweder die Seitenlaenge fuer eine quadratische Kachel oder ein Vektor mit zwei Eintraegen fuer Hoehe und Breite. (Standardwert: 200)
% N (numerisch, >=1): ist die maximale Anzahl an Merkmalen innerhalb einer Kachel (Standardwert: 5)

    %% Input parser
    
    p = inputParser;
    
    addRequired(p,'input_image');
    defaultSegment_length = 11;
    addParameter(p,'segment_length',defaultSegment_length,@(x)isnumeric(x)&&x>1&&mod(x,2)==1)
    default_k = 0.05;
    addParameter(p,'k',default_k,@(x)isnumeric(x)&&x>=0&&x<=1)
    default_tauC = 1e9;
    addParameter(p,'tauC',default_tauC,@(x)isnumeric(x)&&x>0)
    default_tauE = -1e7; % -1e7 good value
    addParameter(p,'tauE',default_tauE,@(x)isnumeric(x)&&x<0)
    default_do_plot = false;
    addParameter(p,'do_plot',default_do_plot,@islogical)
    
    parse(p,input_image,varargin{:})
    segment_length = p.Results.segment_length;
    k =  p.Results.k;
    tauC = p.Results.tauC;
    tauE = p.Results.tauE;
    do_plot = p.Results.do_plot;
    
    
    %% Vorbereitung zur Feature Detektion
    % Pruefe ob es sich um ein Grauwertbild handelt
    if size(input_image,3) > 1
        error("Image format has to be NxMx1");
    end
    % Approximation des Bildgradienten
    input_image = double(input_image);
    [Ix,Iy] = sobel_xy(input_image);
    % Gewichtung
    sigma = segment_length;
    s = floor(segment_length/2);
    w = linspace(-s,s,segment_length);
    C = 1/sum(exp(-w.^2/(2*sigma^2)));
    w = C*exp(-w.^2/(2*sigma^2));
    % Harris Matrix G
    G11 = conv2(w',w,Ix.^2,'same');
    G22 = conv2(w',w,Iy.^2,'same');
    G12 = conv2(w',w,Ix.*Iy,'same');
    
    
    %% Merkmalsextraktion ueber die Harrismessung
    % Compute Kriterium
    H = (G11.*G22-G12.^2)-k*((G11+G22).^2);
    % Extract Corners
        Z = zeros(size(H));
    for i = 1:numel(H)
        if H(i) > tauC
            Z(i) = 2;
        elseif H(i) < tauE
            Z(i) = 1;
        end
    end
    
    % Plot Routine
    if do_plot
    figure
    % Display first image
    imshow(uint8(Z/2*255));hold on;
%     % Display second image with 50% transparency
%     set(h, 'AlphaData', 0.5)
%      h=imshow(uint8(input_image)); 
     end
 
    
end