clc
clear
%% step1-2：读入图像,并转换为灰度图

%读入感兴趣的目标图像,并将其转化为灰度图
object = imread('object.jpg');%读入感兴趣的目标图像
object=rgb2gray(object);    %将颜色空间由rgb转换为gray
figure;
imshow(object);                    %显示该图像，标题为Image of a Book
title('Image of a Book');

%读入包含目标图像的场景，并将其转化为灰度图
sceneImage = imread('scene.jpg');        %读入包含目标图像的场景图
sceneImage=rgb2gray(sceneImage);
figure;
imshow(sceneImage);                      %显示该图像，标题为Image of a Cluttered Scene
title('Image of a Cluttered Scene');
%% step3:特征点检测

%用surf算法在倆幅图片中分别检测特征点
objectPoints = detectSURFFeatures(object);
scenePoints = detectSURFFeatures(sceneImage);
%显示出目标图像中150个最明显的特征点
figure;
imshow(object);
title('150 Strongest Feature Points from Object Image');
hold on;
plot(selectStrongest(objectPoints, 150));
%显示出包含目标的场景图中350个最明显的特征点
figure;
imshow(sceneImage);
title('350 Strongest Feature Points from Scene Image');
hold on;
plot(selectStrongest(scenePoints, 350));
%% step4：提取特征描述子

%提取特征描述子
[objectFeatures, objectPoints] = extractFeatures(object, objectPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);
%% step5:用描述子匹配特征点 
%匹配特征点
objectPairs = matchFeatures(objectFeatures, sceneFeatures);

%显示匹配结果，将对应匹配点进行连线
matchedObjectPoints = objectPoints(objectPairs(:, 1), :);
matchedScenePoints = scenePoints(objectPairs(:, 2), :);
figure;
showMatchedFeatures(object, sceneImage, matchedObjectPoints, ...
    matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');
%% step6:几何变换


%仿射变换估计匹配的特征点，来消除异常值
[tform, inlierObjectPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedObjectPoints, matchedScenePoints, 'affine');

%显示出清除异常值后的匹配结果
figure;
showMatchedFeatures(object, sceneImage, inlierObjectPoints, ...
    inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');
%% step7:检测场景图中的目标

%获取目标图像的外接多边形

objectPolygon = [1, 1;...                           % top-left
        size(object, 2), 1;...                 % top-right
        size(object, 2), size(object, 1);... % bottom-right
        1, size(object, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon
    
%在场景中定位目标的位置
    
    newObjectPolygon = transformPointsForward(tform, objectPolygon);
    
%标出场景图中的目标的位置
figure;
imshow(sceneImage);
hold on;
line(newObjectPolygon(:, 1), newObjectPolygon(:, 2), 'Color', 'y');
title('Detected Object');
