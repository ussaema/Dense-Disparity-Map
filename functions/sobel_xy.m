function [Fx, Fy] = sobel_xy(input_image)
    % In dieser Funktion soll das Sobel-Filter implementiert werden, welches
    % ein Graustufenbild einliest und den Bildgradienten in x- sowie in
    % y-Richtung zurueckgibt.
    
    A = input_image;
    % Seperated Sobel filter
    u = [1 0 -1]';
    v = [1 2 1]';
   % Compute Gradients in x and y direction 
   Fx = conv2(v,u',A,'same');
   Fy = conv2(u,v',A,'same');

    
end