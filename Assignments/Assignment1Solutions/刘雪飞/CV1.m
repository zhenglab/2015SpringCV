%读取原图像并显示
I=imread('C:\Users\Administrator\Desktop\cv1.png');
figure,subplot(221),imshow(I),title('原始图像');
[m,n]=size('I');%图像的大小
%%
%step 1-1 extract image information
  B = double(I(:,:,3));%拆分成三通道
  G = double(I(:,:,2));
  R = double(I(:,:,1));
  R = R/16;%每个通道压缩16倍或者采用for循环将每个像素的值量化到1-15
  G = G/16;
  B = B/16;
 H(:,:,3)=B;
 H(:,:,2)=G;
 H(:,:,1)=R;
 %figure,imshow(H)            %H为三颜色变换后的彩色图像
  RGB=B*16*16+G*16+R;        %RGB为颜色单值表示后的一维矩阵
subplot(222),imshow(imdivide(RGB,max(max(RGB))));%4096
  %imshow(image);
  %figure,imshow(I); 
  %%
  %step 1-2 segment the input image into superpixels
  % im contains the input RGB image as a SINGLE array
regionSize = 30;%每块超像素的大小
regularizer = 1;%调整的尺寸
imlab = vl_xyz2lab(vl_rgb2xyz(I)) ;%% IM contains the image in RGB format as before转化到xyz\lab空间
i=single(imlab);
segments = vl_slic(i, regionSize, regularizer) ;%利用lsic工具箱得到超像素矩阵
%figure,imshow(segments);
%[sm,sn]=vl_grad(double(segments), 'type', 'forward');%求梯度 
%s=find(sm|sn);%梯度的索引做成向量
%image=i;
%imag([s s+numel(I(:,:,1)) s+2*numel(I(:,:,1))]) = 0 ;
%,imshow(image),title('超像素分割后的图像');
subplot(223),imshow(segments*(4294967296/140));%梯度最小
%%
 %step 2-1 compute features of each superpixel
 [p,q]=size(segments);
RGB1=zeros(max(max(segments)),[],'double');  %创建存储每个超像素值的矩阵，双精度，其中行数为超像素矩阵的最大值，
%列数为任意长度，元素为double类型
his=zeros(max(max(segments)),256);%直方图256块，his存储直方图并以行向量的形式表示
for i=0:max(max(segments))%查找所有标签相同的超像素点所在的位置及特征，放在一个矩阵里面
    j=1;
    for x=1:p
        for y=1:q
            if segments(x,y)==i   %把超像素等于i的坐标找到其对应坐标下RGB的值
                RGB1(i+1,j)=RGB(x,y);%把压缩后的标签RGB的值放到RGB1矩阵的第i+1行
                j=j+1;%循环加一
            end
        end
    end
    his(i+1,:)=hist(RGB1(i+1,1:j-1),256); %将RGB1的第i+1行的前1到count-1个数归类画直方图，
    %维度是hist_num
end

%%
%%step3
%计算每个超像素的全局对比度
diff=0;
for k=1:max(max(segments))+1
   for m=1:max(max(segments))+1
        diff=2*sum((his(k,:)-his(m,:)).^2./(his(k,:)+his(m,:)+eps))+diff;
   end    % 计算(hk,h1)+(hk,h2)+(hk,h3)+...+(hk,hn)
   distance(k,1)=(diff/double(max(max(segments))));    %hk到整体距离的平均值
   diff=0;
end
for m=1:size(distance)%量化到0-255之间的值
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
%将超像素全局对比度推广到像素对比度,fea_p是推广后的图像,并以适当的灰度范围显示
%即全局的代替局部的
fea_p=zeros(m,n);
for x=1:m
    for y=1:n
        label=segments(m,n)+1;
        fea_p(m,n)=fix(pixel(label));
    end
end
im_last=uint8(fea_p); 
subplot(224),imshow(im_last),title('全局对比后的图像');
%step5
%center prior用先验知识增强对比度
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
  

