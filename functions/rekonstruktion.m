function [T, R, lambda, M1, M2] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen, K1,K2)
    %% Vorbereitung aus Aufgabe 4.2
    % T_cell    Cell-Array mit T1 und T2 
    % R_cell    Cell-Array mit R1 und R2
    % d_cell    Cell-Array für die Tiefeninformationen
    % x1        homogene kalibrierte Koordinaten
    % x2        homogene kalibrierte Koordinaten
    T_cell={T1,T2,T1,T2};
    R_cell={R1,R1,R2,R2};
    
    %homogene kalib. Koord
    N=size(Korrespondenzen,2);
    x1=ones(3,N);
    x2=ones(3,N);
    x1(1:2,:)=Korrespondenzen(1:2,:);
    x2(1:2,:)=Korrespondenzen(3:4,:);
    x1=K1\x1;
    x2=K2\x2;

    num_tiefeInfo = zeros(4,1);
    for k = 1 : 4
       
        T = T_cell{k};
        R = R_cell{k};
        M1 = zeros(3*N,N);
        M2 = M1;
        v1 = zeros(3,N);
        v2 = v1;
                   
        for i = 1 : N

            x2_dach = dach(x2(:,i));
            v1(:,i) = x2_dach*T;
            M1(3*(i-1)+1:3*i,i) = x2_dach*(R*x1(:,i));
            
            x1_dach = dach(x1(:,i));
            v2(:,i) = -(x1_dach*(R'*T));
            M2(3*(i-1)+1:3*i,i) = x1_dach*(R'*x2(:,i));
        end  

        M1 = [M1,v1(:)];
        [~,~,V1] = svd(M1,0);
        d1 = V1(:,end)/V1(end,end);
        
        M2 = [M2,v2(:)];
        [~,~,V2] = svd(M2,0);
        d2 = V2(:,end)/V2(end,end);
        
        d_cell{k} = [d1(1:end-1),d2(1:end-1)];
        num_tiefeInfo(k) = sum((d_cell{k}>0),'all');
    end
    [val,ind] = sort(num_tiefeInfo,'descend');
    if val(1) == val(2)
        a = sum(d_cell{1},'all');
        b = sum(d_cell{2},'all');
        if a>b
            ind = a;
        else
            ind = b;
        end
    else
        ind = ind(1);
    end
    R = R_cell{ind};
    T = T_cell{ind};
    lambda = d_cell{ind};

end