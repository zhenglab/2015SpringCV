clc
clear
%清除当前command区域的命令和工作空间


%%

%1.对图像进行压缩
image_name = './005.jpg';
image = imread(image_name);   %读入图像
subplot(2,2,1),imshow(image_name),title('原图');

[i,j,k]=size(image);         %得到三维矩阵的尺度
image_compress=zeros(i,j);  
double(image_compress);
%定义一个尺度为(i,j)的空矩阵，并使其定义为double类型
for m=1:i
    for n=1:j
       image_compress(m,n)=double(image(m,n,1)/8)+double(image(m,n,2)/8)*32+double(image(m,n,3)/8)*32^2;
    end
end
%通过for循环,将每个点上的RGB三个通道的值压缩为一个值。且范围是1到32768,存入image_compress矩阵中


%%

%2.超像素分割
im_lab=vl_xyz2lab(vl_rgb2xyz(image));
im_single=single(im_lab);

region_size=30;%调节每块分割大小 
regularizer=0.1;%调整尺度 
segments = vl_slic(im_single,region_size, regularizer);%超像素分割
[ix,iy]=vl_grad(double(segments), 'type', 'forward');%求梯度 
 s=find(ix|iy);%梯度的索引做成向量
 imp=image;
imp([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))]) = 0 ;
subplot(2,2,2),imshow(imp),title('超像素分割后');

%%

%3.以下为生成直方图步骤

seg_num=max(max(segments));  %求矩阵segments的最大值，即超像素的个数—1
store_1=zeros(seg_num+1,[]);  %建立一个double型的零矩阵，具有任意长度的列
% count=1;      %从1开始计数
hist_num=128;   %直方图分为128块
store_hist=zeros(seg_num+1,hist_num);   %存储直方图，每个超像素以行向量形式存储
for k=0:seg_num  
    count=1;
    for m=1:i
        for n=1:j
            if segments(m,n)==k;    %把超像素等于k的坐标找到其对应坐标下image_compress的值
                store_1(k+1,count)=image_compress(m,n); %把压缩后的标签image_compress的值放到store_1矩阵的第k+1行
                count=count+1;        %计数加一
            end
        end
    end
    store_hist(k+1,:)=hist(store_1(k+1,1:count-1),hist_num);   %将store_1的第k+1行的前1到count-1个数归类画直方图，
    %维度是hist_num
%     count=1;      
end
%%

%4.计算超像素的对比度

 diff=0;
for k=1:seg_num+1
   for m=1:seg_num+1
        diff=2*sum((store_hist(k,:)-store_hist(m,:)).^2./(store_hist(k,:)+store_hist(m,:)+eps))+diff;

   end    % 计算(hk,h1)+(hk,h2)+(hk,h3)+...+(hk,hn)
   distance(k,1)=(diff/double(seg_num));    %hk到整体距离的平均值
   diff=0;
end
%%

%5.量化全局对比度
for m=1:size(distance)
    pixel(m)=(distance(m)-min(distance))/(max(distance)-min(distance))*255;
end 
 %用全局对比度代替原像素
im_last=zeros(i,j);      %建立一个i行j列的空矩阵
for m=1:i
    for n=1:j
        M=segments(m,n)+1;
        im_last(m,n)=fix((pixel(M)));   %将第M块超像素的全局对比度存入对应的im_last 矩阵中
    end
end

im_last=uint8(im_last);        %转换为unit8类型      
subplot(2,2,3),imshow(im_last),title('量化对比度后');
%%

%6.用先验知识增强结果


sigmaD = 150; %设置参数
[i, j, k] = size(image);

coordinateMtx = zeros(i, j, 2);
coordinateMtx(:,:,1) = repmat((1:1:i)', 1, j);
coordinateMtx(:,:,2) = repmat(1:1:j, i, 1);

centerY = i / 2;
centerX = j / 2;
centerMtx(:,:,1) = ones(i, j) * centerY;
centerMtx(:,:,2) = ones(i, j) * centerX;
SDMap = exp(-sum((coordinateMtx - centerMtx).^2,3) / sigmaD^2);

%颜色prior
sigmaC = 0.3;
LChannel = im_lab(:,:,1);
AChannel = im_lab(:,:,2);
BChannel = im_lab(:,:,3);
maxA = max(AChannel(:));
minA = min(AChannel(:));
normalizedA = (AChannel - minA) / (maxA - minA);
maxB = max(BChannel(:));
minB = min(BChannel(:));
normalizedB = (BChannel - minB) / (maxB - minB);
labDistSquare = normalizedA.^2 + normalizedB.^2;
SCMap = 1 - exp(-labDistSquare / (sigmaC^2));

% im_out=double(im_last).* SDMap; %center prior增强图像
im_out=double(im_last).* SDMap.*SCMap; %用center prior和color prior俩种方法同时增强图像
im_out=uint8((im_out/max(max(im_out)))*255);
subplot(2,2,4),imshow(im_out),title('先验增强后');





            
            
