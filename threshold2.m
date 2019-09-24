% this thresholds a GREYSCALE image and returns a binary version of the same size
function [BW,thresh] = threshold2(image,postImage,detailYes)

disp('calculating threshold')

% the threshold can be calculated as the avg intensity + 2s.d.

avg = mean(image(:)); % calculate avg intensity

sd = std(double(image(:))); % SD of intensity (double cause type issues)

m = max(image(:)); % maximum intensity as we need a proportion
m2 = 2^16; % potential max

%thresh = (double(avg)+10*double(sd))/double(m2); % threshold
thresh = (double(avg)+2*double(sd))/double(m2); % threshold

% for most images, the built-in matlab function imbinarize is sufficient to
% binarize the image. However for images with poor fluorescence such as
% GFP-TolA it is better to use our calculated threshold above.

BW = imbinarize(image); %usually use this
%BW = imbinarize(image,thresh); % use this for GFP-tolA

if(detailYes)
    figure;imshow(BW);title('first thresh')
end

BW = imfill(BW,'holes');
BW = logical(BW);

% first find the FRAPed cell, this is needed to pass to randomBG later
disp('finding correct cell')
[correctCell,~] = findCorrectCell(BW,image,postImage);

if(detailYes)
    figure;imshow(correctCell);title('correct cell found')
end