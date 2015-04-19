clear all;

%step 1-1:
I=imread('F:\matlab\flower.jpg');
%求r,g,b三个信道图像
Image_R=I(:,:,1);
Image_G=I(:,:,2);
Image_B=I(:,:,3);
figure,subplot(2,2,1);
imshow(I);
subplot(2,2,2);
imshow(Image_R);
subplot(2,2,3);
imshow(Image_G);
subplot(2,2,4);
imshow(Image_B);
%改为16位图像显示
Image_R=uint16(Image_R);
Image_G=uint16(Image_G);
Image_B=uint16(Image_B);
R1=Image_R./16;
G1=Image_G./16;
B1=Image_B./16;
figure,subplot(2,2,1);
imshow(R1);
subplot(2,2,2);
imshow(G1);
subplot(2,2,3);
imshow(B1);
R2=R1.*256;
G2=G1.*16;
B2=B1;
I2=R2+G2+B2;

%step 1-2
 
%超像素分割
I3 = vl_xyz2lab(vl_rgb2xyz(I)) ;
I_single = single(I3);
segments = vl_slic(I_single,30, 0.1) ;         
[sx,sy]=vl_grad(uint16(segments), 'type', 'forward') ;  
 s = find(sx | sy) ;  
 image_segments = I ;  
 image_segments([s s+numel(I(:,:,1)) s+2*numel(I(:,:,1))]) = 0 ;  
 %画出分割图
 figure;
 title('分割结果');
 imshow(image_segments);

%step 2-1
[m n]=size(segments);
feat=zeros(140,4096);      %RGB4第i+1行为第i块超像素包含的像素（颜色分布）
RGB4=zeros(140,[]);
hismatrix=zeros(140,10);
for x=0:139
    y=0;
    for i=1:m
        for j=1:n
            if segments(i,j)==x
                RGB4(x+1,y+1)=I2(i,j);
                y=y+1;
            end
        end
    end
    feat(x+1,[1,4096])=hist(RGB4(x+1,1:y-1),[1,4096]);
end

%step3
%计算每个超像素的全局对比度
num_sup=max(max(segments));
feature=zeros(1,num_sup+1,'double');
for i=0:num_sup
    for x=1:256
        for y=1:num_sup+1
            if feat(i+1,x)+feat(y,x)~=0
                feature(1,i+1)=feature(1,i+1)+2*(feat(i+1,x)-feat(y,x))*(feat(i+1,x)-feat(y,x))/(feat(i+1,x)+feat(y,x));
            end
        end
    end
end

%step4
%将超像素全局对比度推广到像素对比度,fea_p是推广后的图像,并以适当的灰度范围显示
feat_p=zeros(m,n);
for x=1:m
    for y=1:n
        feat_p(x,y)=feature(1,segments(x,y)+1);
    end
end
figure,imshow(imdivide(feat_p,max(max(feature))));

%step5

sigmaF = 6.2;
omega0 = 0.002;
sigmaD = 114;
sigmaC = 0.25;
image=I;
%把图像转换到Lab色度域
[oriRows, oriCols, junk] = size(image);
image = double(image);
dsImage(:,:,1) = imresize(image(:,:,1), [256, 256],'bilinear');
dsImage(:,:,2) = imresize(image(:,:,2), [256, 256],'bilinear');
dsImage(:,:,3) = imresize(image(:,:,3), [256, 256],'bilinear');
lab = RGB2Lab(dsImage); 

LChannel = lab(:,:,1);
AChannel = lab(:,:,2);
BChannel = lab(:,:,3);

LFFT = fft2(double(LChannel));
AFFT = fft2(double(AChannel));
BFFT = fft2(double(BChannel));

[rows, cols, junk] = size(dsImage);
LG = logGabor(rows,cols,omega0,sigmaF);
FinalLResult = real(ifft2(LFFT.*LG));
FinalAResult = real(ifft2(AFFT.*LG));
FinalBResult = real(ifft2(BFFT.*LG));

SFMap = sqrt(FinalLResult.^2 + FinalAResult.^2 + FinalBResult.^2);

%中心先验
coordinateMtx = zeros(rows, cols, 2);
coordinateMtx(:,:,1) = repmat((1:1:rows)', 1, cols);
coordinateMtx(:,:,2) = repmat(1:1:cols, rows, 1);

centerY = rows / 2;
centerX = cols / 2;
centerMtx(:,:,1) = ones(rows, cols) * centerY;
centerMtx(:,:,2) = ones(rows, cols) * centerX;
SDMap = exp(-sum((coordinateMtx - centerMtx).^2,3) / sigmaD^2);
maxA = max(AChannel(:));
minA = min(AChannel(:));
normalizedA = (AChannel - minA) / (maxA - minA);

maxB = max(BChannel(:));
minB = min(BChannel(:));
normalizedB = (BChannel - minB) / (maxB - minB);

labDistSquare = normalizedA.^2 + normalizedB.^2;
SCMap = 1 - exp(-labDistSquare / (sigmaC^2));
VSMap = SFMap .* SDMap .* SCMap;

VSMap =  imresize(VSMap, [oriRows, oriCols],'bilinear');
VSMap = uint8(mat2gray(VSMap) * 255);
prim=im2double(VSMap);
final=feat_p.*prim;
figure,imshow(imdivide(final,max(max(final))));



