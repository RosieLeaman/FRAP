% when provided with a folder reads in all the files necessary for FRAP
% all the files in this folder should be of the form:
% NAME_1.ome.tif;NAME_1minpost_1.ome.tif...
% NAME_2.ome.tif;NAME_1minpost_2.ome.tif...
% the important part is that every FRAP set must have the same number
% ending it
% it does not matter if the images are aligned or not, this will be dealt
% with

function FRAP_folder(folder)
% replace folder input with uigetdir
% folder = uigetdir('','Choose image folder');

% read in the names of all files ending in .lsm
% these are microscopy files
fileList = dir(fullfile(folder,'*.lsm'));

% find out how many FRAP sets there are

FRAPsets = input('How many sets of images are there?\n');

for i=1:1
    disp(['Working on set ',num2str(i)])
    % loop through and find all the right files
    % and save the images and timestamps
    images = {};
    times = [];
    imageCount = 0;
    for j=1:length(fileList)
        if strcmp(fileList(j).name(end-4),num2str(i)) 
            % we've found a right file as the number in the filename
            % matches the FRAP set number
            disp(['Found a file for this set ',fileList(j).name])
            disp('Reading in file\n')
            
            T = tiffread([folder,'/',fileList(j).name]);
            
            % for each frame in this image stack add it to the images and
            % its timestamp too
            
            for k=1:length(T)
                imageCount = imageCount + 1;
                images{imageCount} = T(k).data;
                times(imageCount) = T(k).lsm.TimeStamp(k);
                T(k).lsm.TimeStamp(k)
            end
            
        end        
    end
    % now we have all the files for this FRAP set
    % we then need to arrange the images in time order
    
    % use this snazzy bit of matlab code from the internet to sort the
    % image vector according to the sorted time vector
    % https://uk.mathworks.com/matlabcentral/newsreader/view_thread/83722
    
    [sortedTimes,ind] = sort(times);
    sortedImages = images(ind);
    
    % now that the images are sorted we can read in 
end

