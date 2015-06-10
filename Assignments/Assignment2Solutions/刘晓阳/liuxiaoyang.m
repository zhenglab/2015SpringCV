%%
%step1 input image and step2 color space conversion
object = imread('object.jpg');
object=rgb2gray(object);
figure,imshow(object);
title('object');
scene = imread('scene.jpg');
scene=rgb2gray(scene);
figure,imshow(scene);
title('Scene');
%%
%step3 检测特征点
objectPoints = detectSURFFeatures(object);
scenePoints = detectSURFFeatures(scene);

figure;
imshow(object);
title('Feature Points from object');
hold on;
plot(selectStrongest(objectPoints, 100));%显示在图片中的100个强特征点

figure;
imshow(scene);
title('Feature Points from Scene');
hold on;
plot(selectStrongest(scenePoints, 300));%%显示在图片中的300个强特征点
%%
%step4 计算描述符
[objectFeatures,objectPoints] = extractFeatures(object, objectPoints);
[sceneFeatures, scenePoints] = extractFeatures(scene, scenePoints);
%%
%step5 用描述符配对特征点
objectPairs = matchFeatures(objectFeatures, sceneFeatures);
matchedobjectPoints = objectPoints(objectPairs(:, 1), :);
matchedScenePoints = scenePoints(objectPairs(:, 2), :);
figure;
showMatchedFeatures(object, scene, matchedobjectPoints, ...
    matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');%显示初步特征点配对
%%
%step6 仿射变换
[tform, inlierobjectPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedobjectPoints, matchedScenePoints, 'affine');

%显示筛选后的匹配点
figure;
showMatchedFeatures(object, scene, inlierobjectPoints, ...
    inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');
%%
%step7 得到目标的边界
objectPolygon = [1, 1;...                           % top-left
        size(object, 2), 1;...                 % top-right
        size(object, 2), size(object, 1);... % bottom-right
        1, size(object, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon

%在场景中定位目标
newobjectPolygon = transformPointsForward(tform, objectPolygon);

%显示检测结果
figure;
imshow(scene);
hold on;
line(newobjectPolygon(:, 1), newobjectPolygon(:, 2), 'Color', 'y');
title('Detected object');