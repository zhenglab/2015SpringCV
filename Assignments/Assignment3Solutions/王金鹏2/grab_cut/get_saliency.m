clear;
close all;
clc;

img_file = 'E:\computer_vision\PASCAL\' ;
store_salien_file= 'E:\computer_vision\saliency_map\' ;

dir_img = dir( strcat(img_file, '*.jpg') );
img_cell = struct2cell(dir_img);
img_num = size(img_cell, 2);

%设置二值化阈值
 threshold = 0.7;
 
for i = 1 : img_num
    img_name = img_cell{1, i};
    img_path = strcat( img_file, img_name );
    orig_img = imread( img_path );
    orig_img_width = size(orig_img, 2);
    param= default_signature_param(orig_img_width);
    orig_saliency = signatureSal( orig_img, param);
    gray_saliency = uint8( orig_saliency.*255 );
    imshow (gray_saliency);
    %threshold = graythresh(gray_saliency);
    
    bin_saliency = im2bw( gray_saliency, threshold );
    imwrite( bin_saliency,strcat(store_salien_file,img_name));
%     store_salien_path = strcat( store_salien_file,img_name, '.txt' );
%     fid = fopen( store_salien_path, 'wt' );  
%     [m, n] = size(saliency_map);
%     for j = 1 : m
%         for k = 1 : n
%             if mod(k,n)==0 
%                 fprintf( fid,'%f\n', saliency_map(j,k) );
%             else 
%                 fprintf( fid,'%f\t', saliency_map(j,k) );
%             end
%         end
%     end
%     fclose(fid);
    
end
