clc;
clear;
%%
%step 1-1 extract image information
image = imread('C:\Users\Administrator\Desktop\005.jpg');   %����ͼ��
figure,subplot(2,2,1),imshow(image); %��ȡԭͼ����ʾ
[m,n,d]=size(image);         %catch the height and width of the map
 B = double(image(:,:,3));%��ֳ���ͨ����ת��Ϊ˫��������
 G = double(image(:,:,2));
 R = double(image(:,:,1));
 R = R/16;%ÿ��ͨ��ѹ��16�����߲���forѭ����ÿ�����ص�ֵ������1-15
 G = G/16;
 B = B/16;
 RGB=B*16*16+G*16+R;        %RGBΪ��ɫ��ֵ��ʾ���һά����
subplot(222),imshow(imdivide(RGB,max(max(RGB))));%4096
%ÿ��ͨ��ѹ��16�����߲���forѭ����ÿ�����ص�ֵ������1-15


%%
%step1-2.segment the input image into superpixels
im_lab = vl_xyz2lab(vl_rgb2xyz(image)) ;%% im contains the image in RGB format as beforeת����xyz\lab�ռ�
im_single=single(im_lab);%single����im contains the input RGB image as a SINGLE array
region_size=40;%ÿ�鳬���صĴ�С
regularizer=0.01;%�����ĳ߶ȴ�С 
segments = vl_slic(im_single,region_size, regularizer);%����lsic������õ������ؾ���
[sx,sy]=vl_grad(double(segments), 'type', 'forward');%���ݶ� 
 s=find(sx|sy);%�ݶȵ�������������
 imp=image;
imp([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))]) = 0 ;

subplot(223),imshow(imp);%�����طָ���ͼ��
%subplot(223),imshow(segments*(4294967296/140));%�ݶ�


%%
 %step 2-1 compute features of each superpixel
 [p,q]=size(segments);
%seg_num=max(max(segments));  %�����segments�����ֵ���������صĸ�����1
store_his=zeros(max(max(segments))+1,[],'double');  %����һ��double�͵�����󣬾������ⳤ�ȵ���
 
store_hist=zeros(max(max(segments))+1,256,'double');   %�洢ֱ��ͼ��ÿ������������������ʽ�洢
for k=0:max(max(segments)) %��1��ʼ���� ,�����г����ص����ɨ�账���������б�ǩ��ͬ�ĳ����ص�
    %���ڵ�λ�ü�����������һ����������
    count=1;
    for i=1:p
        for j=1:q
            if segments(i,j)==k;    %�ѳ����ص���k�������ҵ����Ӧ������RGB��ֵ
                store_his(k+1,count)=RGB(i,j); %����Ӧ��ѹ�����RGBֵ�ŵ�store_his����ĵ�k+1��count��
                count=count+1;        %������һѭ��
            end
        end
    end
    store_hist(k+1,:)=hist(store_his(k+1,1:count-1),256);%��store_his�ĵ�k+1�е�ǰ1��count-1�������໭ֱ��ͼ��
    %ά����256
end



%%

%step3 ����ÿ�������ص�ȫ�ֶԱȶ�

 diff=0;
for k=1:max(max(segments))+1
   for j=1:max(max(segments))+1
        diff=2*sum((store_hist(k,:)-store_hist(j,:)).^2./(store_hist(k,:)+store_hist(j,:)+eps))+diff;
   end    % ����������Ĺ�ʽ����(hk,h1)+(hk,h2)+(hk,h3)+...+(hk,hn)
   distance(k,1)=(diff/double(max(max(segments))));    %hk����������ƽ��ֵ
   diff=0;
end
%%

for i=1:size(distance)
    pixel(i)=(distance(i)-min(distance))/(max(distance)-min(distance))*255;%����ȫ�ֶԱȶ�
end 
 %��ȫ�ֶԱȶȴ���ԭ����
im_last=zeros(m,n);      %����һ��mn�Ŀվ���
for i=1:m
  for j=1:n
      segment=segments(i,j)+1;
      im_last(i,j)=fix((pixel(segment)));%����M�鳬���ص�ȫ�ֶԱȶȴ����Ӧ��im_last �����У���ȫ�ֶԱȶȴ���ԭ����
   end
end

im_last=uint8(im_last);        %ת��Ϊunit8����      
subplot(224),imshow(im_last);
%%

%6.������֪ʶ��ǿ���
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













            
            
