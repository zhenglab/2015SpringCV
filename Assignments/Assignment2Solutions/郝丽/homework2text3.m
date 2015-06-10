clear
clc
%%颜色空间转换，显示图像
image1_object = imread('object1.png');
image1_object=rgb2gray(image1_object);
figure,imshow(image1_object);
title('Image of a object');%显示目标图像

image2_scene = imread('scene1.png');
image2_scene=rgb2gray(image2_scene);
figure,imshow(image2_scene);
title('Image of a Scene');%显示场景图像

%%检测特征点
poin_object = detectSURFFeatures(image1_object);
poin_scene = detectSURFFeatures(image2_scene);

%%显示在目标图片中的150个强特征点
figure,imshow(image1_object);
title('150 Strongest Feature Points from image1_flower ');
hold on;
plot(selectStrongest(poin_object, 150));

%%显示在场景图片中的200个强特征点
figure,imshow(image2_scene);
title('200 Strongest Feature Points from Scene Image');
hold on;
plot(selectStrongest(poin_scene, 200));

%%计算特征点
[fea_object, poin_object] = extractFeatures(image1_object, poin_object);
[fea_scene, poin_scene] = extractFeatures(image2_scene, poin_scene);

%%用描述符配对特征点
objectPairs = matchFeatures(fea_object, fea_scene);

%%显示指定特征点配对
matchedobjectPoints = poin_object(objectPairs(:, 1), :);
matchedScenePoints = poin_scene(objectPairs(:, 2), :);
figure,
showMatchedFeatures(image1_object, image2_scene, matchedobjectPoints, ...
    matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');

%%定位目标物在场景中的位置
%筛选匹配点
[tform, inlierObjectPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedobjectPoints, matchedScenePoints, 'affine');
figure,showMatchedFeatures(image1_object, image2_scene, inlierObjectPoints, ...
    inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');
%得到示例图像的闭合多边形
objectPolygon = [1, 1;...                           % top-left
        size(image1_object, 2), 1;...                 % top-right
        size(image1_object, 2), size(image1_object, 1);... % bottom-right
        1, size(image1_object, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon
%把多边形转移到目标图像中，定位
newobjectPolygon = transformPointsForward(tform, objectPolygon);
%显示检测出的目标
figure,imshow(image2_scene);
hold on;
line(newobjectPolygon(:, 1), newobjectPolygon(:, 2), 'Color', 'y');
title('Detected object');



