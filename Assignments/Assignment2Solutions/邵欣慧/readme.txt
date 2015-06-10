This code is used for object detection whos code's enironment is matlab (at least matlab 2007). Before running it, we should install the vlfeat library. You can down vlfeat library from "http://www.vlfeat.org". 
Firstly, you must install a new file, setup.m with "run (''D:\vlfeat-0.9.18\toolbox\vl_setup')". Then save this file into root's folder. Finally, open matlab. 

This code fall into seven steps, such as input image, color space conversion,features and descriptors,match descriptors,find homographe transformation,perspective transform and localize the object.

Patten attention:
    1) When does color space conversion, you should use mat2gray() not rgb2gray().
    2) When use vl_sift() , you should convert it into single().
   

If you have any questions or suggestions, wellcome to contact me by QQ:376449788 or tel:18363928310.
