% When provided with a folder reads in all the files necessary for FRAP
% all the files in this folder should be of the form:
% NAME_1.lsm;NAME_1minpost_1.lsm...
% NAME_2.lsm;NAME_1minpost_2.lsm...
% the important part is that all the images that are part of the same set
% must end in the same number
% and each set must have THE SAME NUMBER OF IMAGES
% it does not matter if the images are aligned or not, this will be dealt
% with

function [avg,time] = FRAP_folder()
% replace folder input with uigetdir
folder = uigetdir('','Choose image folder');

% read in the names of all files ending in .lsm
% these are microscopy files
fileList = dir(fullfile(folder,'*.lsm'));

% find out how many FRAP sets and images per set there are
[FRAPsets,numImages] = getNumbers();

% create storage for the signals and times used
signals = zeros(FRAPsets,numImages);
timestamps = zeros(FRAPsets,numImages);

% determine how much information we want to display
[plotRecoveryYes,averageRecoveryYes,driftYes,plotMasksYes,detailYes] = checkboxes();

% plotMasksYes = 1; % plots a summary of masks for bleached and non-bleached regions
% plotRecoveryYes = 1; % plots a recovery curve for each image set
% detailYes = 0; % plots almost every single mask used (for debugging only)
% driftYes = 1; % accounts for drift in the images

for i=1:FRAPsets
    disp(['Working on set ',num2str(i)])
    % loop through and find all the right files
    % and save the images and timestamps
    images = cell(1,numImages);
    times = zeros(1,numImages);
    imageCount = 0;
    for j=1:length(fileList)
        fileEnd = [num2str(i),'.lsm'];
        
        % there is a slight awkwardness when comparing file names as 10 has
        % more digits than 1, so a different comparison is used for < 10
        % and >= 10
        if i < 10
            if strcmp(fileList(j).name(end-4:end),fileEnd)  && strcmp(fileList(j).name(end-5),'-')
                % we've found a right file as the number in the filename
                % matches the FRAP set number
                disp(['Found a file for this set ',fileList(j).name])
                disp('Reading in file\n')

                T = tiffread([folder,'/',fileList(j).name]); % read file

                % for each frame in this image stack add it to the images and
                % its timestamp too
                for k=1:length(T)
                    imageCount = imageCount + 1;
                    images{imageCount} = T(k).data;
                    times(imageCount) = T(k).lsm.TimeStamp(k);
                end
            end
            
        elseif strcmp(fileList(j).name(end-5:end),fileEnd)
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
            end
        end        
    end
    % now we have all the files for this FRAP set
    % we then need to arrange the images in time order
    
    % use this bit of matlab code from https://uk.mathworks.com/matlabcentral/newsreader/view_thread/83722
    % to sort the image vector according to the sorted time vector
    [sortedTimes,ind] = sort(times);
    sortedImages = images(ind);

    % now that the images are sorted we can do the FRAP!
    signals(i,:) = FRAP_main(sortedImages,sortedTimes,plotMasksYes,plotRecoveryYes,detailYes,driftYes);
    
    % make the times relative to the first time, as the times are currently
    % system times the images were taken
    relTimes = sortedTimes - sortedTimes(1);
    
    % save the relative timestamps too
    timestamps(i,:) = relTimes;
    
    if(plotRecoveryYes)
        % save the individual recovery curve
        filename = [folder,'/recovery-',num2str(i),'.tif'];
        print('-dtiff', '-r400', filename);
    end
end

% save the data to a text file, comma-separated.
dlmwrite([folder,'/times.txt'],timestamps)
dlmwrite([folder,'/curves.txt'],signals)

if(averageRecoveryYes)
    % calculate the average recovery curve
    [avg,time] = calcAverage(signals,timestamps);
    
    % plot the curve
    figure;plot(time,avg,'Linewidth',3);grid on;grid minor;set(gca,'FontSize',20);hold on
    %errorbar(preciseTimes(1:6),avgSignals(1:6),stdev(1:6),'kx','Linewidth',2); 
    xlabel('Time postbleach (s)');ylabel('Normalised intensity');
    text(250,0.95,['n=',num2str(FRAPsets)],'FontSize',20,'Color','black');
    
    filename = [folder,'/recovery-average.tif'];
    print('-dtiff', '-r400', strcat(filename)); % save to file
end
