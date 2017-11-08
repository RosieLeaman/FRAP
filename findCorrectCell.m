% takes in a BINARY image mask (the total cell mask), I the prebleach image
% and I2, the first postbleach image
% returns the same BINARY mask but with any cells in the picture that were not
% FRAPed removed (set to zero)
function [correct,pixels] = findCorrectCell(mask,I,I2)

% first clean up the image
[correct,n,CC] = cleanup(mask); 
% this will clean up the image and return the resulting cleaned image's
% connected components in CC

% if there is only one then return the cleaned up image
%figure;imshow(mask);title('first cleanup')
if n < 2
    pixels = CC.PixelIdxList{1};
    return
end

% NEW PLAN; find things closest to the centre
% original plan; find the component that changes intensity the most
% this breaks when there's a mobile background cell in the prebleach image
%ratios = zeros(n,1);

% find the centroids of the components

s = regionprops(correct,'Centroid');

% calculate image centre

centreY = floor(size(I,1)/2);
centreX = floor(size(I,2)/2);

smallestDist = (size(I,1)-centreY)^2+(size(I,2)-centreX)^2;
component = 0;

% if not then loop through the components
for i=1:n
%     % calculate the ratios of intensities between the initial greyscale
%     % image and prebleach
%     % the component with the smallest ratio is the FRAPed cell
%     comp = CC.PixelIdxList{i};
%     len = length(comp);
%     
%     I2avg = sum(I2(comp))/len;
%     Iavg = sum(I(comp))/len;
%     
%     ratios(i) = I2avg/Iavg;

    % calculate the distance from the centre
    
    dist = ((s(i).Centroid(1)-centreX).^2 + (s(i).Centroid(2)-centreY).^2);
    
    if dist < smallestDist
        smallestDist = dist;
        component = i;
    end

end

chosen = component;

% 
% % find the smallest element of ratios
% 
% [~,chosen] = min(ratios);

% create an array of the non-chosen indices

notChosen = [1:chosen-1,chosen+1:n];

% go through the cells and set things that aren't in our cell to zero

for i=notChosen
    correct(CC.PixelIdxList{i})=0;
end

pixels = CC.PixelIdxList{chosen};