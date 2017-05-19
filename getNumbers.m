function [numSets,numImages] = getNumbers()

answer = inputdlg({'Number of image sets','Number of images per set'},'How many files?');

numSets = str2num(answer{1});
numImages = str2num(answer{2});