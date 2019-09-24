% this function calculates a FRAP recovery curve.
% it currently outputs nothing but the image.
% inputs should be a CELL ARRAY of the images IN TIME ORDER
% first image should be 1 prebleach, second should be first postbleach
% timestamps should be an ARRAY of the time of each frame MUST HAVE SAME
% LENGTH AS IMAGES
% plot should be a BOOLEAN that is 1 if you want the masks used shown and zero
% else

% now has the added bonus of: double thresholding for a nicer looking image
% and actually outputting the results

% this function depends on several other .m files:
% maskMaker3 (cleanup,findCorrectCell,threshold2), findCorrectCell (cleanup),
% cleanup, subplot_tight,calcImmobile

function [signal,immobile] = FRAP_main(images,timestamps,plotMasksYes,plotRecoveryYes,detailYes,driftYes)

numImages = length(images);

% create first pass mask for total cell

disp('doing first pass for cell')
%figure;imshow(images{1},[min(images{1}(:)),max(images{1}(:))])

[totalAllCells,bleached,~,drifts,thresh] = maskMaker3(images,detailYes); 
% add nonbleached to this list if desire nonbleached region mask

% check for multiple cells

disp('checking for multiple cells and removing unwanted')
total = findCorrectCell(totalAllCells,images{1},images{2});
if(detailYes)
    figure;imshow(total);title('correct cell in frapv0_3')
end
% create background mask

% first clean up totalAllCells
disp('cleaning up cells')
totalAllCells = cleanup(totalAllCells);

% create the mask for background region
disp('creating mask for background')
%BGmask = imcomplement(totalAllCells);
[~,BGmask] = randomBG(images,total);

% display all masks IF plot ==1

if plotMasksYes==1
    disp('displaying masks to be used')
    figure;
    subplot_tight(2,2,1,[0.1,0.1]);imshow(totalAllCells);title('All cells');
    subplot_tight(2,2,2,[0.1,0.1]);imshow(total);title('FRAPed cell');
    subplot_tight(2,2,3,[0.1,0.1]);imshow(bleached);title('Bleached region');
    subplot_tight(2,2,4,[0.1,0.1]);imshow(BGmask);title('Background');
    
    %bw = bwboundaries(bleached);
    blackImage = zeros(size(images{1}), 'uint8');
    rgbImage1 = cat(3, blackImage,images{1}, blackImage);
    figure;set(gcf,'Units','normal');set(gca,'Position',[0 0 1 1])
    subplot_tight(1,3,1,[0.01,0.01]);imshow(rgbImage1);
    %hold on;visboundaries(bw,'Linewidth',1);
    text(30,30,'0s','Color','white','Fontsize',20);
    rgbImage2 = cat(3, blackImage,images{5}, blackImage);
    subplot_tight(1,3,2,[0.01,0.01]);imshow(rgbImage2);
    %hold on;visboundaries(bw,'Linewidth',1);
    text(30,30,'5s','Color','white','Fontsize',20);
    rgbImage3 = cat(3, blackImage,images{end}, blackImage);
    subplot_tight(1,3,3,[0.01,0.01]);imshow(rgbImage3);
    %hold on;visboundaries(bw,'Linewidth',1);
    text(30,30,'5mins','Color','white','Fontsize',20);
end

% create the necessary drifted masks

totalDrifted = cell(numImages,1);
bleachedDrifted = cell(numImages,1);
BGDrifted = cell(numImages,1); % we do not drift this though
% it has been chosen to coincide with no cells across the whole time frame

if driftYes==1
    for i=1:numImages
        if i==1 || i==2
            totalDrifted{i} = total;
            bleachedDrifted{i} = bleached;
            BGDrifted{i} = BGmask;
        else
            totalDrifted{i} = imtranslate(total,drifts{i-2});
            bleachedDrifted{i} = imtranslate(bleached,drifts{i-2});
            BGDrifted{i} = BGmask;
        end
    end
else
    for i=1:numImages
        totalDrifted{i} = total;
        bleachedDrifted{i} = bleached;
        BGDrifted{i} = BGmask;
    end
end
% at each time point (number images) calculate the avg T_t 
%(total cell intensity) and I_t (bleached region intensity) and BG_t
%(background region intensity)

Tt = zeros(numImages,1); % this stores average in total cell at each timepoint

% create the masked version of total cell region original image and average
T = cell(numImages,1);
for i=1:numImages
    
    % calculate the number of pixels in the cell from total
    % this will tell us how many to take the average over

    cellPixels = nnz(totalDrifted{i});
    
    T{i} = images{i}; % make a copy of the image
    
    T{i}(~totalDrifted{i})=0; % set pixels not in the cell to zero
    
    Tt(i) = sum(T{i}(:))/cellPixels; % now add up everything else and 
                                % divide by num. non-zero pixels
    if(detailYes)
        figure;imshow(T{i})
    end
end

% create masked version of the bleached region and average

It = zeros(numImages,1); %stores averages in bleached region

I = cell(numImages,1);
for i=1:numImages
    bleachedPixels = nnz(bleachedDrifted{i});
    
    I{i} = images{i};
    I{i}(~bleachedDrifted{i})=0; % set everything not in bleached region to zero
    
    It(i) = sum(I{i}(:))/bleachedPixels; % average

    if(detailYes)
        figure;imshow(I{i})
    end
end

% create masked version of background and average

BGt = zeros(numImages,1); %stores averages in bleached region

BG = cell(numImages,1);
for i=1:numImages
    
    BGPixels = nnz(BGDrifted{i});
    BG{i} = images{i};
    BG{i}(~BGDrifted{i})=0; % set everything not in bleached region to zero
    
    BGt(i) = sum(BG{i}(:))/BGPixels; % average
    if(detailYes)
        figure;imshow(BG{i});
    end
end

% subtract BG from all of these T'_t and I'_t

Tt2 = Tt - BGt;

It2 = It - BGt;

% At each time point, calculate signal as (I'_t/I'_pre)*(T'_pre/T'_t)
% double normalisation

%signal = It2/It2(1);

signal = zeros(numImages,1);
signal(1) = 1;

for i=2:numImages
    signal(i) = (It2(i)/It2(1))*(Tt2(1)/Tt2(i));
    %signal(i) = (It2(i));
end

%signal2 = (signal - signal(2))/(signal(1)-signal(2));
%signal = signal2;

% display
if plotRecoveryYes == 1
    times = [0,1,2,3,4,60,120,300];
    %figure;plot(timestamps,signal,'linewidth',2);
    figure;plot(times,signal,'linewidth',2);
    hold on;scatter(times,signal,'linewidth',2)
    
    xlabel('Time postbleach (s)');ylabel('Normalised Fluorescence Intensity (a.u.)');    
    xticks([0,60,120,300])
    
    set(gca,'FontSize',16)
    ax = gca;
    ax.YGrid = 'on';

    axis tight;
    ylim([0,1])
    
    %title('Recovery curve');
end

% calculate the immobile fraction and output

immobile = calcImmobile(signal);

disp(['Immobile fraction: ',num2str(immobile)])