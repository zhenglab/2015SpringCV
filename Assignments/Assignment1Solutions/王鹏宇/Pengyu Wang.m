clc;
clear;
%step1-1
%输入图像
RGB=imread('4.jpg');
%将RGB图像分为三个通道的灰度图
R=RGB(:,:,1);
G=RGB(:,:,2);
B=RGB(:,:,3);
%将灰度范围压缩到0-16
R=R/8;
G=G/8;
B=B/8;
%将像素数值类型从uint8转化为double
R=double(R);
G=double(G);
B=double(B);


%将三通道颜色通过0-4096的单数值表示,并显示单值表示后的图像
RGB2=R*32*32+G*32+B;        %RGB2为颜色单值表示后的一维矩阵
figure,imshow(imdivide(RGB2,max(max(RGB2)))),title('颜色单值化图像');

%step1-2
%使用vlfeat产生超像素分割矩阵
imlab=vl_xyz2lab(vl_rgb2xyz(RGB));
% imlab=vl_rgb2xyz(RGB);
imlab=single(imlab);
segments=vl_slic(imlab,20,0.1);
num_sup=max(max(segments));
[m n] = size(segments); 
  
 
[sx,sy]=vl_grad(double(segments), 'type', 'forward') ;  
 s = find(sx | sy) ;  
 imp = RGB ;  
 imp([s s+numel(imp(:,:,1)) s+2*numel(imp(:,:,1))]) = 0 ;  
  
o = imp;
figure,imshow(o);

%step2


num_bin=512;
RGB3=zeros(num_sup,[],'double');      %RGB3第i+1行为第i块超像素包含的像素（颜色分布）
his=zeros(num_sup,num_bin);
for i=0:num_sup
    j=1;
    for x=1:m
        for y=1:n
            if segments(x,y)==i
                RGB3(i+1,j)=RGB2(x,y);
                j=j+1;
            end
        end
    end
    his(i+1,[1:num_bin])=hist(RGB3(i+1,1:j-1),num_bin)/(j+1);
end

%step3
%计算每个超像素的全局对比度

feature=zeros(1,num_sup+1,'double');
for i=0:num_sup
    for x=1:num_bin
        for y=1:num_sup+1
            a=his(i+1,x)-his(y,x);
            b=his(i+1,x);
            if b>eps
                feature(1,i+1)=feature(1,i+1)+a*a/b;
            end     
        end
    end
end

%step4
%将超像素全局对比度推广到像素对比度,fea_p是推广后的图像,并以适当的灰度范围显示
fea_p=zeros(m,n,'double');
for x=1:m
    for y=1:n
        fea_p(x,y)=feature(1,segments(x,y)+1);
    end
end
figure,imshow((fea_p-min(min(fea_p)))/(max(max(feature))-min(min(fea_p)))),title('先验知识前显著图');

%step5
%使用两种先验知识对提取结果进行优化

sigmaF = 6.2;
omega0 = 0.002;
sigmaD = 114;
sigmaC = 0.25;
coordinateMtx = zeros(m, n, 2);
coordinateMtx(:,:,1) = repmat((1:1:m)', 1, n);
coordinateMtx(:,:,2) = repmat(1:1:n, m, 1);

%center priors
centerY = m / 2;
centerX = n / 2;
centerMtx(:,:,1) = ones(m, n) * centerY;
centerMtx(:,:,2) = ones(m, n) * centerX;
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
final=fea_p.*priormap;
figure,imshow((final-min(min(final)))/(max(max(final))-min(min(final)))),title('最后图像');



                
                
                
                
                
            
