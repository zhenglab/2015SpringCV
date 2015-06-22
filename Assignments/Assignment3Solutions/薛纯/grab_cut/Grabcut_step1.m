clear;
close all;
clc;

file_path = 'C:\Users\水晶\Desktop\计算机视觉3\PASCAL (1)\PASCAL\' ;
salency_path = 'C:\Users\水晶\Desktop\计算机视觉3\PASCAL (1)\PASCAL\PASCAL_SALENCY_0.8\' ;
% rectangle_path='C:\Users\水晶\Desktop\计算机视觉3\PASCAL (1)\RECTANGLE\';
img_path_list = dir(strcat(file_path,'*.jpg'));
img_num = length(img_path_list);
threshold=0.8;
if img_num > 0 %有满足条件的图像  
        for k = 1:img_num %逐一读取图像  
            image_name = img_path_list(k).name;% 图像名  
            image =  imread(strcat(file_path,image_name));
            param = default_signature_param;
            salency_image = signatureSal( image,param);  
            salency = imresize(salency_image , [ size(image,1) size(image,2) ] );
            salencyoutput=im2bw(salency,threshold);
            imwrite(salencyoutput,strcat(salency_path,image_name));
         end
 end

  