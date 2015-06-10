clc;
clf;
clear all;
%%%%%%%%%%%%%输入图像并转换成灰度图
image=imread('scene.png');
image_detect=imread('object.png');
imageGRAY=mat2gray(image);
image_detectGRAY=mat2gray(image_detect);
subplot(1,2,1)
imshow(imageGRAY);title('原图灰度图');
subplot(1,2,2)
imshow(image_detectGRAY);title('检测图灰度图');

%%%%%%%%%%%%%提取keypoints和descriptors
imageGRAY_s=single(imageGRAY);
image_detectGRAY_s=single(image_detectGRAY);
[feature_image,descriptor_image] = vl_sift(imageGRAY_s) ;
[feature_detect,descriptor_detect] = vl_sift(image_detectGRAY_s) ;

%%%%%%%%%%%%%显示特征点
%原图的特征点
figure;
imshow(image);
hold on;
perm = randperm(size(feature_image,2)) ;    
h1 = vl_plotframe(feature_image(:,perm)) ;  
set(h1,'color','y','linewidth',2) ;  
title('原图的特征点');
%检测图的特征点
figure;
imshow(image_detect);
hold on;
perm = randperm(size(feature_detect,2)) ;    
h2 = vl_plotframe(feature_detect(:,perm)) ;  
set(h2,'color','y','linewidth',2) ;  
title('检测图的特征点')

%%%%%%%%%%%%%SIFT匹配
[matches, scores] = vl_ubcmatch(descriptor_image,descriptor_detect) ;%对上述提取的特征点进行匹配
num_matches = size(matches,2) ;
% X1 = feature_image(1:2,matches(1,:)) ; X1(3,:) = 1 ;
% X2 = feature_detect(1:2,matches(2,:)) ; X2(3,:) = 1 ;

%%%%%%%%%%%%%显示匹配结果                          
dh1 = max(size(image_detectGRAY_s,1)-size(imageGRAY_s,1),0) ;
dh2 = max(size(imageGRAY_s,1)-size(image_detectGRAY_s,1),0) ;
figure;
% imshow(image_detectGRAY);clf;
imshow(imageGRAY);clf;
imagesc([padarray(imageGRAY_s,dh1,'post') padarray(image_detectGRAY_s,dh2,'post')]) ;
o = size(imageGRAY_s,2) ;
line([feature_image(1,matches(1,:));feature_detect(1,matches(2,:))+o], ...
     [feature_image(2,matches(1,:));feature_detect(2,matches(2,:))]) ;
axis image off ;
drawnow ;

%%%%%%%%%%%%%求H矩阵
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
      'Color',[1,0,0],'linewidth',3);
 