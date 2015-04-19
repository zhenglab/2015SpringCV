clc;
clear;
image_name='1.jpg';
image=imread(image_name);%读入图像
m=size(imread(image_name),1);  %获取图像的长
n=size(imread(image_name),2); %获取图像的宽
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%获取图像信息矩阵
%1获取图像的RGB特征值
s=size(image);
R=image(:,:,1);
G=image(:,:,2);
B=image(:,:,3);
%2将三个通道的信息有0-255压缩至0-16
R=R/16;
G=G/16;
B=B/16;
R=im2double(R);
G=im2double(G);
B=im2double(B);
%3将三通道信息整合至一个矩阵中，生成m*n的图像信息矩阵，元素数值范围0-4096
M_rgb=R*16*16+G*16+B;
%显示原图、RGB三个通道及经处理后的图像
subplot(2,3,1);imshow(image,[]);title('image');
subplot(2,3,2);imshow(R,[]);title('R-channel');
subplot(2,3,3);imshow(G,[]);title('G-channel');
subplot(2,3,4);imshow(B,[]);title('B-channel');
subplot(2,3,5);imshow(M_rgb,[]);title('info_matrix');
%超像素分割
Image_xyz=vl_rgb2xyz(image);%转换为xyz模式
Image_lab=vl_xyz2lab(vl_rgb2xyz(image));%转换为lab模式
Image_single=single(Image_lab);
%设定slic算法所需参数
regionsize=20;%分块的大小
regularizer=0.1;%设置调整尺度
%用SLIC算法进行超像素分割
M_segments=vl_slic(Image_single,regionsize,regularizer);%超像素分割
[M_x,M_y]=vl_grad(double(M_segments), 'type', 'forward');%求梯度 
s=find(M_x|M_y);%梯度的索引做成向量
image_segments=image;
image_segments([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))]) = 0 ;
figure,imshow(image_segments);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%生成直方图
[p q]=size(M_segments);
H_image=zeros(max(max(M_segments)),[],'double');      %H_image第i+1行为第i块超像素包含的像素
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
 %计算对比度
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
%将超像素全局对比度推广到像素对比度
fea_p=zeros(m,n);
for x=1:m
    for y=1:n
        fea_p(x,y)=contrast(1,M_segments(x,y)+1);
    end
end
figure,imshow(imdivide(fea_p,max(max(contrast))));
 %运用先验增强结果
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


