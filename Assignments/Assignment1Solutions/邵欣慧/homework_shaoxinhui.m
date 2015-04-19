%变量说明：
%image 原图；  r g b:原图的三通道；   M,N,O原图的行、列、维数；   rr,gg,bb量化
%后的三通道；  image_segments分割后的图；   segments_marix存放分块后的对应原图像素 
%distance_hist:距离直方图；   image_saliency：显著性分割图   VSMap：加priors后的图


clear;
clc;
clf;
%%%读入图像
image_name='1.jpg';
image = imread(image_name );   %300*400*3大小
r = image(:,:,1);
g = image(:,:,2);
b = image(:,:,3);
%%%%%%%%%%画出三个通道图以及直方图
hold on;
subplot(4,2,1)
imshow(image);
title('原图');
subplot(4,2,3)
imshow(r);   %显示第一个分量图
title('R');
subplot(4,2,4)
imhist(r);
title('(b)R分量直方图','FontSize',8,'FontName','隶书','color','b');
subplot(4,2,5)
imshow(g);   %显示第二个分量图
title('G');
subplot(4,2,6)
imhist(g);
title('(b)G分量直方图','FontSize',8,'FontName','隶书','color','b');
subplot(4,2,7)
imshow(b);   %显示第三个分量图
title('B');
subplot(4,2,8)
imhist(b);
title('(b)B分量直方图','FontSize',8,'FontName','隶书','color','b');
%%%%%%%%%%%%%%%%%%%%%

[M,N,O] = size(image);  %存储图像的行、列、维数
%r,g,b分别量化成16等级
double rr=zeros(M,N);
double gg=zeros(M,N);
double bb=zeros(M,N);
%R通道量化
for i=1:M
    for j=1:N
         if r(i,j)>=0&&r(i,j)<=15
             rr(i,j)=0;
         end
         if r(i,j)>=16&&r(i,j)<=31
             rr(i,j)=1;
         end
         if r(i,j)>=32&&r(i,j)<=47
             rr(i,j)=2;
         end
         if r(i,j)>=48&&r(i,j)<=63
             rr(i,j)=3;
         end    
         if r(i,j)>=64&&r(i,j)<=79
             rr(i,j)=4;
         end     
         if r(i,j)>=80&&r(i,j)<=95
             rr(i,j)=5;
         end      
         if r(i,j)>=96&&r(i,j)<=111
             rr(i,j)=6;
         end     
         if r(i,j)>=112&&r(i,j)<=127
             rr(i,j)=7;
         end      
         if r(i,j)>=128&&r(i,j)<=143
             rr(i,j)=8;
         end       
         if r(i,j)>=144&&r(i,j)<=159
             rr(i,j)=9;
         end      
         if r(i,j)>=160&&r(i,j)<=175
             rr(i,j)=10;
         end      
         if r(i,j)>=176&&r(i,j)<=191
             rr(i,j)=11;
         end      
         if r(i,j)>=192&&r(i,j)<=207
             rr(i,j)=12;
         end      
         if r(i,j)>=208&&r(i,j)<=223
             rr(i,j)=13;
         end      
         if r(i,j)>=224&&r(i,j)<=239
             rr(i,j)=14;
         end     
         if r(i,j)>=240&&r(i,j)<=255
             rr(i,j)=15;
         end   
       end
    end
%G通道量化    
for i=1:M
    for j=1:N
         if g(i,j)>=0&&g(i,j)<=15
             gg(i,j)=0;
         end     
         if g(i,j)>=16&&g(i,j)<=31
             gg(i,j)=1;
         end      
         if g(i,j)>=32&&g(i,j)<=47
             gg(i,j)=2;
         end      
         if g(i,j)>=48&&g(i,j)<=63
             gg(i,j)=3;
         end      
         if g(i,j)>=64&&g(i,j)<=79
             gg(i,j)=4;
         end      
         if g(i,j)>=80&&g(i,j)<=95
             gg(i,j)=5;
         end      
         if g(i,j)>=96&&g(i,j)<=111
             gg(i,j)=6;
         end      
         if g(i,j)>=112&&g(i,j)<=127
             gg(i,j)=7;
         end      
         if g(i,j)>=128&&g(i,j)<=143
             gg(i,j)=8;
         end      
         if r(i,j)>=144&&r(i,j)<=159
             gg(i,j)=9;
         end      
         if g(i,j)>=160&&g(i,j)<=175
             gg(i,j)=10;
         end      
         if g(i,j)>=176&&g(i,j)<=191
             gg(i,j)=11;
         end      
         if g(i,j)>=192&&g(i,j)<=207
             gg(i,j)=12;
         end      
         if g(i,j)>=208&&g(i,j)<=223
             gg(i,j)=13;
         end      
         if g(i,j)>=224&&g(i,j)<=239
             gg(i,j)=14;
         end      
         if g(i,j)>=240&&g(i,j)<=255
             gg(i,j)=15;
          end     
       end
