code for detecting and matching SIFT features
.
run in the version 2014a matlab.


Running from within Matlab
--------------------------

If you have access to Matlab, scripts are provided for loading SIFT
features and finding matches between images.These were tested under
Matlab Version 7 and do not require the image processing toolbox.

Run Matlab in the current directory and execute the following
commands.  The "sift" command calls the appropriate binary to extract
SIFT features (under Linux or Windows) and returns them in matrix
form.  Use "showkeys" to display the keypoints superimposed on the 
image.


The "match" command is given two image file names.  It extracts SIFT
features from each image, matches the features between the two images,
and displays the results.

  match('scene1.png','object2.png');

The result shows the two input images next to each other, with lines 
connecting the matching locations.  Most of the matches should be
 correct, but there will be a few false
outliers that could be removed by enforcing viewpoint consistency
constraints.


You can only try matching images i have showed.
the executable
for Windows is named "siftWin32.exe".