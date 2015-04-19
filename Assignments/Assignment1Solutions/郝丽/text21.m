clc
clear
%%
%输入图像
image_name = '0_7_7804.jpg';
image = imread( image_name );
subplot(2,2,1),imshow(image_name),title('原图');
%%
%量化色彩通道来减少色彩数量
[i,j,k]=size(image);%image的规格
group=zeros(i,j);%创建一个全0的二维数组，i行j列
uint16(group);%将变量comp转换为Uint16类型

for m=1:i
    for n=1:j
       group(m,n)=uint16(image(m,n,1)/16)+uint16(image(m,n,2))+uint16(image(m,n,3))*16;
    end
end
%%
%超像素分割
lab_picture=vl_xyz2lab(vl_rgb2xyz(image));%把image由rgb转化为xyz，再由xyz转化为lab格式
single_picture=single(lab_picture);
block_size=30; %每块大小设置为30 
measurement=0.1; %尺度设置为0.1 
segment = vl_slic(single_picture,block_size, measurement);%超像素分割，分割函数：vl_slic
%用求梯度的方法来显示图像
[sx,sy]=vl_grad(double(segment), 'type', 'forward');%把segments的类型转换成double，求梯度 
s=find(sx|sy);%梯度的索引做成向量
segment_picture=image;
segment_picture([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))])=0 ;
subplot(2,2,2),imshow(segment_picture),title('分割后');
%%
% 将每块超像素内的数值输入到某一维向量再进行分析
[m n]=size(segment);
num=200;%设置直方图横坐标间隔
numb=max(max(segment));%分块标签最大值
hist0=zeros(numb,[],'double');      %hist0为以numb为行，任意列的0矩阵
hist1=zeros(numb,num);%hist1为0矩阵
for i=0:max(max(segment))%i的取值为从0到标签最大值
    j=1;
    for x=1:m
        for y=1:n
             if segment(x,y)==i  %如果segments(x,y)的值为i
                hist0(i+1,j)=group(x,y);%把comp(x,y)赋给RGB1(i+1,j)
                j=j+1;
           end
        end
    end
    hist1(i+1,[1:num])=hist(hist0(i+1,1:j-1),num);%画直方图，
end
%计算每个超像素的全局对比度
compare=zeros(1,numb+1,'double');%compare为以umb+1为行，任意列的0矩阵
for i=0:numb
    for x=1:num %x从0到分块的块数
        for y=1:numb+1 %y从1到标签最大值+1
            if hist1(i+1,x)+hist1(y,x)~=0 %分母不能为0
                compare(1,i+1)=2*(hist1(i+1,x)-hist1(y,x))*(hist1(i+1,x)-hist1(y,x))/(hist1(i+1,x)+hist1(y,x))+compare(1,i+1);  %直方图距离计算公式        
            end
        end
    end
end

%将超像素全局对比度代替到像素对比度
pixel_compare=zeros(m,n);
for x=1:m
    for y=1:n
        pixel_compare(x,y)=compare(1,segment(x,y)+1);%找到坐标为xy的全局对比度，并将其赋给坐标为xy的像素点
    end
end
subplot(2,2,3),imshow(imdivide(pixel_compare,max(max(compare)))),title('对比度量化后图像');
%%
%用center prior增强
sigmaD =120;
[rows, cols, junk] = size(image);

coordinateMtx = zeros(rows, cols, 2);
coordinateMtx(:,:,1) = repmat((1:1:rows)', 1, cols);
coordinateMtx(:,:,2) = repmat(1:1:cols, rows, 1);

centerY = rows / 2;
centerX = cols / 2;
centerMtx(:,:,1) = ones(rows, cols) * centerY;
centerMtx(:,:,2) = ones(rows, cols) * centerX;
SDMap = exp(-sum((coordinateMtx - centerMtx).^2,3) / sigmaD^2);

im_out=double(segment).* SDMap;
im_out=uint8((im_out/max(max(im_out)))*255);
subplot(2,2,4),imshow(im_out),title('增强后');










