clear;
image= imread( '.\1.jpg');
%%
%step1-1 get information
r=image(:,:,1);
g=image(:,:,2);
b=image(:,:,3);%分别读取RGB通道灰度图

r=imdivide(r,8);
g=imdivide(g,8);
b=imdivide(b,8);%灰度值压缩到0-31

r=im2double(r);
g=im2double(g);
b=im2double(b);%计算之前转换为double类型

image2=r+g*32+b*32*32;       %将RGB三维矩阵压缩为一维矩阵
%%
%step1-2 segment
im_xyz=vl_rgb2xyz(image);
imlab = vl_xyz2lab(im_xyz) ;
im_single = single(imlab);%单精度

region_size=20;%分块尺寸
regularizer=0.5;%调整尺度
segments = vl_slic(im_single,region_size, regularizer);%超像素分割
%显示分割图
[sx,sy]=vl_grad(double(segments), 'type', 'forward');%求梯度 
s=find(sx|sy);%梯度的索引做成向量
imsegments=image;
imsegments([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))]) = 0 ;
%figure,imshow(imsegments);
%%
%step2 color histogram
[m n]=size(segments);   %原图大小
num_bin=512;%直方图数目
comp3=zeros(max(max(segments)),[],'double');      %用comp3第i+1存储原图第i块超像素包含的所有像素值
co_hist=zeros(max(max(segments)),num_bin);   %co_hist用来存储h个直方图
for h=0:max(max(segments))      %h为分割的块数
    i=1;
    for x=1:m
        for y=1:n
            if segments(x,y)==h
                comp3(h+1,i)=image2(x,y);
                i=i+1;
            end
        end
    end
    co_hist(h+1,[1:num_bin])=hist(comp3(h+1,1:i-1),num_bin);
end
%%
%step3 feature contrast
 h=max(max(segments));
contrast=zeros(1,h+1,'double');
for j=0:h  %j表示每一个超像素
    for i=1:num_bin  %表示ith component
        for y=1:h+1  %遍历每一个超像素
             a=co_hist(j+1,i)-co_hist(y,i);
             b=co_hist(j+1,i);
             %b=co_hist(j+1,i)+co_hist(y,i);
            if b>eps
             contrast(1,j+1)=contrast(1,j+1)+2*a^2/b;
            end
        end
    end
end

%%
%step4 pixel saliency
im_saliency=zeros(m,n);
for x=1:m
    for y=1:n
        im_saliency(x,y)=255*(contrast(1,segments(x,y)+1)-min(contrast))/(max(contrast)-min(contrast));    %量化到0-255之间
    end
end
%figure,imshow(im_saliency);
%%
%step5 use prior to enhance
sigmaF = 6.2;
omega0 = 0.002;
sigmaD = 100;
sigmaC = 0.25; %设置参数
[rows, cols, junk] = size(image);

coordinateMtx = zeros(rows, cols, 2);
coordinateMtx(:,:,1) = repmat((1:1:rows)', 1, cols);
coordinateMtx(:,:,2) = repmat(1:1:cols, rows, 1);
%center priors
centerY = rows / 2.2;
centerX = cols / 2.4;
centerMtx(:,:,1) = ones(rows, cols) * centerY;
centerMtx(:,:,2) = ones(rows, cols) * centerX;
SDMap = exp(-sum((coordinateMtx - centerMtx).^2,3) / sigmaD^2);

%color priors
Achannel=imlab(:,:,2);
Bchannel=imlab(:,:,3);
maxA = max(max(Achannel));
minA = min(min(Achannel));
normalizedA = (Achannel-minA )/ (maxA-minA);

maxB = max(max(Bchannel));
minB = min(min(Bchannel));
normalizedB = (Bchannel-minB) / (maxB - minB);

labDistSquare = normalizedA.^2 + normalizedB.^2;
SCMap = 1 - exp(-labDistSquare / (sigmaC^2));

VSMap = SDMap .* SCMap;


priormap=double(VSMap);
final=im_saliency .*priormap;


figure,imshow(image),title('Image');
figure,imshow(imdivide(image2,max(max(image2)))),title('Image Information');
figure,imshow(imsegments),title('Superpixel segmentation');
im_saliency=uint8(im_saliency);
figure,imshow(im_saliency),title('Initial saliency map');
figure,imshow((final-min(min(final)))/(max(max(final))-min(min(final)))),title('Final image');
