function [T1, R1, T2, R2, U, V]=TR_aus_E(E)
    % Diese Funktion berechnet die moeglichen Werte fuer T und R
    % aus der Essentiellen Matrix
    %Singulärwertzerlegung

   % Diese Funktion berechnet die moeglichen Werte fuer T und R
    % aus der Essentiellen Matrix
    % R_z(+pi/2)
    R_z1 = [0 -1 0;
            1 0 0;
            0 0 1];
    % R_z(-pi/2)    
    R_z2 = [0 1 0;
            -1 0 0;
            0 0 1]; 
    % SVD of E
    [U,~,V] = svd(E);
    
    % Make sure U and V are rotation matrices
    if det(U) < 0
        U(:,3)=-U(:,3);
    end
    
     if det(V) < 0
         V(:,3)=-V(:,3);
     end
             
    % First pair of R,T       
    R1 = U*R_z1'*V';
    T1 = U(:,3);
  
    % Second pair of R,T
    R2 = U*R_z2'*V';
    T2 = -T1;
        
end