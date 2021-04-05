function gray_image = rgb_to_gray(input_image)
    % Diese Funktion soll ein RGB-Bild in ein Graustufenbild umwandeln. Falls
    % das Bild bereits in Graustufen vorliegt, soll es direkt zurueckgegeben werden.
    % Check if image is Grauwertbild
    if size(input_image,3) == 1
        gray_image = input_image;
        return;
    else
    % Convert to double
    input_image = double(input_image);
    % Convert to Grauwertbild
    R = input_image(:,:,1);
    G = input_image(:,:,2);
    B = input_image(:,:,3);
    gray_image = 0.299*R+0.587*G+0.114*B;
    % Convert to unit8
    gray_image = uint8(gray_image);
    end

end