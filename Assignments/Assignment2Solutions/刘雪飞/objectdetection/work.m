clc;
clf;
clear all;
%%%%%%%%%%%%%����ͼ��ת���ɻҶ�ͼ
image=imread('scene.png');
image_detect=imread('object.png');

[matchLoc1 matchLoc2] = siftMatch(image, image_detect);
% % use RANSAC to find homography matrix
[H corrPtIdx] = findHomography(matchLoc2',matchLoc1');

%%%%%%%%%%%%%��ͼ�п��Ŀ��
[m,n]=size(image_detect);
tform = maketform('projective',H');
img21 = imtransform(image_detect,tform);
pt = zeros(3,4);
pt(:,1) = H*[1;1;1]; 
pt(:,2) = H*[n;1;1];
pt(:,3) = H*[n;m;1];
pt(:,4) = H*[1;m;1];
x2 = pt(1,:)./pt(3,:);%./��ʾ����Ԫ��֮�������(��һ��)
y2 = pt(2,:)./pt(3,:);
figure;
imshow(image);
hold on
plot([x2(1),x2(2),x2(3),x2(4),x2(1)],[y2(1),y2(2),y2(3),y2(4),y2(1)],...
      'Color',[1,0,0]);
