function merkmale = harris_detektor(input_image, varargin)
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
    defaultSegment_length = 15;
    addParameter(p,'segment_length',defaultSegment_length,@(x)isnumeric(x)&&x>1&&mod(x,2)==1)
    default_k = 0.05;
    addParameter(p,'k',default_k,@(x)isnumeric(x)&&x>=0&&x<=1)
    default_tau = 1e6;
    addParameter(p,'tau',default_tau,@(x)isnumeric(x)&&x>0)
    default_do_plot = false;
    addParameter(p,'do_plot',default_do_plot,@islogical)
    default_min_dist = 20;
    addParameter(p,'min_dist',default_min_dist,@(x)isnumeric(x)&&x>=1)
    default_tile_size= [200,200];
    addParameter(p,'tile_size',default_tile_size,@(x)isnumeric(x))
    default_N = 5;
    addParameter(p,'N',default_N,@(x)isnumeric(x)&&x>=1)
    
    parse(p,input_image,varargin{:})
    segment_length = p.Results.segment_length;
    k =  p.Results.k;
    tau = p.Results.tau;
    do_plot = p.Results.do_plot;
    min_dist = p.Results.min_dist;
    N = p.Results.N;
    tile_size = p.Results.tile_size;
    if isscalar(tile_size)
        tile_size = [tile_size, tile_size];
    end
    
    
    %% Vorbereitung zur Feature Detektion
    % Pruefe ob es sich um ein Grauwertbild handelt
    if size(input_image,3) > 1
        error("Image format has to be NxMx1");
    end
    % Approximation des Bildgradienten
    input_image = double(input_image);
    [Ix,Iy] = sobel_xy(input_image);
    % Gewichtung
    s = floor(segment_length/2);
    sigma = s;
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
    corners = H;
    corners(corners<tau)=0;
    
    %% Merkmalsvorbereitung
    % Get dimensions of image
    [m,n] = size(input_image);
    % Compute corners with zeros at border
    % [00000000000
    %  00corners00
    %  00000000000]
    zero_borderHori = zeros(min_dist,n+2*min_dist);
    zero_borderVert = zeros(m,min_dist);
    corners = [zero_borderHori;
               zero_borderVert,corners,zero_borderVert;
               zero_borderHori];
    [m,n] = size(corners);
    % Sort Merkmale and index
    [A,sorted_index] = sort(reshape(corners,[m*n,1]),'descend');
    sorted_index = sorted_index(A~=0);
    
    %% Akkumulatorfeld
    AKKA = zeros(ceil(size(input_image,1)/tile_size(1)),ceil(size(input_image,2)/tile_size(2)));
    % Create empty merkmale array
    merkmale=zeros(2,min(numel(AKKA)*N,numel(sorted_index)));
    
    %% Merkmalsbestimmung mit Mindestabstand und Maximalzahl pro Kachel
    
    % Compute Cake
    Cake = cake(min_dist);
    % Count Number of extracted Merkmale
    count = 0;
    % length of sorted_index
    l = length(sorted_index);

    % Extract Merkmale
    for i = 1 : l
        % Pixel-Coordinates of inspected Merkmal in Corners-coordinates
        [x,y] = ind2sub(size(corners),sorted_index(i));
        % Transform Coordinates into input_image coordinates
        xp = x - min_dist;
        yp = y - min_dist;
        % Check if merkmal still exists or already deleted due to min_dist
        if corners(x,y) ~= 0
            % Get Kachel, hence akkumulatorfeld's coordnates
            xak = ceil(xp/tile_size(1));
            yak = ceil(yp/tile_size(2));
            % Check if Kachel is already full and if not then extract merkmal
            if AKKA(xak,yak) < N
                count = count + 1;
                % Save extracted Merkmal's oordinates
                merkmale(:,count) = [yp,xp]';
                AKKA(xak,yak) = AKKA(xak,yak) + 1;
                % Delete current Merkmal and all Merkmale surrounding the current Merkmale with radius min_dist
                corners(x - min_dist : x + min_dist,y - min_dist : y + min_dist) = ...
                    corners(x - min_dist : x + min_dist,y - min_dist : y + min_dist).*Cake;

            end
        end
    end

    merkmale = merkmale(:,1:count);
        
        


    
    % Plot Routine
    if do_plot
    m1 = merkmale(1:2,:);
    figure
    % Display first image
    imshow(uint8(input_image)); hold on;
    % Plot and connect corresponding Merkmale
    plot(m1(1,:),m1(2,:),'og')
    end
    

    function Cake = cake(min_dist)
    % Die Funktion cake erstellt eine "Kuchenmatrix", die eine kreisfoermige
    % Anordnung von Nullen beinhaltet und den Rest der Matrix mit Einsen
    % auffuellt. Damit koennen, ausgehend vom staerksten Merkmal, andere Punkte
    % unterdrueckt werden, die den Mindestabstand hierzu nicht einhalten. 
    % Compute mesh of coordinates
    [X,Y]=meshgrid(-min_dist:min_dist,[-min_dist:-1,0:min_dist]);
    % Compute Cake
    Cake=sqrt(X.^2+Y.^2)>min_dist;
    
    end
    
end