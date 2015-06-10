This code is used for object detection whos code's enironment is matlab (at least matlab 2007).

This function reads two images, finds their sift features and displays lines connecting the matched keypoints.  A match is accepted only if its distance is less than distratio times the distance to the second closest match. It returns the number of matches displayed.

"match.m"is the main function in this project, "sift" and "showkeys"are the subfunctions which are needed to implement the project. 

This code fall into eight steps£¬ 
¡¤Step 1 Input image
¡¤Step 2: Color space conversion 
¡¤Step 3: Features2D detection £¨¡°sift.m¡± reads an image and returns its sift keypoints. ¡°sift.m¡± contains the input part and the output part. Input parameters: the file name for the image. Returned: image( the image array in double format), descriptors(a K-by-128 matrix, where each row gives an invariant descriptor for one of the K keypoints. The descriptor is a vector of 128 values normalized to unit length.), locs(K-by-4 matrix, in which each row has the 4 values for a keypoint location (row, column, scale, orientation).The orientation is in the range [-PI, PI] radians.)£©

¡¤Step 4: Calculate descriptors
¡¤Step 5: Match descriptors 
¡¤Step 6: Find homography transformation£¨For efficiency in Matlab, it is cheaper to compute dot products between unit vectors rather than Euclidean distances. Note that the ratio of angles is a close approximation to the ratio of Euclidean distances for small angles. Only keep matches in which the ratio of vector angles from the nearest to second nearest neighbor is less than distRatio. Because these matches are regarded as good matches.£©

¡¤Step 7: Perspective transform
¡¤Step 8: Localize the object£¨ We need to find four points on the edge of the scene image, so that we can draw a rectangle to mark the object which is detected through our project. Four points of scene image which are corresponding to the four corners. We use the matrix of homography transformation which was got in Step 6 to perspective transform the four corners of object image to four points of scene image.£©



If you have any questions or suggestions, please contact me by e-mail:lchang0919@163.com 