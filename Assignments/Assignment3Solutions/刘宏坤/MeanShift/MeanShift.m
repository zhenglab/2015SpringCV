clear all;
clc;
close all;

%设置meanShift 参数%
hs = 20 ; % the bandwidth of spatial kernel
%hr = 10 ; % the bandwidth of feature kernel
th = 0.05 ; %  the threshod of the convergence criterion (default = .25)
plotOn = 1; % switch on/off the image display of intermediate results (default = 1)

% 设置文件路径%
originImage_dir = 'D:\研一\assignment3\images\train\' ;

clustImage_dir = 'D:\研一\assignment3\images\clusted_image';

segImage_dir= 'D:\研一\assignment3\images\segmentation' ;  %%

%store_MS_evalu = 'E:\computer_vision\MS_evaluation';

%读入所有图片名字%
image_list = dir( strcat(originImage_dir, '*.jpg') );
img_cell = struct2cell(image_list);
image_num = length(image_list);

%对每张图片进行处理%
for hs = 20 : 10 : 40
    for hr = 10 : 10 : 40
        clustImage_path = strcat( clustImage_dir, 'hs',num2str(hs),'_hr', num2str(hr), '\' );
        segImage_path = strcat( segImage_dir,'hs', num2str(hs), '_hr',num2str(hr), '\' );
        
        for i = 1 : image_num
            image_name = image_list(i).name;
            image_path = strcat( originImage_dir, image_name );
            OriginImage = double( imread( image_path ) );
    
            [clusted_img, aver_MS] = meanShiftPixCluster( OriginImage,hs,hr,th,plotOn );
            clusted_img = uint8(clusted_img);
            imwrite( clusted_img,strcat(clustImage_path,image_name) );
   
            seg_img = processSuperpixelImage(clusted_img);
            save( strcat(segImage_path,strrep(image_name,'jpg','mat')),'seg_img' );
        end
    end
end