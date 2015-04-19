clear;
image= imread( '.\1.jpg');
%%
%step1-1 get information
r=image(:,:,1);
g=image(:,:,2);
b=image(:,:,3);%�ֱ��ȡRGBͨ���Ҷ�ͼ

r=imdivide(r,8);
g=imdivide(g,8);
b=imdivide(b,8);%�Ҷ�ֵѹ����0-31

r=im2double(r);
g=im2double(g);
b=im2double(b);%����֮ǰת��Ϊdouble����

image2=r+g*32+b*32*32;       %��RGB��ά����ѹ��Ϊһά����
%%
%step1-2 segment
im_xyz=vl_rgb2xyz(image);
imlab = vl_xyz2lab(im_xyz) ;
im_single = single(imlab);%������

region_size=20;%�ֿ�ߴ�
regularizer=0.5;%�����߶�
segments = vl_slic(im_single,region_size, regularizer);%�����طָ�
%��ʾ�ָ�ͼ
[sx,sy]=vl_grad(double(segments), 'type', 'forward');%���ݶ� 
s=find(sx|sy);%�ݶȵ�������������
imsegments=image;
imsegments([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))]) = 0 ;
%figure,imshow(imsegments);
%%
%step2 color histogram
[m n]=size(segments);   %ԭͼ��С
num_bin=512;%ֱ��ͼ��Ŀ
comp3=zeros(max(max(segments)),[],'double');      %��comp3��i+1�洢ԭͼ��i�鳬���ذ�������������ֵ
co_hist=zeros(max(max(segments)),num_bin);   %co_hist�����洢h��ֱ��ͼ
for h=0:max(max(segments))      %hΪ�ָ�Ŀ���
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
for j=0:h  %j��ʾÿһ��������
    for i=1:num_bin  %��ʾith component
        for y=1:h+1  %����ÿһ��������
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
        im_saliency(x,y)=255*(contrast(1,segments(x,y)+1)-min(contrast))/(max(contrast)-min(contrast));    %������0-255֮��
    end
end
%figure,imshow(im_saliency);
%%
%step5 use prior to enhance
sigmaF = 6.2;
omega0 = 0.002;
sigmaD = 100;
sigmaC = 0.25; %���ò���
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
