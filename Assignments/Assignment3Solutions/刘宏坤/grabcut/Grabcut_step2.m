clear;
close all;
clc;

file_path = 'D:\研一\assignment3\PASCAL\PASCAL\' ;
salency_path = 'D:\研一\assignment3\PASCAL\PASCAL_SALENCY_0.8\' ;
% rectangle_path='D:\研一\assignment3\PASCAL\RECTANGLE\';
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
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               nRow=size(salencyoutput,1);
%             nCol=size(salencyoutput,2);
%            wcount=1;
%            hcount=1;
%            width=[];
%            height=[];
%             for i=1:nRow
%                for j=1: nCol
%                   if salencyoutput(i,j)==1
%                      height=[height;i];
%                       hcount=hcount+1;  
%                       width=[width;j];
%                       wcount=wcount+1;
%                   end         
%                end
%             end
%            
%            nRowMin=height(1,1);
%             nRowMax=height(1,1);
%           for i=1:hcount-1
%                if(nRowMin>height(i,1))
%                    nRowMin=height(i,1);
%                end
%               if(nRowMax<height(i,1))
%                     nRowMax=height(i,1);
%                end    
%            end
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             nColMin=width(1,1);
%             nColMax=width(1,1);
%             for i=1:wcount-1
%                if(nColMin>width(i,1))
%                    nColMin=width(i,1);
%                end
%                if(nColMax<width(i,1))
%                    nColMax=width(i,1);
%                end
%             end
%             mDrawRec=image;
%      pointAll = [nRowMin,nColMin];  
%     windSize = [nColMax-nColMin,nRowMax-nRowMin];  
%   
%     [state,results]=draw_rect(mDrawRec,pointAll,windSize,1);  
%        imwrite(results,strcat(rectangle_path,image_name));
      end
 end

  