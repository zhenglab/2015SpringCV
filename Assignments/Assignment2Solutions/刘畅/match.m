%Object Detection
%变量名：object、scene分别代表检测目标图像和场景图像；
%主函数
function num = match(image1,image2)
tic;
clear;
clc;
tic
%%%%%%%读入图像并运用sift提取keypoints
object='object.png';
scene='scene.png';
[im1,des1,loc1]=sift('object.png');
toc
[im2,des2,loc2]=sift('scene.png');
 save('im1.mat','im1');
 save('im2.mat','im2');
 
 %%显示检测出的特征点
 showkeys(object, loc1); 
 showkeys(scene,loc2);
 
 %%%寻找匹配的特征点
 %定义衡量两点距离的参数
 distRatio=0.5;
 %针对object图像中的每一个描述子点，在scene图像中寻找与之相匹配的点
 des2t = des2';                          % 预先计算矩阵的转置
 for i=1:size(des1,1)
   dotprods=des1(i,:)*des2t;        % 计算点积向量
   [vals,indx]=sort(acos(dotprods));  
   if (vals(1)<distRatio*vals(2))
      match(i)=indx(1);
   else
      match(i)=0;
   end
end

% 将object与scene合并到一张图中用以显示最终的检测结果
% 较小的图像矩阵用0元素来填充，使之与较大的图像拥有一样的图像大小
rows1 = size(im1,1);
rows2 = size(im2,1);
if (rows1<rows2)
     im1(rows2,1)=0;
else
     im2(rows1,1)=0;
end
im3=[im1 im2];

%将检测出的相匹配的点用线连接起来
figure('Position', [100 100 size(im3,2) size(im3,1)]);
colormap('gray');
imagesc(im3);
hold on;
cols1 = size(im1,2);
for i = 1: size(des1,1)
  if (match(i)>0)
    line([loc1(i,2) loc2(match(i),2)+cols1],[loc1(i,1) loc2(match(i),1)], 'Color', 'c');
  end
end
%将检测出的物体用矩形框出
%矩阵A用来存储scene中检测出的匹配点
%矩阵B用来存储object中检测出的匹配点
double A=zero(size(des1,1));
double B=zero(size(des1,1));
j=1;
for i=1:size(des1,1)
  if (match(i)>0)      
       A(j,:,:,:)=loc2(i,:,:,:);
       B(j,:,:,:)=loc1(i,:,:,:);
       j=j+1;
  end
end
rectangle('Position',[420,165,200,120],'EdgeColor','blue','LineWidth',2);
hold off;
num = sum(match > 0);
fprintf('Found %d matches.\n', num);


%%需要的子函数
%sift函数
function [image, descriptors, locs] = sift(image1)
% Load image
image=imread(image1);
a=imread(image1);
image=rgb2gray(a);
[rows, cols] = size(image); 
% Convert into PGM imagefile, readable by "keypoints" executable
f = fopen('tmp.pgm', 'w');
if f == -1
    error('Could not create file tmp.pgm.');
end
fprintf(f, 'P5\n%d\n%d\n255\n', cols, rows);
fwrite(f, image', 'uint8');
fclose(f);
% Call keypoints executable
if isunix
    command = '!./sift ';
else
    command = '!siftWin32 ';
end
command = [command ' <tmp.pgm >tmp.key'];
eval(command);
% Open tmp.key and check its header
g = fopen('tmp.key', 'r');
if g == -1
    error('Could not open file tmp.key.');
end
[header, count] = fscanf(g, '%d %d', [1 2]);
if count ~= 2
    error('Invalid keypoint file beginning.');
end
num = header(1);
len = header(2);
if len ~= 128
    error('Keypoint descriptor length invalid (should be 128).');
end
% Creates the two output matrices (use known size for efficiency)
locs = double(zeros(num, 4));
descriptors = double(zeros(num, 128));
% Parse tmp.key
for i = 1:num
    [vector, count] = fscanf(g, '%f %f %f %f', [1 4]); %row col scale ori
    if count ~= 4
        error('Invalid keypoint file format');
    end
    locs(i, :) = vector(1, :);    
    [descrip, count] = fscanf(g, '%d', [1 len]);
    if (count ~= 128)
        error('Invalid keypoint file value.');
    end
    % Normalize each input vector to unit length
    descrip = descrip / sqrt(sum(descrip.^2));
    descriptors(i, :) = descrip(1, :);
end
fclose(g);

%%%showkeys函数
function showkeys(image, locs)
image=imread(image);
disp('Drawing SIFT keypoints ...');
% 画图
figure('Position', [50 50 size(image,2) size(image,1)]);
colormap('gray');
imagesc(image);
hold on;
imsize = size(image);
for i=1:size(locs,1)
    len=6*locs(i,3);
    s=sin(locs(i,4));
    c=cos(locs(i,4));
    r1=locs(i,1)-len*(c);
    c1=locs(i,2)+len*(-s);
    plot(c1,r1, 'ro');    
end
hold off;












