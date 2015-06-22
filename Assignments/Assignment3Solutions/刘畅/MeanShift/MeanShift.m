clear all;
clc;

%设置meanShift 参数%
hs = 20 ; % the bandwidth of spatial kernel
%hr = 10 ; % the bandwidth of feature kernel
th = 0.05 ; %  the threshod of the convergence criterion (default = .25)
plotOn = 1; % switch on/off the image display of intermediate results (default = 1)

% 设置文件路径%
img_file = 'C:\Users\Administrator.NTPVB2AO09XFWFK\Desktop\liuchang_assignment3\BSDS500\groundTruth\train' ;
%ground_truth_file = 'C:\Users\Administrator.NTPVB2AO09XFWFK\Desktop\liuchang_assignment3\BSDS500\groundTruth\train';
store_clust_file = 'C:\Users\Administrator.NTPVB2AO09XFWFK\Desktop\liuchang_assignment3\MeanShift\ClusterImage\clustd_img';

store_seg_file= 'C:\Users\Administrator.NTPVB2AO09XFWFK\Desktop\liuchang_assignment3\MeanShift\SegImage\seg_img' ;  %%

%store_MS_evalu = 'C:\Users\Administrator.NTPVB2AO09XFWFK\Desktop\liuchang_assignment3\MeanShift\evaluation';

%读入所有图片名字%
dir_img = dir( strcat(img_file, '*.jpg') );
img_cell = struct2cell(dir_img);
img_num = size(img_cell, 2);

%对每张图片进行处理%
%for hs = 20 : 10 : 40
    for hr = 10 : 10 : 40
        store_seg_path = strcat( store_seg_file, num2str(hs), num2str(hr), '\' );
        store_clust_path = strcat( store_clust_file, num2str(hs), num2str(hr), '\' );
        for i = 2 : img_num
            img_name = img_cell{1, i};
            img_path = strcat( img_file, img_name );
            orig_img = double( imread( img_path ) );
    
            [clusted_img, aver_MS] = meanShiftPixCluster( orig_img,hs,hr,th,plotOn );
            clusted_img = uint8(clusted_img);
            imwrite( clusted_img,strcat(store_clust_path,img_name) );
   
            seg_img = processSuperpixelImage(clusted_img);
            save( strcat(store_seg_path,strrep(img_name,'jpg','mat')),'seg_img' );
        end
    end
%end