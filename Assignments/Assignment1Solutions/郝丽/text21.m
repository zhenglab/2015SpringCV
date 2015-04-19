clc
clear
%%
%����ͼ��
image_name = '0_7_7804.jpg';
image = imread( image_name );
subplot(2,2,1),imshow(image_name),title('ԭͼ');
%%
%����ɫ��ͨ��������ɫ������
[i,j,k]=size(image);%image�Ĺ��
group=zeros(i,j);%����һ��ȫ0�Ķ�ά���飬i��j��
uint16(group);%������compת��ΪUint16����

for m=1:i
    for n=1:j
       group(m,n)=uint16(image(m,n,1)/16)+uint16(image(m,n,2))+uint16(image(m,n,3))*16;
    end
end
%%
%�����طָ�
lab_picture=vl_xyz2lab(vl_rgb2xyz(image));%��image��rgbת��Ϊxyz������xyzת��Ϊlab��ʽ
single_picture=single(lab_picture);
block_size=30; %ÿ���С����Ϊ30 
measurement=0.1; %�߶�����Ϊ0.1 
segment = vl_slic(single_picture,block_size, measurement);%�����طָ�ָ����vl_slic
%�����ݶȵķ�������ʾͼ��
[sx,sy]=vl_grad(double(segment), 'type', 'forward');%��segments������ת����double�����ݶ� 
s=find(sx|sy);%�ݶȵ�������������
segment_picture=image;
segment_picture([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))])=0 ;
subplot(2,2,2),imshow(segment_picture),title('�ָ��');
%%
% ��ÿ�鳬�����ڵ���ֵ���뵽ĳһά�����ٽ��з���
[m n]=size(segment);
num=200;%����ֱ��ͼ��������
numb=max(max(segment));%�ֿ��ǩ���ֵ
hist0=zeros(numb,[],'double');      %hist0Ϊ��numbΪ�У������е�0����
hist1=zeros(numb,num);%hist1Ϊ0����
for i=0:max(max(segment))%i��ȡֵΪ��0����ǩ���ֵ
    j=1;
    for x=1:m
        for y=1:n
             if segment(x,y)==i  %���segments(x,y)��ֵΪi
                hist0(i+1,j)=group(x,y);%��comp(x,y)����RGB1(i+1,j)
                j=j+1;
           end
        end
    end
    hist1(i+1,[1:num])=hist(hist0(i+1,1:j-1),num);%��ֱ��ͼ��
end
%����ÿ�������ص�ȫ�ֶԱȶ�
compare=zeros(1,numb+1,'double');%compareΪ��umb+1Ϊ�У������е�0����
for i=0:numb
    for x=1:num %x��0���ֿ�Ŀ���
        for y=1:numb+1 %y��1����ǩ���ֵ+1
            if hist1(i+1,x)+hist1(y,x)~=0 %��ĸ����Ϊ0
                compare(1,i+1)=2*(hist1(i+1,x)-hist1(y,x))*(hist1(i+1,x)-hist1(y,x))/(hist1(i+1,x)+hist1(y,x))+compare(1,i+1);  %ֱ��ͼ������㹫ʽ        
            end
        end
    end
end

%��������ȫ�ֶԱȶȴ��浽���ضԱȶ�
pixel_compare=zeros(m,n);
for x=1:m
    for y=1:n
        pixel_compare(x,y)=compare(1,segment(x,y)+1);%�ҵ�����Ϊxy��ȫ�ֶԱȶȣ������丳������Ϊxy�����ص�
    end
end
subplot(2,2,3),imshow(imdivide(pixel_compare,max(max(compare)))),title('�Աȶ�������ͼ��');
%%
%��center prior��ǿ
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
subplot(2,2,4),imshow(im_out),title('��ǿ��');










