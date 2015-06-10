% num = match(image1, image2)
%
% This function reads two images, finds their SIFT features, and
%   displays lines connecting the matched keypoints.  A match is accepted
%   only if its distance is less than distRatio times the distance to the
%   second closest match.
% It returns the number of matches displayed.
%
% Example: match('scene.pgm','book.pgm');

function num = match(image1,image2)
tic;
% Find SIFT keypoints for each image
% a=imread('ren.jpg');
% s1=rgb2gray(a);
% b=imread('ref.jpg');
% s2=rgb2gray(b);
tic
%%sift�������Ŀ��ͼ��ͳ���ͼ��
[im1 des1 loc1] = sift('object2.png');%loc1����λ����Ϣ���ݶ���Ϣ  K*4�ľ���������des1��K*128�ľ���
toc
%0076,1
[im2 des2 loc2] = sift('scene1.png');
%[im2 des2 loc2] = sift('youtu2.png');
 save('im1.mat','im1');
 save('im2.mat','im2');
 disp('Drawing SIFT keypoints ...');

%%��ʾ������,����λ����Ϣ�Լ���С�ͷ�����Ϣ���ݶȣ�
showkeys(im1, loc1);
%showkeys(im2, loc2);
%%%%%%��ͼ���н�keypoints��ǳ�������ʾ
 n1=size(loc1,1);
 n2=size(loc2,1);
 figure,imshow(im2);
 hold on;
 for i=1:n2
      plot(loc2(i,1,:,:),loc2(i,2,:,:),'ro');%����һ����ɫ��ԲȦ
 end 
 hold off;

 


% For efficiency in Matlab, it is cheaper to compute dot products between
%  unit vectors rather than Euclidean distances.  Note that the ratio of 
%  angles (acos of dot products of unit vectors) is a close approximation
%  to the ratio of Euclidean distances for small angles.
%
% distRatio: Only keep matches in which the ratio of vector angles from the
%   nearest to second nearest neighbor is less than distRatio.
distRatio = 0.5;   
%��Ŀ��ͼ���ÿһ�����������ӣ�ѡ�񳡾�ͼ���ƥ���
% For each descriptor in the first image, select its match to second image.
des2t = des2';                          % Precompute matrix transpose
for i = 1 : size(des1,1)
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
   else
      match(i) = 0;
   end
end
%%�����ο�
%figure,imshow('scene1.png');

% Create a new image showing the two images side by side.
im3 = appendimages(im1,im2);


% Show a figure with lines joining the accepted matches.
figure('Position', [100 100 size(im3,2) size(im3,1)]);
colormap('gray');
imagesc(im3);
hold on;
cols1 = size(im1,2);
for i = 1: size(des1,1)
  if (match(i) > 0)
    line([loc1(i,2) loc2(match(i),2)+cols1], ...
         [loc1(i,1) loc2(match(i),1)], 'Color', 'c');
  end
end
rectangle('Position',[420,170,200,100],'edgecolor','blue');
hold off;
%%huakuang
%��ȡĿ��ͼ�����Ӷ����
j=1;
A=zeros(3000,2);B=zeros(3000,2);
A=double(A);B=double(B);
for i=1:size(loc1,1);
   if (match(i) > 0)
       A(j,:)=[loc1(i,1) loc1(i,2)]
       B(j,:)=[loc2(i,1) loc2(i,2)]
       j=j+1;
   end
end
%[H corrPtIdx] = findHomography(A,B);

%rectangle('Position',[420,170,200,100],'edgecolor','blue');



num = sum(match > 0);
fprintf('Found %d matches.\n', num);




