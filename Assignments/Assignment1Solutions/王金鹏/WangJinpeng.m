%% ��ҵһ

clear;
clc;


%% ����ͼ��

image_name='./flower10.jpg';
image=imread(image_name);


%% 1-1 ѹ��ͼ��

[oriRows,oriCols,junk]=size(image);
im_compress(:,:,1)=image(:,:,1)./16;
im_compress(:,:,2)=image(:,:,2)./16;
im_compress(:,:,3)=image(:,:,3)./16;

% im_gray����1��4096��ʾ��ͼ�����
for m=1:oriRows
    for n=1:oriCols
       im_gray(m,n)=uint16(im_compress(m,n,1))+uint16(im_compress(m,n,2))*16+uint16(im_compress(m,n,3))*16^2+1;
    end
end



%% 1-2 �����طָ�

im_lab=vl_xyz2lab(vl_rgb2xyz(image));
im_single=single(im_lab);

region_size=25; %ÿ���С �Լ��趨
regularizer=0.1; %�����߶� �Լ��趨
segments = vl_slic(im_single,region_size, regularizer);%segments���ָ��洢ÿ���ǩ�ľ���


% ������ʾ�ָ���ͼ��
[sx,sy]=vl_grad(double(segments), 'type', 'forward');%���ݶ� 
s=find(sx|sy);%�ݶȵ�������������
im_seg=image;
im_seg([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))])=0 ;

figure,imshow(im_seg);


%% 2.���������ص�ֱ��ͼ

seg_num=max(max(segments))+1;   %ȷ�������طָ�ķֿ���
seg_store=zeros(4000,seg_num,'double');%seg_store:�������ر�ǩ��ԭ���ط��ಢ���ھ���
seg_count=zeros(1,seg_num);%ͳ��ÿ�鳬���������ظ��� 
for m=1:oriRows
    for n=1:oriCols
        label=segments(m,n)+1;%ȡ����������ĳ�����صı�ǩ����һ
        row_zero=find(seg_store(:,label)<1); %�����label����Ԫ�ص������������
        first_zero=row_zero(1);  %�ҳ������label�е�һ����Ԫ��λ��
        seg_store(first_zero,label)=im_gray(m,n);%�ѵ�ǰλ�õ�����ֵ������label�е�һ����Ԫ�ص�λ��
        seg_count(1,label)=seg_count(1,label)+1;%��label�е�Ԫ������һ
    end
end


%��ֱ��ͼ���洢���
hist_size=128; %ֱ��ͼ����

store_hist=zeros(hist_size,seg_num);%�洢ֱ��ͼ�����ľ���
for m=1:seg_num
    store_hist(:,m)=hist(double(seg_store(1:seg_count(m),m)),hist_size); %����m���ֱ��ͼ
end

% store_Count=zeros(seg_num,hist_size);
% store_X=zeros(seg_num,hist_size);
% for m=1:seg_num
%    [store_Count(m,:),store_X(m,:)]= hist(double(seg_store(1:seg_count(m),m)),hist_size);
% end

%% 3.���㳬���������Ա�

%����ϵ������ֱ��ͼ����
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
       diff=2*sum((store_hist(:,k).^2-store_hist(:,m).^2)./(store_hist(:,k)+eps))+diff;%����ʽ�����޸�
   end % ����(h1,h1)+(h1,h2)+(h1,h3)+...+(h1,hn)
    distance(k,1)=diff;
    diff=0;
end

  

%% 4.Convert superpixel saliency to pixel saliency

%����ȫ�ֶԱȶ�
for m=1:size(distance)
    pixel(m)=(distance(m)-min(distance))/(max(distance)-min(distance))*255;%%%%%%%%%%%
end 

%��ȫ�ֶԱȶȴ���ԭ����
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


%% 5.��center piror��ǿ

sigmaD = 130; %���ò���
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

%��ɫprior
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

im_out=double(im_last).* SDMap; %center prior��ǿͼ��
% im_out=double(im_last).* SDMap.*SCMap; %��center prior��color prior��ǿͼ��
im_out=uint8((im_out/max(max(im_out)))*255);
figure,imshow(im_out);


