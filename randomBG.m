% calculates the avg BG of image I in a random region of the shape of the mask
% provided, checking that this doesn't overlap with any cells
% BGmask is a BINARY image of the FRAPed cell
% cellsMask is a BINARY image of all cells
% will avoid any cell objects present in cellsMask

function [avg,trans] = randomBG(images,BGmask)
% calculate image size (ASSUMING I is square)
avg = 'pointless';

imageSizeX = size(images{1},2);
imageSizeY = size(images{1},1);
numPixels = sum(BGmask(:));
numImages = numel(images);

% binarize all the images

masks = cell(size(images));
for i=1:numImages
    masks{i} = imbinarize(images{i});
    masks{i} = cleanup(masks{i}); % clean them up a bit too
end

% loop until success OR too many tries

success = 0;
tries = 0;

while success == 0 && tries < 50
    % pick a random offset in x and y
    maxOffsetX = floor(imageSizeX/2);
    maxOffsetY = floor(imageSizeY/2);
    
    x = randi([-maxOffsetX,maxOffsetX],1);
    y = randi([-maxOffsetY,maxOffsetY],1);

    % move the mask
    
    trans = imtranslate(BGmask,[x,y]);
    

    
    % check if it fell off screen
    
    s = sum(trans(:));
    
    if s/numPixels > 0.99
        
        miniSuccess = 0;
        for i=1:numImages
            % determine if it intersects with any cells
            insect = bsxfun(@and,trans,masks{i});

            if sum(insect(:)) == 0
                % if no, calculate average and success
                miniSuccess = miniSuccess + 1;
                
            else

            end
        end
        
        if miniSuccess == numImages
            success = 1;
        end
    end
    
    tries = tries + 1;

    % if yes, loop again
end

if tries == 50
    disp('TOO MANY ATTEMPTS TO FIND A BACKGROUND AREA, PROBABLY TOO SKETCHY DATA')
end