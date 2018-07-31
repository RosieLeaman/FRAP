% this thresholds a GREYSCALE image and returns a binary version of the same size
function [BW,thresh] = threshold2(image,postImage,detailYes)

% do first threshold; this part is the same as threshold.m

disp('calculating threshold')

avg = mean(image(:)); % calculate avg intensity

sd = std(double(image(:))); % SD of intensity (double cause type issues)

m = max(image(:)); % maximum intensity as we need a proportion
m2 = 2^16; % potential max

thresh = (double(avg)+20*double(sd))/double(m2); % threshold
%thresh = (double(avg)+2*double(sd))/double(m2); % threshold


BW = imbinarize(image);
%BW = imbinarize(image,thresh);

if(detailYes)
    figure;imshow(BW);title('first thresh')
end

BW = imfill(BW,'holes');
BW = logical(BW);

% now we do the second pass

% first find the FRAPed cell, this is needed to pass to randomBG later
disp('finding correct cell')
[correctCell,pixels] = findCorrectCell(BW,image,postImage);

if(detailYes)
    figure;imshow(correctCell);title('correct cell found')
end

% % select a random piece of the background to average and use as a threshold
% 
% BG = randomBG(image,correctCell,BW);
% 
% BGavg = double(sum(BG(:)))/nnz(sum(BG(:)));
% 
% BGstd = std(double(image(pixels)));
% 
% % as before calculate threshold as avg + sd /max, but this time only for
% % the background region. This should provide a better impression of the
% % cell region
% 
% newThresh = (BGavg+double(BGstd))/double(m2);
% %newThresh = 0.11;
% 
% %newThresh = (BGavg+0.5*double(BGstd))/double(max(image(:)));
% %newThresh = (BGavg)/double(max(image(:)));
% 
% BW = imbinarize(image,newThresh);
