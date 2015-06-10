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
%step3 ���������
objectPoints = detectSURFFeatures(object);
scenePoints = detectSURFFeatures(scene);

figure;
imshow(object);
title('Feature Points from object');
hold on;
plot(selectStrongest(objectPoints, 100));%��ʾ��ͼƬ�е�100��ǿ������

figure;
imshow(scene);
title('Feature Points from Scene');
hold on;
plot(selectStrongest(scenePoints, 300));%%��ʾ��ͼƬ�е�300��ǿ������
%%
%step4 ����������
[objectFeatures,objectPoints] = extractFeatures(object, objectPoints);
[sceneFeatures, scenePoints] = extractFeatures(scene, scenePoints);
%%
%step5 �����������������
objectPairs = matchFeatures(objectFeatures, sceneFeatures);
matchedobjectPoints = objectPoints(objectPairs(:, 1), :);
matchedScenePoints = scenePoints(objectPairs(:, 2), :);
figure;
showMatchedFeatures(object, scene, matchedobjectPoints, ...
    matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');%��ʾ�������������
%%
%step6 ����任
[tform, inlierobjectPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedobjectPoints, matchedScenePoints, 'affine');

%��ʾɸѡ���ƥ���
figure;
showMatchedFeatures(object, scene, inlierobjectPoints, ...
    inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');
%%
%step7 �õ�Ŀ��ı߽�
objectPolygon = [1, 1;...                           % top-left
        size(object, 2), 1;...                 % top-right
        size(object, 2), size(object, 1);... % bottom-right
        1, size(object, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon

%�ڳ����ж�λĿ��
newobjectPolygon = transformPointsForward(tform, objectPolygon);

%��ʾ�����
figure;
imshow(scene);
hold on;
line(newobjectPolygon(:, 1), newobjectPolygon(:, 2), 'Color', 'y');
title('Detected object');