function [EF] = achtpunktalgorithmus(Korrespondenzen, K1,K2)
    % Diese Funktion berechnet die Essentielle Matrix oder Fundamentalmatrix
    % mittels 8-Punkt-Algorithmus, je nachdem, ob die Kalibrierungsmatrix 'K'
    % vorliegt oder nicht
    
    %% Anfang Achtpunktalgorithmus aus Aufgabe 3.1
    % Bekannte Variablen: 
    % x1    homogene (kalibrierte) Koordinaten
    % x2    homogene (kalibrierte) Koordinaten
    % A     A Matrix für den Achtpunktalgorithmus
    % V     Rechtsseitige Singulärvektoren
    % Diese Funktion berechnet die Essentielle Matrix oder Fundamentalmatrix
    % mittels 8-Punkt-Algorithmus, je nachdem, ob die Kalibrierungsmatrix 'K'
    % vorliegt oder nicht
    
    %größe Korrespondenzen
    [~,n]=size(Korrespondenzen);
    if n<8
        error('Need alteast 8 Correspondences for 8-Point-Algorithm');
    end
    %inhomogene Koord umwandeln
    x1=ones(3,n);
    x2=ones(3,n);
    x1(1:2,:)=Korrespondenzen(1:2,:);
    x2(1:2,:)=Korrespondenzen(3:4,:);
    if nargin == 3
        x1=K1\x1;
        x2=K2\x2;
    elseif nargin == 2
        x1=K1\x1;
        x2=K1\x2;
    end
    mu = mean(x1(1:2,:),2);
    alpha = sqrt(2)*n/sum(vecnorm(x1(1:2,:)-mu));
    Kx1 = [alpha*eye(2) -alpha*mu ; zeros(1,2) 1];
    x1 = Kx1*x1;
    
    mu = mean(x2(1:2,:),2);
    alpha = sqrt(2)*n/sum(vecnorm(x2(1:2,:)-mu));
    Kx2 = [alpha*eye(2) -alpha*mu ; zeros(1,2) 1];
    x2 = Kx2*x2;
    
    
    %Matrix A berechnen
    A=zeros(n,9);
    for i=1:n
        A(i,:)=kron(x1(:,i),x2(:,i))';
    end
    
    %Singulärwertzerlegung von A
    [~,~,V]=svd(A);
    
    
    %% Schaetzung der Matrizen
    %E
    if nargin==2
       G_s=reshape(V(:,9),[3,3]);
       G_s = Kx2'\G_s/Kx1;
       [U_G,~,V_G]=svd(G_s);
       EF = (U_G(:,1:2)*V_G(:,1:2)');
    else
       G_s=reshape(V(:,9),[3,3]);
       [U_G,S_G,V_G]=svd(G_s);
       %F berechnen
       EF=U_G(:,1:2)*diag([S_G(1,1),S_G(2,2)])*V_G(:,1:2)';
       EF = Kx2'\EF/Kx1;
    end
    
end