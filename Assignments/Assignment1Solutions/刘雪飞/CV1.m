%��ȡԭͼ����ʾ
I=imread('C:\Users\Administrator\Desktop\cv1.png');
figure,subplot(221),imshow(I),title('ԭʼͼ��');
[m,n]=size('I');%ͼ��Ĵ�С
%%
%step 1-1 extract image information
  B = double(I(:,:,3));%��ֳ���ͨ��
  G = double(I(:,:,2));
  R = double(I(:,:,1));
  R = R/16;%ÿ��ͨ��ѹ��16�����߲���forѭ����ÿ�����ص�ֵ������1-15
  G = G/16;
  B = B/16;
 H(:,:,3)=B;
 H(:,:,2)=G;
 H(:,:,1)=R;
 %figure,imshow(H)            %HΪ����ɫ�任��Ĳ�ɫͼ��
  RGB=B*16*16+G*16+R;        %RGBΪ��ɫ��ֵ��ʾ���һά����
subplot(222),imshow(imdivide(RGB,max(max(RGB))));%4096
  %imshow(image);
  %figure,imshow(I); 
  %%
  %step 1-2 segment the input image into superpixels
  % im contains the input RGB image as a SINGLE array
regionSize = 30;%ÿ�鳬���صĴ�С
regularizer = 1;%�����ĳߴ�
imlab = vl_xyz2lab(vl_rgb2xyz(I)) ;%% IM contains the image in RGB format as beforeת����xyz\lab�ռ�
i=single(imlab);
segments = vl_slic(i, regionSize, regularizer) ;%����lsic������õ������ؾ���
%figure,imshow(segments);
%[sm,sn]=vl_grad(double(segments), 'type', 'forward');%���ݶ� 
%s=find(sm|sn);%�ݶȵ�������������
%image=i;
%imag([s s+numel(I(:,:,1)) s+2*numel(I(:,:,1))]) = 0 ;
%,imshow(image),title('�����طָ���ͼ��');
subplot(223),imshow(segments*(4294967296/140));%�ݶ���С
%%
 %step 2-1 compute features of each superpixel
 [p,q]=size(segments);
RGB1=zeros(max(max(segments)),[],'double');  %�����洢ÿ��������ֵ�ľ���˫���ȣ���������Ϊ�����ؾ�������ֵ��
%����Ϊ���ⳤ�ȣ�Ԫ��Ϊdouble����
his=zeros(max(max(segments)),256);%ֱ��ͼ256�飬his�洢ֱ��ͼ��������������ʽ��ʾ
for i=0:max(max(segments))%�������б�ǩ��ͬ�ĳ����ص����ڵ�λ�ü�����������һ����������
    j=1;
    for x=1:p
        for y=1:q
            if segments(x,y)==i   %�ѳ����ص���i�������ҵ����Ӧ������RGB��ֵ
                RGB1(i+1,j)=RGB(x,y);%��ѹ����ı�ǩRGB��ֵ�ŵ�RGB1����ĵ�i+1��
                j=j+1;%ѭ����һ
            end
        end
    end
    his(i+1,:)=hist(RGB1(i+1,1:j-1),256); %��RGB1�ĵ�i+1�е�ǰ1��count-1�������໭ֱ��ͼ��
    %ά����hist_num
end

%%
%%step3
%����ÿ�������ص�ȫ�ֶԱȶ�
diff=0;
for k=1:max(max(segments))+1
   for m=1:max(max(segments))+1
        diff=2*sum((his(k,:)-his(m,:)).^2./(his(k,:)+his(m,:)+eps))+diff;
   end    % ����(hk,h1)+(hk,h2)+(hk,h3)+...+(hk,hn)
   distance(k,1)=(diff/double(max(max(segments))));    %hk����������ƽ��ֵ
   diff=0;
end
for m=1:size(distance)%������0-255֮���ֵ
    pixel(m)=(distance(m)-min(distance))/(max(distance)-min(distance))*255;
end
% num_sup=max(max(segments));
%feature=zeros(1,num_sup+1,'double');
%for i=0:num_sup
%       for y=1:num_sup+1
%            if his(i+1,x)+his(y,x)~=0
 %               feature(1,i+1)=feature(1,i+1)+2*(his(i+1,x)-his(y,x))*(his(i+1,x)-his(y,x))/(his(i+1,x)+his(y,x));
%            end
%        end
%  end
%%
%step4
%��������ȫ�ֶԱȶ��ƹ㵽���ضԱȶ�,fea_p���ƹ���ͼ��,�����ʵ��ĻҶȷ�Χ��ʾ
%��ȫ�ֵĴ���ֲ���
fea_p=zeros(m,n);
for x=1:m
    for y=1:n
        label=segments(m,n)+1;
        fea_p(m,n)=fix(pixel(label));
    end
end
im_last=uint8(fea_p); 
subplot(224),imshow(im_last),title('ȫ�ֶԱȺ��ͼ��');
%step5
%center prior������֪ʶ��ǿ�Աȶ�
sigmaD = 110;

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
im_out=uint8((im_out/146)*255);
 figure,imshow(im_out);
  

