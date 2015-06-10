function main
clc;
clear;
close all;

%The coner points extractions using Harris methods;
frame=imread('object2.png');
figure(1);
imshow(frame);

%调用harris角点检测子函数;
%输入参数解释：frame为输入图像,7为高斯滤波窗口大小，2为均方差sigma的值，
%0,04为推荐的k值，winsize为极大抑制窗口的大小且给参数时为奇数;
%输出参数解释：posX为检测到角点X坐标，posY为检测到角点Y坐标，
%cnt为检测到角点的个数，Out_Image为输出图像;
[posX,posY,cnt,Out_Image]=conerdetection(frame,7,2,0.04,7);      %输出的图像已经是2值化的
figure(2);
imshow(Out_Image);
hold on;
plot(posX,posY,'ro','MarkerSize',15);
disp(cnt);
end

function [posX,posY,cnt,Out_Image]=conerdetection(frame,GaussWindow,sigma,k,winsize)
%ImageData: gracyscale image of input
%GaussWindow: The sizes of Gauss window
%sigma:The variance
%default value
%winsize为极大抑制窗口大小
Out_Image=frame;
ImageData=frame;
ImageData= double(ImageData(:,:,2));    %ImageData数据矩阵式一个三通道的，我们角点标记只需选择一个可以;
%ImageData=im2bw(ImageData,0.5);        %或者将3通道的的图像转换成2值化的图像，完成提取;

%算法解释：
%1：利用水平，竖直差分算子对图像的每个像素进行滤波以求得Ix,Iy，进而求得M矩阵中四个元素的值;
%M=[Ix*Ix,Ix*Iy;Ix*Iy,Iy*Iy]
orig_image=ImageData;
fx=[-2,-1,0,1,2];
Ix=filter2(fx,orig_image);
fy=[-2;-1;0;1;2];
Iy=filter2(fy,orig_image);
Ix2=Ix.*Ix;
Iy2=Iy.*Iy;
Ixy=Ix.*Iy;

%2:对M的四个元素进行高斯平滑滤波，得到新的矩阵M;
%滤波平滑，消除突出点,得到新的矩阵M;
h=fspecial('gaussian',[GaussWindow,GaussWindow],sigma);     %建立滤波算子
Ix2=filter2(h,Ix2);     %filter2是用h滤波器放在Ix2移动进行模板滤波
Iy2=filter2(h,Iy2);     %消除y方向上的突兀点
Ixy=filter2(h,Ixy);

%提取前的图像矩阵的预处理;
height=size(orig_image,1);       %返回图像矩阵的行数给高
width=size(orig_image,2);        %返回图像矩阵的列数给宽
result=zeros(height,width);      % 纪录角点位置,角点处值为1 
R=zeros(height,width);           %创建与图像矩阵大小相同的零矩阵
Rmax=0;                          % 图像中最大的R值 

%3:接下来利用M计算对应于每个像素的角点响应函数Cim(即R)；
%计算公式为：R=det(M)-k*(trace(M))^2,其中k为一个任意数，经验选取0.04就可以;
%由于k的取值有些太随意，因此，改用此公式，用新的公式定义R：R=det(M)/Tr(M);
%即Cim=R=[Ix*Ix*Iy*Iy-(Ix*Iy)*(Ix*Iy)]/[Ix*Ix+Iy*Iy];
for i=1:height
    for j=1:width
        M=[Ix2(i,j),Ixy(i,j);Ixy(i,j),Iy2(i,j)];        %%自相关矩阵
        R(i,j)=det(M)-0.04*(trace(M))^2;                %% 计算R值,det()求一个方阵的行列式(Determinant);trace()求方阵的迹，即该方阵对角线上元素之和;
        if  R(i,j)>Rmax
            Rmax=R(i,j);
        end
    end
end

%winsize为非极大抑制窗口
winr=(winsize-1)/2;        %the radius of the neighborhood
istart=winr+1;
jstart=winr+1;
iend=height-winr;
jend=width-winr;

cnt=0;
for i=istart:iend
    for j=jstart:jend
        subr=R((i-winr):(i+winr),(j-winr):(j+winr));        %取出winr*winr这块区域里面的的矩阵;
        subrmax=max(max(subr));
        if(R(i,j)>k*Rmax)&&(R(i,j)==subrmax)
            result(i,j)=1;
            cnt=cnt+1;
        end
    end
end

[posY,posX]=find(result==1);
% %cnt为检测出来的角点的个数;
% figure(2);
% imshow(orig_image);
% hold on;
% plot(posX,posY,'ro','MarkerSize',15);
% disp(cnt);
end
