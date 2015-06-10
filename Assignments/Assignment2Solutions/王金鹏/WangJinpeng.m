clear;
clc;

%%  step 1 ����ͼƬ��ת��Ϊ�Ҷ�ͼ

obj_name = 'object.jpg';
sce_name = 'scene.jpg';
ori_obj_img = imread(obj_name);
ori_sce_img = imread(sce_name);
gray_obj_img = rgb2gray(ori_obj_img);
gray_sce_img = rgb2gray(ori_sce_img);

figure, imshow(gray_obj_img);
title('gray object image');
figure, imshow(gray_sce_img);
title('gray scene image');


%% ��ȡ�ؼ��㲢��ʾ

% obj_keyp = detectHarrisFeatures(gray_obj_img);
% sce_keyp = detectHarrisFeatures(gray_sce_img);
obj_keyp = detectSURFFeatures(gray_obj_img);
sce_keyp = detectSURFFeatures(gray_sce_img);
% [obj_keyp, obj_desc] = vl_sift(single(gray_obj_img));
% [sce_keyp, sce_desc] = vl_sift(single(gray_sce_img));
% obj_keyp = detectFASTFeatures(gray_obj_img);
% sce_keyp = detectFASTFeatures(gray_sce_img);

figure, imshow(gray_obj_img);
title('keypoints of object image');
hold on;
plot(selectStrongest(obj_keyp, 60));

figure, imshow(gray_sce_img);
title('keypoints of scene image');
hold on;
plot(selectStrongest(sce_keyp, 200));


%% ��ȡdescriptors��ƥ�䡢��ʾ

%��ȡdescriptors
obj_desc = extractFeatures(gray_obj_img, obj_keyp);
sce_desc = extractFeatures(gray_sce_img, sce_keyp);

%ƥ��descriptors
% match_keyp  = vl_ubcmatch(obj_desc, sce_desc);
match_keyp = matchFeatures(obj_desc, sce_desc); 

obj_match_keyp = obj_keyp(match_keyp(:, 1), :);
sce_match_keyp = sce_keyp(match_keyp(:, 2), :);

figure;
showMatchedFeatures(gray_obj_img, gray_sce_img, obj_match_keyp, sce_match_keyp, 'montage');
title('image of matched keypoints');

%% ӳ��任

[trans_mat, obj_inlier_keyp, sce_inlier_keyp] = estimateGeometricTransform(...
                         obj_match_keyp, sce_match_keyp, 'projective');

figure;
% vl_plotsiftdescriptor(obj_inlier_keyp, sce_inlier_keyp);
showMatchedFeatures(gray_obj_img, gray_sce_img, obj_inlier_keyp, sce_inlier_keyp, 'montage');
title('matched points (after projective)');


%% �ڳ���ͼ�п��Ŀ����

obj_frame = [1, 1;size(gray_obj_img, 2), 1; size(gray_obj_img, 2),...
                    size(gray_obj_img, 1); 1, size(gray_obj_img, 1); 1, 1]; %ȷ����ܳߴ�

circle_obj = transformPointsForward(trans_mat, obj_frame); %���Ŀ����

figure, imshow(gray_sce_img);
hold on;
line(circle_obj(:, 1), circle_obj(:, 2), 'Color', 'y');
title('detected object');

