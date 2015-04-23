clc;
clear;
%%
%step 1-1 extract image information
image = imread('C:\Users\Administrator\Desktop\005.jpg');   %读入图像
figure,subplot(2,2,1),imshow(image); %读取原图像并显示
[m,n,d]=size(image);         %catch the height and width of the map
 B = double(image(:,:,3));%拆分成三通道并转化为双精度类型
 G = double(image(:,:,2));
 R = double(image(:,:,1));
 R = R/16;%每个通道压缩16倍或者采用for循环将每个像素的值量化到1-15
 G = G/16;
 B = B/16;
 RGB=B*16*16+G*16+R;        %RGB为颜色单值表示后的一维矩阵
subplot(222),imshow(imdivide(RGB,max(max(RGB))));%4096
%每个通道压缩16倍或者采用for循环将每个像素的值量化到1-15


%%
%step1-2.segment the input image into superpixels
im_lab = vl_xyz2lab(vl_rgb2xyz(image)) ;%% im contains the image in RGB format as before转化到xyz\lab空间
im_single=single(im_lab);%single类型im contains the input RGB image as a SINGLE array
region_size=40;%每块超像素的大小
regularizer=0.01;%调整的尺度大小 
segments = vl_slic(im_single,region_size, regularizer);%利用lsic工具箱得到超像素矩阵
[sx,sy]=vl_grad(double(segments), 'type', 'forward');%求梯度 
 s=find(sx|sy);%梯度的索引做成向量
 imp=image;
imp([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))]) = 0 ;

subplot(223),imshow(imp);%超像素分割后的图像
%subplot(223),imshow(segments*(4294967296/140));%梯度


%%
 %step 2-1 compute features of each superpixel
 [p,q]=size(segments);
%seg_num=max(max(segments));  %求矩阵segments的最大值，即超像素的个数—1
store_his=zeros(max(max(segments))+1,[],'double');  %建立一个double型的零矩阵，具有任意长度的列
 
store_hist=zeros(max(max(segments))+1,256,'double');   %存储直方图，每个超像素以行向量形式存储
for k=0:max(max(segments)) %从1开始计数 ,对所有超像素点进行扫描处理，查找所有标签相同的超像素点
    %所在的位置及特征，放在一个矩阵里面
    count=1;
    for i=1:p
        for j=1:q
            if segments(i,j)==k;    %把超像素等于k的坐标找到其对应坐标下RGB的值
                store_his(k+1,count)=RGB(i,j); %将相应的压缩后的RGB值放到store_his矩阵的第k+1行count列
                count=count+1;        %计数加一循环
            end
        end
    end
    store_hist(k+1,:)=hist(store_his(k+1,1:count-1),256);%将store_his的第k+1行的前1到count-1个数归类画直方图，
    %维度是256
end



%%

%step3 计算每个超像素的全局对比度

 diff=0;
for k=1:max(max(segments))+1
   for j=1:max(max(segments))+1
        diff=2*sum((store_hist(k,:)-store_hist(j,:)).^2./(store_hist(k,:)+store_hist(j,:)+eps))+diff;
   end    % 根据文献里的公式计算(hk,h1)+(hk,h2)+(hk,h3)+...+(hk,hn)
   distance(k,1)=(diff/double(max(max(segments))));    %hk到整体距离的平均值
   diff=0;
end
%%

for i=1:size(distance)
    pixel(i)=(distance(i)-min(distance))/(max(distance)-min(distance))*255;%量化全局对比度
end 
 %用全局对比度代替原像素
im_last=zeros(m,n);      %建立一个mn的空矩阵
for i=1:m
  for j=1:n
      segment=segments(i,j)+1;
      im_last(i,j)=fix((pixel(segment)));%将第M块超像素的全局对比度存入对应的im_last 矩阵中，用全局对比度代替原像素
   end
end

im_last=uint8(im_last);        %转换为unit8类型      
subplot(224),imshow(im_last);
%%

%6.用先验知识增强结果
sigmaD = 100;
[rows, cols, junk] = size(image);

coordinateMtx = zeros(rows, cols, 2);
coordinateMtx(:,:,1) = repmat((1:1:rows)', 1, cols);
coordinateMtx(:,:,2) = repmat(1:1:cols, rows, 1);

centerY = rows / 2;
centerX = cols / 2;
centerMtx(:,:,1) = ones(rows, cols) * centerY;
centerMtx(:,:,2) = ones(rows, cols) * centerX; 
SDMap = exp(-sum((coordinateMtx - centerMtx).^2,3) / sigmaD^2);

im_out=double(segments).* SDMap;
im_out=uint8((im_out/max(max(im_out)))*255);
figure,imshow(im_out);













            
            
