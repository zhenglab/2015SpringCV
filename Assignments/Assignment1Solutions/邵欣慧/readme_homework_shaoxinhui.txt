This code is used for salient object detection whos code's enironment is matlab (at least matlab 2007). Before 
running it, we should install the vlfeat library. You can down vlfeat library from "http://www.vlfeat.org". 
Firstly, you must install a new file, setup.m with "run (''D:\vlfeat-0.9.18\toolbox\vl_setup')". Then save 
this file into root's folder. Finally, open matlab. 

This code fall into seven steps, such as input image, extract image colocful information and sengment the
input image to superpixels, compute features of each superixel, compte superpixel feature contrast, conver
superpixel sallency to pixel sallency, use priors to enhance the result, use priors to enforce. 

Patten attention:
    1) When use vl_slic(), you should convert image to single type. 
    2) When numbers are exceed the limit, you should type cast by "uint8".
    3) In order to avoid accurring infinity, you should plus "eps" to denominator.


If you have any questions or suggestions, wellcome to contact me by QQ:376449788 or tel:18363928310.