README for FRAP.m

Usage:
Move the current MATLAB folder to the FRAP folder

In the MATLAB command line run FRAP_folder with no inputs

A folder selection dialog will appear, select the folder with the files you would like to FRAP.
	(the files must be numbered in sets and sequentially or the program will crash.
	 e.g. if we had two sets of FRAP images with one bleach image and images at 1 2 
	 and 3 minutes post bleach they should be numbered
	 1minPost_1.lsm
	 1minPost_2.lsm
	 2minPost_1.lsm
	 2minPost_2.lsm
	 3minPost_1.lsm
	 3minPost_2.lsm
	 bleach_1.lsm
	 bleach_2.lsm
	 The initial name before the number DOES NOT MATTER. What matters is images in the 	 same set have the same number before the ., and the set numbers go from 1 to the 	 maximum with no gaps)

A dialog box with two inputs will appear asking for the number of file sets (this is the total number of cells that were FRAPed) and the number of images per set (this is the prebleach image + the number of images that were taken post bleach)

Finally there is a checkbox selection where you can choose any options to show more details in the output.

The code will then run and by default produce:
Images for each image set of the whole cell and bleached region used by the algorithm
Summary images showing the cell prebleach and at two times postbleach
An average recovery curve across all the cells


--------------------------------------

Details of checkbox options:
'Show individual recovery curves for each image set'
	Default off
	Will plot a recovery curve for each image

'Calculate an average recovery curve'
	Default on
	Will plot an average recovery curve across all images

'Account for drift'
	Default on
	Will track the cell so that the bleached region moves if the cell moves
	Not recommended to turn off

'Show a summary of the masks used and example images'
	Default on
	For each image set show the masks used for the bleached and whole cell regions
	Will also show some example images pre-bleach and post-bleach
	Recommended to leave on for at least the first time on a folder to ensure
	all is working correctly

'Show every mask used (not recommended)'
	Default off
	Will plot every single mask used at almost every stage in the code for 
	each image set
	If there are many image sets in a folder is prohibitively slow
	Not recommended unless debugging

