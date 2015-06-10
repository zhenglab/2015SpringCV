clc
clear
%% step1-2������ͼ��,��ת��Ϊ�Ҷ�ͼ

%�������Ȥ��Ŀ��ͼ��,������ת��Ϊ�Ҷ�ͼ
object = imread('object.jpg');%�������Ȥ��Ŀ��ͼ��
object=rgb2gray(object);    %����ɫ�ռ���rgbת��Ϊgray
figure;
imshow(object);                    %��ʾ��ͼ�񣬱���ΪImage of a Book
title('Image of a Book');

%�������Ŀ��ͼ��ĳ�����������ת��Ϊ�Ҷ�ͼ
sceneImage = imread('scene.jpg');        %�������Ŀ��ͼ��ĳ���ͼ
sceneImage=rgb2gray(sceneImage);
figure;
imshow(sceneImage);                      %��ʾ��ͼ�񣬱���ΪImage of a Cluttered Scene
title('Image of a Cluttered Scene');
%% step3:��������

%��surf�㷨�ڂz��ͼƬ�зֱ���������
objectPoints = detectSURFFeatures(object);
scenePoints = detectSURFFeatures(sceneImage);
%��ʾ��Ŀ��ͼ����150�������Ե�������
figure;
imshow(object);
title('150 Strongest Feature Points from Object Image');
hold on;
plot(selectStrongest(objectPoints, 150));
%��ʾ������Ŀ��ĳ���ͼ��350�������Ե�������
figure;
imshow(sceneImage);
title('350 Strongest Feature Points from Scene Image');
hold on;
plot(selectStrongest(scenePoints, 350));
%% step4����ȡ����������

%��ȡ����������
[objectFeatures, objectPoints] = extractFeatures(object, objectPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);
%% step5:��������ƥ�������� 
%ƥ��������
objectPairs = matchFeatures(objectFeatures, sceneFeatures);

%��ʾƥ����������Ӧƥ����������
matchedObjectPoints = objectPoints(objectPairs(:, 1), :);
matchedScenePoints = scenePoints(objectPairs(:, 2), :);
figure;
showMatchedFeatures(object, sceneImage, matchedObjectPoints, ...
    matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');
%% step6:���α任


%����任����ƥ��������㣬�������쳣ֵ
[tform, inlierObjectPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedObjectPoints, matchedScenePoints, 'affine');

%��ʾ������쳣ֵ���ƥ����
figure;
showMatchedFeatures(object, sceneImage, inlierObjectPoints, ...
    inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');
%% step7:��ⳡ��ͼ�е�Ŀ��

%��ȡĿ��ͼ�����Ӷ����

objectPolygon = [1, 1;...                           % top-left
        size(object, 2), 1;...                 % top-right
        size(object, 2), size(object, 1);... % bottom-right
        1, size(object, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon
    
%�ڳ����ж�λĿ���λ��
    
    newObjectPolygon = transformPointsForward(tform, objectPolygon);
    
%�������ͼ�е�Ŀ���λ��
figure;
imshow(sceneImage);
hold on;
line(newObjectPolygon(:, 1), newObjectPolygon(:, 2), 'Color', 'y');
title('Detected Object');