end
%B通道量化
for i=1:M
    for j=1:N
         if b(i,j)>=0&&b(i,j)<=15
             bb(i,j)=0;
         end      
         if b(i,j)>=16&&b(i,j)<=31
             bb(i,j)=1;
         end      
         if b(i,j)>=32&&b(i,j)<=47
             bb(i,j)=2;
         end      
         if b(i,j)>=48&&b(i,j)<=63
             bb(i,j)=3;
         end      
         if b(i,j)>=64&&b(i,j)<=79
             bb(i,j)=4;
         end      
         if b(i,j)>=80&&b(i,j)<=95
             bb(i,j)=5;
         end      
         if b(i,j)>=96&&b(i,j)<=111
             bb(i,j)=6;
         end      
         if b(i,j)>=112&&b(i,j)<=127
             bb(i,j)=7;
         end      
         if b(i,j)>=128&&b(i,j)<=143
             bb(i,j)=8;
         end      
         if b(i,j)>=144&&b(i,j)<=159
             bb(i,j)=9;
         end      
         if b(i,j)>=160&&b(i,j)<=175
             bb(i,j)=10;
         end     
         if b(i,j)>=176&&b(i,j)<=191
             bb(i,j)=11;
         end      
         if b(i,j)>=192&&b(i,j)<=207
             bb(i,j)=12;
         end     
         if b(i,j)>=208&&b(i,j)<=223
             bb(i,j)=13;
         end     
         if b(i,j)>=224&&b(i,j)<=239
             bb(i,j)=14;
         end     
         if b(i,j)>=240&&b(i,j)<=255
             bb(i,j)=15;
         end      
       end
end
%%%%%%%%%%显示量化后的图
figure;
title('量化后的图');
subplot(2,2,1)
imshow(image);
title('原图');
subplot(2,2,2)
imshow(rr);   %显示第一个分量图
title('R');
subplot(2,2,3)
imshow(gg);   %显示第二个分量图
title('G');
subplot(2,2,4)
imshow(bb);   %显示第三个分量图
title('B');
%%%%%%%%%%%%%%%%%%%%%
%将三个通道的矩阵存放在一个大矩阵中
image_combine=rr*16*16+gg*16+bb;   
%超像素分割
imlab = vl_xyz2lab(vl_rgb2xyz(image)) ;
I_single = single(imlab);
segments = vl_slic(I_single,50, 0.1) ;         
[sx,sy]=vl_grad(double(segments), 'type', 'forward') ;  
 s = find(sx | sy) ;  
 image_segments = image ;  
 image_segments([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))]) = 0 ;  
 %画出分割图
 figure;
 title('分割结果');
 imshow(image_segments);

%把每一个sengments都找出来，对应的image_combine的像素分别存储到一个矩阵中
max_segments=max(max(segments));  %分块标号最大值
  for i=1:M
     for j=1:N
         for k=1:(max_segments+1)
              if segments(i,j)==k-1
                 eval(['image_combine_hist',num2str(k-1),'(j)=','image_combine(i,j)',';']);
              end
         end
     end
  end
  % 直方图距离
  segments_marix=cell(max_segments+1,1);
  for k=1:(max_segments+1)
       segments_marix{k,1}=hist(eval(['image_combine_hist',num2str(k-1)]),128);
  end 
 distance_hist=zeros(1,max_segments+1);
 for i=1:(max_segments+1)
     for j=1:(max_segments+1)
      distance_hist(i) = 2 * sum( (segments_marix{i,1} - segments_marix{j,1}).^2 ./ (segments_marix{i,1} + segments_marix{j,1} + eps) );     
     end
 end 
%直方图量化
  distance_hist_quantity=zeros(1,max_segments+1);
 for i=1:(max_segments+1)
     distance_hist_quantity(i)=(distance_hist(i)-min(distance_hist))/(max(distance_hist)-min(distance_hist))*255;
 end
 %把量化后的直方图距离赋给对应的图片位置作为像素值
 image_saliency=zeros(M,N);
 for i=1:M
      for j=1:N
            image_saliency(i,j)=distance_hist_quantity(segments(i,j)+1);
      end
 end
figure;
 imshow(uint8(image_saliency));
%use priors to enhance the result
sigmaD = 400;
[rows, cols, junk] = size(image);
coordinateMtx = zeros(rows, cols, 2);
coordinateMtx(:,:,1) = repmat((1:1:rows)', 1, cols);
coordinateMtx(:,:,2) = repmat(1:1:cols, rows, 1);

centerY = rows / 2;
centerX = cols / 2;
centerMtx(:,:,1) = ones(rows, cols) * centerY;
centerMtx(:,:,2) = ones(rows, cols) * centerX;
SDMap = exp(-sum((coordinateMtx - centerMtx).^2,3) / sigmaD^2);
VSMap = image_saliency.* SDMap;
figure;
imshow(uint8(VSMap))
  
  
  
  
  
  
  
 


 
 
 
 
         
         
             
     
 
 
  
         