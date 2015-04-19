%% 作业一

clear;
clc;


%% 读入图像

image_name='./flower10.jpg';
image=imread(image_name);


%% 1-1 压缩图像

[oriRows,oriCols,junk]=size(image);
im_compress(:,:,1)=image(:,:,1)./16;
im_compress(:,:,2)=image(:,:,2)./16;
im_compress(:,:,3)=image(:,:,3)./16;

% im_gray：用1到4096表示的图像矩阵
for m=1:oriRows
    for n=1:oriCols
       im_gray(m,n)=uint16(im_compress(m,n,1))+uint16(im_compress(m,n,2))*16+uint16(im_compress(m,n,3))*16^2+1;
    end
end



%% 1-2 超像素分割

im_lab=vl_xyz2lab(vl_rgb2xyz(image));
im_single=single(im_lab);

region_size=25; %每块大小 自己设定
regularizer=0.1; %调整尺度 自己设定
segments = vl_slic(im_single,region_size, regularizer);%segments：分割后存储每块标签的矩阵


% 用于显示分割后的图像
[sx,sy]=vl_grad(double(segments), 'type', 'forward');%求梯度 
s=find(sx|sy);%梯度的索引做成向量
im_seg=image;
im_seg([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))])=0 ;

figure,imshow(im_seg);


%% 2.各个超像素的直方图

seg_num=max(max(segments))+1;   %确定超像素分割的分块数
seg_store=zeros(4000,seg_num,'double');%seg_store:按超像素标签把原像素分类并存于矩阵
seg_count=zeros(1,seg_num);%统计每块超像素内像素个数 
for m=1:oriRows
    for n=1:oriCols
        label=segments(m,n)+1;%取出超像素中某个像素的标签并加一
        row_zero=find(seg_store(:,label)<1); %矩阵第label列零元素的索引组成数组
        first_zero=row_zero(1);  %找出矩阵第label列第一个零元素位置
        seg_store(first_zero,label)=im_gray(m,n);%把当前位置的像素值赋给第label列第一个零元素的位置
        seg_count(1,label)=seg_count(1,label)+1;%第label列的元素数加一
    end
end


%画直方图并存储结果
hist_size=128; %直方图条数

store_hist=zeros(hist_size,seg_num);%存储直方图向量的矩阵
for m=1:seg_num
    store_hist(:,m)=hist(double(seg_store(1:seg_count(m),m)),hist_size); %画第m块的直方图
end

% store_Count=zeros(seg_num,hist_size);
% store_X=zeros(seg_num,hist_size);
% for m=1:seg_num
%    [store_Count(m,:),store_X(m,:)]= hist(double(seg_store(1:seg_count(m),m)),hist_size);
% end

%% 3.计算超像素特征对比

%巴氏系数计算直方图距离
% Sum=sum(store_Count,2);
% distance=zeros(seg_num,1);
% diff=0;
% for m=1:seg_num
%     for n=1:seg_num
%         Sumup=sqrt(store_Count(m,:).*store_Count(n,:));
%         SumDown=sqrt(Sum(m)*Sum(n));
%         Sumup=sum(Sumup);
%         diff=1-sqrt(1-Sumup/SumDown)+diff;
%     end
%     distance(m)=diff;
%     diff=0;
% end

 diff=0;
 temp=0;
for k=1:seg_num   for m=1:seg_num
       diff=2*sum((store_hist(:,k).^2-store_hist(:,m).^2)./(store_hist(:,k)+eps))+diff;%将公式稍作修改
   end % 计算(h1,h1)+(h1,h2)+(h1,h3)+...+(h1,hn)
    distance(k,1)=diff;
    diff=0;
end

  

%% 4.Convert superpixel saliency to pixel saliency

%量化全局对比度
for m=1:size(distance)
    pixel(m)=(distance(m)-min(distance))/(max(distance)-min(distance))*255;%%%%%%%%%%%
end 

%用全局对比度代替原像素
im_last=zeros(oriRows,oriCols);
for m=1:oriRows
    for n=1:oriCols
        label=segments(m,n)+1;
        im_last(m,n)=pixel(label);
    end
end

average=sum(sum(im_last))/(oriRows*oriCols);
for m=1:oriRows
    for n=1:oriCols
        if im_last(m,n)<average;
            im_last(m,n)=im_last(m,n)/3;
        else im_last(m,n)=im_last(m,n)+(255-im_last(m,n))*0.5;
        end
    end
end

im_last=uint8(im_last);
figure,imshow(im_last);


%% 5.用center piror增强

sigmaD = 130; %设置参数
[rows, cols, junk] = size(image);

coordinateMtx = zeros(rows, cols, 2);
coordinateMtx(:,:,1) = repmat((1:1:rows)', 1, cols);
coordinateMtx(:,:,2) = repmat(1:1:cols, rows, 1);

centerY = rows / 2;
centerX = cols / 2;
centerMtx(:,:,1) = ones(rows, cols) * centerY;
centerMtx(:,:,2) = ones(rows, cols) * centerX;
SDMap = exp(-sum((coordinateMtx - centerMtx).^2,3) / sigmaD^2);
figure,imshow(uint8(SDMap*255));

%颜色prior
% sigmaC = 0.25;
% LChannel = im_lab(:,:,1);
% AChannel = im_lab(:,:,2);
% BChannel = im_lab(:,:,3);
% maxA = max(AChannel(:));
% minA = min(AChannel(:));
% normalizedA = (AChannel - minA) / (maxA - minA);
% maxB = max(BChannel(:));
% minB = min(BChannel(:));
% normalizedB = (BChannel - minB) / (maxB - minB);
% labDistSquare = normalizedA.^2 + normalizedB.^2;
% SCMap = 1 - exp(-labDistSquare / (sigmaC^2));

im_out=double(im_last).* SDMap; %center prior增强图像
% im_out=double(im_last).* SDMap.*SCMap; %用center prior和color prior增强图像
im_out=uint8((im_out/max(max(im_out)))*255);
figure,imshow(im_out);


