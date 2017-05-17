% calculates the avg BG of image I in a random region of the shape of the mask
% provided.
% BGmask is a BINARY image of the FRAPed cell
% cellsMask is a BINARY image of all cells
% will avoid any cell objects present in cellsMask

function [avg,trans] = randomBG(I,BGmask,cellsMask)
% calculate image size (ASSUMING I is square)

imageSize = size(I,1);

% calculate pixels in mask

numPixels = sum(BGmask(:));

% first ensure both these masks are clean, cleanup

BGmask = cleanup(BGmask);
cellsMask = cleanup(cellsMask);

% loop until success

success = 0;

while success == 0
    % pick a random offset in x and y
    x = randi([-imageSize,imageSize],1);
    y = randi([-imageSize,imageSize],1);

    % move the mask
    
    trans = imtranslate(BGmask,[x,y]);
    
    % check if it fell off screen
    
    s = sum(trans(:));
    
    if sum(trans(:))/numPixels > 0.99

        % determine if it intersects with any cells
        insect = bsxfun(@and,trans,cellsMask);
        
        if sum(insect(:)) == 0
            % if no, calculate average and success
            success = 1;
            
            J = I;
            J(~trans)=0;
            
            avg = sum(J(:))/s;
        end
    end

    % if yes, loop again
end

% disp(s/numPixels);
% disp(avg);
% 
% figure;imshow(J);
% figure;imshow(I);