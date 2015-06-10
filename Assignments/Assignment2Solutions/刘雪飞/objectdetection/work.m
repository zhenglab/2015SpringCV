clc;
clf;
clear all;
%%%%%%%%%%%%%输入图像并转换成灰度图
image=imread('scene.png');
image_detect=imread('object.png');

[matchLoc1 matchLoc2] = siftMatch(image, image_detect);
% % use RANSAC to find homography matrix
[H corrPtIdx] = findHomography(matchLoc2',matchLoc1');

%%%%%%%%%%%%%从图中框出目标
[m,n]=size(image_detect);
tform = maketform('projective',H');
img21 = imtransform(image_detect,tform);
pt = zeros(3,4);
pt(:,1) = H*[1;1;1]; 
pt(:,2) = H*[n;1;1];
pt(:,3) = H*[n;m;1];
pt(:,4) = H*[1;m;1];
x2 = pt(1,:)./pt(3,:);%./表示矩阵元素之间的运算(归一化)
y2 = pt(2,:)./pt(3,:);
figure;
imshow(image);
hold on
plot([x2(1),x2(2),x2(3),x2(4),x2(1)],[y2(1),y2(2),y2(3),y2(4),y2(1)],...
      'Color',[1,0,0]);
