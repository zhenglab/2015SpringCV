%Object Detection
%��������object��scene�ֱ������Ŀ��ͼ��ͳ���ͼ��
%������
function num = match(image1,image2)
tic;
clear;
clc;
tic
%%%%%%%����ͼ������sift��ȡkeypoints
object='object.png';
scene='scene.png';
[im1,des1,loc1]=sift('object.png');
toc
[im2,des2,loc2]=sift('scene.png');
 save('im1.mat','im1');
 save('im2.mat','im2');
 
 %%��ʾ������������
 showkeys(object, loc1); 
 showkeys(scene,loc2);
 
 %%%Ѱ��ƥ���������
 %��������������Ĳ���
 distRatio=0.5;
 %���objectͼ���е�ÿһ�������ӵ㣬��sceneͼ����Ѱ����֮��ƥ��ĵ�
 des2t = des2';                          % Ԥ�ȼ�������ת��
 for i=1:size(des1,1)
   dotprods=des1(i,:)*des2t;        % ����������
   [vals,indx]=sort(acos(dotprods));  
   if (vals(1)<distRatio*vals(2))
      match(i)=indx(1);
   else
      match(i)=0;
   end
end

% ��object��scene�ϲ���һ��ͼ��������ʾ���յļ����
% ��С��ͼ�������0Ԫ������䣬ʹ֮��ϴ��ͼ��ӵ��һ����ͼ���С
rows1 = size(im1,1);
rows2 = size(im2,1);
if (rows1<rows2)
     im1(rows2,1)=0;
else
     im2(rows1,1)=0;
end
im3=[im1 im2];

%����������ƥ��ĵ�������������
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
%�������������þ��ο��
%����A�����洢scene�м�����ƥ���
%����B�����洢object�м�����ƥ���
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


%%��Ҫ���Ӻ���
%sift����
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

%%%showkeys����
function showkeys(image, locs)
image=imread(image);
disp('Drawing SIFT keypoints ...');
% ��ͼ
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












