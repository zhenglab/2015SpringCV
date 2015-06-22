%%%Grab_Cut
%%%���ļ����Grab_cut�е���������ͼƬ�������Լ���ͼ���ֵ���Ĳ���
clear all;
%Step 1 Input Image
file_path =  'C:\Users\Administrator.NTPVB2AO09XFWFK\Desktop\zuoye3\PASCAL\';% ͼ���ļ���·��
img_path_list = dir(strcat(file_path,'*.jpg'));%��ȡ���ļ���������jpg��ʽ��ͼ��
img_num = length(img_path_list);%��ȡͼ��������
mkdir imgSignature;%����imgSignature�ļ��У������洢����saliency����ֵ�����ͼ��

if img_num > 0 %������������ͼ��
        for j = 1:img_num %��һ��ȡͼ��
            image_name = img_path_list(j).name;% ͼ����
            image =  imread(strcat(file_path,image_name));
            fprintf('%d %d %s\n',j,strcat(file_path,image_name));% ��ʾ���ڴ����ͼ����
            
            %%%step 2 use image signature
            map=signatureSal(image);% ���image signature
            
            %%%step 3 get the binary image and store the images    
            tt=graythresh(map);%�Զ�ȷ����ֵ����ֵ
            image2=im2bw(map,tt);%��ͼ���ֵ��
            smap = mat2gray( imresize(image2,[size(image,1) size(image,2)]) );%�����ɵ�mapͼ�����Ϊ��ԭͼͬ����С��ͼ��            
            directory=[cd,'C:\Users\Administrator.NTPVB2AO09XFWFK\Desktop\zuoye3\imgSignature\'];%�����ɵ�ͼƬ����imgSignature�ļ�����
            imwrite(smap,[directory,image_name]);        
        end
end

  
  
  






