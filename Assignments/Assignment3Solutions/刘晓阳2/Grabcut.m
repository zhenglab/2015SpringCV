clear;
close all;
clc;

file_path = 'E:\matlab\assignment3\graphcut\PASCALIMAGE\' ;
salency_path = 'E:\matlab\assignment3\graphcut\saliencymap\' ;

img_path_list = dir(strcat(file_path,'*.jpg'));
img_num = length(img_path_list);
threshold=0.8;
if img_num > 0 %������������ͼ��  
        for k = 1:img_num %��һ��ȡͼ��  
            image_name = img_path_list(k).name;% ͼ����  
            image =  imread(strcat(file_path,image_name));
            param = default_signature_param;
            salency_image = signatureSal( image,param);  
            salency = imresize(salency_image , [ size(image,1) size(image,2) ] );
            salencyoutput=im2bw(salency,threshold);
            imwrite(salencyoutput,strcat(salency_path,image_name));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      end
 end

  