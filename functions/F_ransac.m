function [Korrespondenzen_robust,F] = F_ransac(Korrespondenzen, varargin)
    % Diese Funktion implementiert den RANSAC-Algorithmus zur Bestimmung von
    % robusten Korrespondenzpunktpaaren
    
    %% Input parser
    % Bekannte Variablen:
    % epsilon       geschätzte Wahrscheinlichkeit
    % p             gewünschte Wahrscheinlichkeit
    % tolerance     Toleranz um als Teil des Consensus-Sets zu gelten
    % x1_pixel      homogene Pixelkoordinaten
    % x2_pixel      homogene Pixelkoordinaten
    p = inputParser;
    % nötige Korrespodenzen
    addRequired(p,'Korrespondenzen')
    %opt Paras
    defaultEpsilon=0.5;
    addParameter(p,'epsilon',defaultEpsilon,@(x)isnumeric(x)&&(x>0)&&(x<1));
    defaultP=0.5;
    addParameter(p,'p',defaultP,@(x)isnumeric(x)&&(x>0)&&(x<1));
    defaultTolerance=0.01;
    addParameter(p,'tolerance',defaultTolerance,@(x)isnumeric(x));
    defaultk = 8;
    addParameter(p,'k',defaultk,@(x)isnumeric(x)&&x>=8);
    
    parse(p,Korrespondenzen,varargin{:});
    epsilon=p.Results.epsilon;
     tolerance=p.Results.tolerance;
      k=p.Results.k;
    p=p.Results.p;

    
    x1_pixel= Korrespondenzen(1:2,:);
    x2_pixel= Korrespondenzen(3:4,:);
    homx1 = [x1_pixel;ones(1,size(x1_pixel,2))];
    homx2 = [x2_pixel;ones(1,size(x2_pixel,2))];
    
    %% RANSAC Algorithmus Vorbereitung
    % Vorinitialisierte Variablen:
    % k                     Anzahl der benötigten Punkte
    % s                     Iterationszahl
    % largest_set_size      Größe des bisher größten Consensus-Sets
    % largest_set_dist      Sampson-Distanz des bisher größten Consensus-Sets
    % largest_set_F         Fundamentalmatrix des bisher größten Consensus-Sets
    s=log(1-p)/(log(1-(1-epsilon)^k));
    largest_set_size=0;
    largest_set_dist=inf;
    
    %% RANSAC Algorithmus
    
    %%1. F berechnen
    [~,n]=size(Korrespondenzen);
    for i=1:s
        zufall = randperm(n);
        F = achtpunktalgorithmus(Korrespondenzen(:,zufall(1:8)));
    
        %%2. Sampson Distanz berechnen
        sd = sampson_dist(F, homx1, homx2);
    
        %%3. Consensus-Set
        z=sd<tolerance;
        consensus = Korrespondenzen(:,z);
    
        %%4.
        set_size=size(consensus,2);
        set_dist=sum(sd(z),2);
    
        %%5
        if set_size>largest_set_size
            largest_set_size=set_size;
            Korrespondenzen_robust=consensus;
        elseif set_size==largest_set_size && largest_set_dist>set_dist
            largest_set_dist=set_dist;
            Korrespondenzen_robust=consensus;
        end
    end
    
  %  F = achtpunktalgorithmus(Korrespondenzen_robust);


end

