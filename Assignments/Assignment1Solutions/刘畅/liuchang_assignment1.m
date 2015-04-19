clc;
clear;
image_name='1.jpg';
image=imread(image_name);%����ͼ��
m=size(imread(image_name),1);  %��ȡͼ��ĳ�
n=size(imread(image_name),2); %��ȡͼ��Ŀ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ȡͼ����Ϣ����
%1��ȡͼ���RGB����ֵ
s=size(image);
R=image(:,:,1);
G=image(:,:,2);
B=image(:,:,3);
%2������ͨ������Ϣ��0-255ѹ����0-16
R=R/16;
G=G/16;
B=B/16;
R=im2double(R);
G=im2double(G);
B=im2double(B);
%3����ͨ����Ϣ������һ�������У�����m*n��ͼ����Ϣ����Ԫ����ֵ��Χ0-4096
M_rgb=R*16*16+G*16+B;
%��ʾԭͼ��RGB����ͨ������������ͼ��
subplot(2,3,1);imshow(image,[]);title('image');
subplot(2,3,2);imshow(R,[]);title('R-channel');
subplot(2,3,3);imshow(G,[]);title('G-channel');
subplot(2,3,4);imshow(B,[]);title('B-channel');
subplot(2,3,5);imshow(M_rgb,[]);title('info_matrix');
%�����طָ�
Image_xyz=vl_rgb2xyz(image);%ת��Ϊxyzģʽ
Image_lab=vl_xyz2lab(vl_rgb2xyz(image));%ת��Ϊlabģʽ
Image_single=single(Image_lab);
%�趨slic�㷨�������
regionsize=20;%�ֿ�Ĵ�С
regularizer=0.1;%���õ����߶�
%��SLIC�㷨���г����طָ�
M_segments=vl_slic(Image_single,regionsize,regularizer);%�����طָ�
[M_x,M_y]=vl_grad(double(M_segments), 'type', 'forward');%���ݶ� 
s=find(M_x|M_y);%�ݶȵ�������������
image_segments=image;
image_segments([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))]) = 0 ;
figure,imshow(image_segments);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����ֱ��ͼ
[p q]=size(M_segments);
H_image=zeros(max(max(M_segments)),[],'double');      %H_image��i+1��Ϊ��i�鳬���ذ���������
histogram=zeros(max(max(M_segments)),256);
for i=0:max(max(M_segments))
    j=1;
    for x=1:p
        for y=1:q
            if M_segments(x,y)==i
                H_image(i+1,j)=M_rgb(x,y);
                j=j+1;
            end
        end
    end   
    H_image=ceil(H_image);
        a=1;
        b=1;
        if(a<=256 && b<=j-1)
            histogram(i+1,a)=histogram(H_image(i+1,b)+1,256);
            a=a+1;
            b=b+1;
        end     
    
end
 %����Աȶ�
number=max(max(M_segments));
contrast=zeros(1,number+1,'double');
for i=0:number
    for x=1:256
        for y=1:number+1
            if histogram(i+1,x)+histogram(y,x)~=0
                contrast(1,i+1)=contrast(1,i+1)+2*(histogram(i+1,x)-histogram(y,x))*(histogram(i+1,x)-histogram(y,x))/(shistogra(i+1,x)+histogram(y,x));
            end
        end
    end
end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��������ȫ�ֶԱȶ��ƹ㵽���ضԱȶ�
fea_p=zeros(m,n);
for x=1:m
    for y=1:n
        fea_p(x,y)=contrast(1,M_segments(x,y)+1);
    end
end
figure,imshow(imdivide(fea_p,max(max(contrast))));
 %����������ǿ���
sigmaD = 110;
[rows, cols, junk] = size(image);
coordinateMtx = zeros(rows, cols, 2);
coordinateMtx(:,:,1) = repmat((1:1:rows)', 1, cols);
coordinateMtx(:,:,2) = repmat(1:1:cols, rows, 1);
centerY = rows / 2;
centerX = cols / 2;
centerMtx(:,:,1) = ones(rows, cols) * centerY;
centerMtx(:,:,2) = ones(rows, cols) * centerX;
SDMap = exp(-sum((coordinateMtx - centerMtx).^2,3) / sigmaD^2);
image_out=double(M_segments).* SDMap;
image_out=uint8((image_out/146)*255);
figure,imshow(image_out);


