% takes in a binary image I
% cleans up by getting rid of speckly background rubbish
% returns the cleaned up image and the number of connected components in
% clean image (should be num cells present)
% also optionally can return the whole component structure at the end

function [clean,numComps,CC] = cleanup(I)

% set clean to be the same as input image
clean = I;

% find the connected components
CC = bwconncomp(I);

% calculate size of each component
numPixels = cellfun(@numel,CC.PixelIdxList);

% loop through each component, if it's under a certain size zero it in our
% clean image. Chosen 100 as pixel size of interest as anything smaller
% than that won't be a cell.

for i=1:length(CC.PixelIdxList)
    if numPixels(i) < 200
        clean(CC.PixelIdxList{i})=0;
    end
end

% find again connected components on clean image. This will be num cells.
CC = bwconncomp(clean);

numComps = CC.NumObjects;