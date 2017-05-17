% this function takes in two images and spits out binary masks for total
% cell region, bleached cell region and nonbleached cell region.
% I should be prebleach image, I2 first postbleach image.

% this version instead of subtracting the grayscale it subtracts the mask
% but uses a lower threshold for the second image so that it has less of a
% halo
% produces similar results to maskMaker.m

function [total,bleached,nonbleached,drifts] = maskMaker3(images,detailYes)

I = images{1};
I2 = images{2};

% extract mean + s.d. threshold from prebleach image
disp('finding threshold for image 1 and binarising it')
BW = threshold2(I,I2,detailYes);

% find reduced threshold for second image
%disp('finding threshold for image 2')
% maxPre = double(mean(I(:)));
% 
% maxPost = double(mean(I2(:)));

%thresh2 = thresh*(maxPost/maxPre);

% threshold the second image to get nonbleached region

nonbleached = imbinarize(I2);

disp('Binarized image 2')

if(detailYes)
    figure;imshow(nonbleached);title('nonbleached')
end
% subtract the masks to produce bleached region

disp('Calculating bleached region')

bleached = BW - nonbleached;
bleached(bleached < 0)=0;
bleached = logical(bleached);

if(detailYes)
    figure;imshow(BW);title('cell, pre clean')
    figure;imshow(nonbleached);title('nonbleached,preclean')
    figure;imshow(bleached);title('bleached,preclean')
end

% clean up all these

disp('cleaning up the masks')

bleached = cleanup(bleached);

bleached = imfill(bleached,'holes');

nonbleached = cleanup(nonbleached);

if(detailYes)
    figure;imshow(BW);title('cell, post clean')
    figure;imshow(bleached);title('nonbleached,postclean')
    figure;imshow(nonbleached);title('bleached,postclean')
end

% find pixels in common between bleach and nonbleach mask
disp('checking for pixels in both the bleached and nonbleached')
inBoth = bsxfun(@and,bleached,nonbleached);

% subtract pixels in common from the bleach mask
disp('removing these from bleached')
bleached = bleached - inBoth;
bleached(bleached < 0) = 0;
bleached = logical(bleached);

% cleanup
disp('cleaning up bleached')
bleached = cleanup(bleached);

% create total cell by adding the two together
disp('create total cell new by adding bleached and nonbleached')
total = logical(bleached + nonbleached);

% fill in gaps in total cell. 
disp('fill in the gaps in total cell')
total = imfill(total,'holes');

if(detailYes)
    figure;imshow(total);title('total cell, end maskmaker')
end

% Create new version of nonbleach by subtracting bleach mask from our 
%filled total cell

disp('Now create new version of nonbleach')

nonbleached = logical(total - bleached);

if(detailYes)
    figure;imshow(nonbleached);title('nonbleach, end maskmaker')
end

% calculate the drifts
% first we need to actually pick the correct cell out of nonbleached

correct = findCorrectCell(nonbleached,I,I2);

clusters0 = bwconncomp(correct);

centre0 = regionprops(clusters0,'Centroid');

drifts = cell(1,(length(images)-3));

for i=3:length(images)
    disp(['Checking for drift in image ',num2str(i)]) 
    % threshold the image
    thresholded = imbinarize(images{i});
    
    % cleanup the image quickly
    
    [thresholded,numCells,cells] = cleanup(thresholded);
    
    % pick the component that is our cell
    
    % first check how many cells there are, if there is only 1 we are
    % finished
    
    if numCells > 1
        disp('Many cells! Have to find correct')
        % we have too many cells
    
        chosenCell = 0;
        chosenMask = 0;
        chosenCount = 0;
    
        for k=1:numCells
            % for each component create a mask for that component only
            thisCell = thresholded;
            for m=[1:k-1,k+1:numCells]
                % set pixels in all other cells to 0
                thisCell(cells.PixelIdxList{m})=0;
            end
            
            % cross this mask with the nonbleach

            cross = correct.*thisCell;
            
            count = nnz(cross);
            
            if count > chosenCount
                chosenCount = count;
                chosenCell = k;
                chosenMask = thisCell;
            end           
        end
   
    else
        chosenCell = 1;
        chosenMask = thresholded;
    end
    
    if(detailYes)
        figure;imshow(chosenMask);title(['chosen',num2str(i)]);
    end
    
    % calculate the centre of mass
    
    comp = bwconncomp(chosenMask);
    centre = regionprops(comp,'Centroid');
    
    % calculate drift
    
    drifts{i-2} = centre.Centroid - centre0.Centroid;
    
end

for i=1:length(drifts)
    disp(drifts{i})
end

disp('end maskmaker')