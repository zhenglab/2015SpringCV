clc
clear
%�����ǰcommand���������͹����ռ�


%%

%1.��ͼ�����ѹ��
image_name = './005.jpg';
image = imread(image_name);   %����ͼ��
subplot(2,2,1),imshow(image_name),title('ԭͼ');

[i,j,k]=size(image);         %�õ���ά����ĳ߶�
image_compress=zeros(i,j);  
double(image_compress);
%����һ���߶�Ϊ(i,j)�Ŀվ��󣬲�ʹ�䶨��Ϊdouble����
for m=1:i
    for n=1:j
       image_compress(m,n)=double(image(m,n,1)/8)+double(image(m,n,2)/8)*32+double(image(m,n,3)/8)*32^2;
    end
end
%ͨ��forѭ��,��ÿ�����ϵ�RGB����ͨ����ֵѹ��Ϊһ��ֵ���ҷ�Χ��1��32768,����image_compress������


%%

%2.�����طָ�
im_lab=vl_xyz2lab(vl_rgb2xyz(image));
im_single=single(im_lab);

region_size=30;%����ÿ��ָ��С 
regularizer=0.1;%�����߶� 
segments = vl_slic(im_single,region_size, regularizer);%�����طָ�
[ix,iy]=vl_grad(double(segments), 'type', 'forward');%���ݶ� 
 s=find(ix|iy);%�ݶȵ�������������
 imp=image;
imp([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))]) = 0 ;
subplot(2,2,2),imshow(imp),title('�����طָ��');

%%

%3.����Ϊ����ֱ��ͼ����

seg_num=max(max(segments));  %�����segments�����ֵ���������صĸ�����1
store_1=zeros(seg_num+1,[]);  %����һ��double�͵�����󣬾������ⳤ�ȵ���
% count=1;      %��1��ʼ����
hist_num=128;   %ֱ��ͼ��Ϊ128��
store_hist=zeros(seg_num+1,hist_num);   %�洢ֱ��ͼ��ÿ������������������ʽ�洢
for k=0:seg_num  
    count=1;
    for m=1:i
        for n=1:j
            if segments(m,n)==k;    %�ѳ����ص���k�������ҵ����Ӧ������image_compress��ֵ
                store_1(k+1,count)=image_compress(m,n); %��ѹ����ı�ǩimage_compress��ֵ�ŵ�store_1����ĵ�k+1��
                count=count+1;        %������һ
            end
        end
    end
    store_hist(k+1,:)=hist(store_1(k+1,1:count-1),hist_num);   %��store_1�ĵ�k+1�е�ǰ1��count-1�������໭ֱ��ͼ��
    %ά����hist_num
%     count=1;      
end
%%

%4.���㳬���صĶԱȶ�

 diff=0;
for k=1:seg_num+1
   for m=1:seg_num+1
        diff=2*sum((store_hist(k,:)-store_hist(m,:)).^2./(store_hist(k,:)+store_hist(m,:)+eps))+diff;

   end    % ����(hk,h1)+(hk,h2)+(hk,h3)+...+(hk,hn)
   distance(k,1)=(diff/double(seg_num));    %hk����������ƽ��ֵ
   diff=0;
end
%%

%5.����ȫ�ֶԱȶ�
for m=1:size(distance)
    pixel(m)=(distance(m)-min(distance))/(max(distance)-min(distance))*255;
end 
 %��ȫ�ֶԱȶȴ���ԭ����
im_last=zeros(i,j);      %����һ��i��j�еĿվ���
for m=1:i
    for n=1:j
        M=segments(m,n)+1;
        im_last(m,n)=fix((pixel(M)));   %����M�鳬���ص�ȫ�ֶԱȶȴ����Ӧ��im_last ������
    end
end

im_last=uint8(im_last);        %ת��Ϊunit8����      
subplot(2,2,3),imshow(im_last),title('�����ԱȶȺ�');
%%

%6.������֪ʶ��ǿ���


sigmaD = 150; %���ò���
[i, j, k] = size(image);

coordinateMtx = zeros(i, j, 2);
coordinateMtx(:,:,1) = repmat((1:1:i)', 1, j);
coordinateMtx(:,:,2) = repmat(1:1:j, i, 1);

centerY = i / 2;
centerX = j / 2;
centerMtx(:,:,1) = ones(i, j) * centerY;
centerMtx(:,:,2) = ones(i, j) * centerX;
SDMap = exp(-sum((coordinateMtx - centerMtx).^2,3) / sigmaD^2);

%��ɫprior
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

% im_out=double(im_last).* SDMap; %center prior��ǿͼ��
im_out=double(im_last).* SDMap.*SCMap; %��center prior��color prior���ַ���ͬʱ��ǿͼ��
im_out=uint8((im_out/max(max(im_out)))*255);
subplot(2,2,4),imshow(im_out),title('������ǿ��');





            
            
