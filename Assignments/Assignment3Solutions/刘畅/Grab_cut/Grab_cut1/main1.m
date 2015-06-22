%%%Grab_Cut
%%%此文件完成Grab_cut中的批量读入图片、显著性检测和图像二值化的部分
clear all;
%Step 1 Input Image
file_path =  'C:\Users\Administrator.NTPVB2AO09XFWFK\Desktop\zuoye3\PASCAL\';% 图像文件夹路径
img_path_list = dir(strcat(file_path,'*.jpg'));%获取该文件夹中所有jpg格式的图像
img_num = length(img_path_list);%获取图像总数量
mkdir imgSignature;%创建imgSignature文件夹，用来存储经过saliency并二值化后的图像

if img_num > 0 %有满足条件的图像
        for j = 1:img_num %逐一读取图像
            image_name = img_path_list(j).name;% 图像名
            image =  imread(strcat(file_path,image_name));
            fprintf('%d %d %s\n',j,strcat(file_path,image_name));% 显示正在处理的图像名
            
            %%%step 2 use image signature
            map=signatureSal(image);% 完成image signature
            
            %%%step 3 get the binary image and store the images    
            tt=graythresh(map);%自动确定二值化阈值
            image2=im2bw(map,tt);%对图像二值化
            smap = mat2gray( imresize(image2,[size(image,1) size(image,2)]) );%将生成的map图像调整为与原图同样大小的图像            
            directory=[cd,'C:\Users\Administrator.NTPVB2AO09XFWFK\Desktop\zuoye3\imgSignature\'];%将生成的图片存入imgSignature文件夹中
            imwrite(smap,[directory,image_name]);        
        end
end

  
  
  






