function sd = sampson_dist(F, x1_pixel, x2_pixel)
    % Diese Funktion berechnet die Sampson Distanz basierend auf der
    % Fundamentalmatrix F
    e3_dach=[0 -1 0; 1 0 0; 0 0 0];
    
    %zähler
    zaehler=dot(x2_pixel,F*x1_pixel).^2;
    
    
    %nenner
    links=e3_dach*(F*x1_pixel);
    rechts=(x2_pixel'*F)*e3_dach;
    nenner= dot(links,links)+dot(rechts',rechts');
    sd=zaehler./nenner;
end