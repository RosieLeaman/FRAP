% this is an edit of FRAP_folder that makes it run on one set of FRAP files
% which it asks for in turn to deal with problems where the time of the
% images is not known so MATLAB cannot order the images properly
% It makes the assumption that there are 8 images total in the FRAP
% sequence

function FRAP_folder_noTime()

numImages = 8;

answer = inputdlg({'Number of image sets'},'How many image sets?');

numSets = str2num(answer{1});

signals = zeros(numSets,8);

[plotRecoveryYes,~,driftYes,plotMasksYes,detailYes] = checkboxes();

for j =1:numSets

    sortedImages = cell(8,1);

    for i=1:4
        [file,path] = uigetfile('*.tif')

        T = tiffread([path,file]);

        if i==1
            sortedImages{1} = T(1).data();
            sortedImages{2} = T(2).data();
            sortedImages{3} = T(3).data();
            sortedImages{4} = T(4).data();
            sortedImages{5} = T(5).data();
        else
            sortedImages{i+4} = T(1).data();
        end
    end

    signals(j,:) = FRAP_main(sortedImages,[0,1,2,3,4,60,120,300],plotMasksYes,plotRecoveryYes,detailYes,driftYes);

    if(plotRecoveryYes)
        filename = [path,'/recovery-',num2str(j),'.tif'];
        print('-dtiff', '-r400', filename);
    end

end

dlmwrite([path,'/curves.txt'],signals)