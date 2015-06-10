clear
clc
%%��ɫ�ռ�ת������ʾͼ��
image1_object = imread('object1.png');
image1_object=rgb2gray(image1_object);
figure,imshow(image1_object);
title('Image of a object');%��ʾĿ��ͼ��

image2_scene = imread('scene1.png');
image2_scene=rgb2gray(image2_scene);
figure,imshow(image2_scene);
title('Image of a Scene');%��ʾ����ͼ��

%%���������
poin_object = detectSURFFeatures(image1_object);
poin_scene = detectSURFFeatures(image2_scene);

%%��ʾ��Ŀ��ͼƬ�е�150��ǿ������
figure,imshow(image1_object);
title('150 Strongest Feature Points from image1_flower ');
hold on;
plot(selectStrongest(poin_object, 150));

%%��ʾ�ڳ���ͼƬ�е�200��ǿ������
figure,imshow(image2_scene);
title('200 Strongest Feature Points from Scene Image');
hold on;
plot(selectStrongest(poin_scene, 200));

%%����������
[fea_object, poin_object] = extractFeatures(image1_object, poin_object);
[fea_scene, poin_scene] = extractFeatures(image2_scene, poin_scene);

%%�����������������
objectPairs = matchFeatures(fea_object, fea_scene);

%%��ʾָ�����������
matchedobjectPoints = poin_object(objectPairs(:, 1), :);
matchedScenePoints = poin_scene(objectPairs(:, 2), :);
figure,
showMatchedFeatures(image1_object, image2_scene, matchedobjectPoints, ...
    matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');

%%��λĿ�����ڳ����е�λ��
%ɸѡƥ���
[tform, inlierObjectPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedobjectPoints, matchedScenePoints, 'affine');
figure,showMatchedFeatures(image1_object, image2_scene, inlierObjectPoints, ...
    inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');
%�õ�ʾ��ͼ��ıպ϶����
objectPolygon = [1, 1;...                           % top-left
        size(image1_object, 2), 1;...                 % top-right
        size(image1_object, 2), size(image1_object, 1);... % bottom-right
        1, size(image1_object, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon
%�Ѷ����ת�Ƶ�Ŀ��ͼ���У���λ
newobjectPolygon = transformPointsForward(tform, objectPolygon);
%��ʾ������Ŀ��
figure,imshow(image2_scene);
hold on;
line(newobjectPolygon(:, 1), newobjectPolygon(:, 2), 'Color', 'y');
title('Detected object');



