function main
clc;
clear;
close all;

%The coner points extractions using Harris methods;
frame=imread('object2.png');
figure(1);
imshow(frame);

%����harris�ǵ����Ӻ���;
%����������ͣ�frameΪ����ͼ��,7Ϊ��˹�˲����ڴ�С��2Ϊ������sigma��ֵ��
%0,04Ϊ�Ƽ���kֵ��winsizeΪ�������ƴ��ڵĴ�С�Ҹ�����ʱΪ����;
%����������ͣ�posXΪ��⵽�ǵ�X���꣬posYΪ��⵽�ǵ�Y���꣬
%cntΪ��⵽�ǵ�ĸ�����Out_ImageΪ���ͼ��;
[posX,posY,cnt,Out_Image]=conerdetection(frame,7,2,0.04,7);      %�����ͼ���Ѿ���2ֵ����
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
%winsizeΪ�������ƴ��ڴ�С
Out_Image=frame;
ImageData=frame;
ImageData= double(ImageData(:,:,2));    %ImageData���ݾ���ʽһ����ͨ���ģ����ǽǵ���ֻ��ѡ��һ������;
%ImageData=im2bw(ImageData,0.5);        %���߽�3ͨ���ĵ�ͼ��ת����2ֵ����ͼ�������ȡ;

%�㷨���ͣ�
%1������ˮƽ����ֱ������Ӷ�ͼ���ÿ�����ؽ����˲������Ix,Iy���������M�������ĸ�Ԫ�ص�ֵ;
%M=[Ix*Ix,Ix*Iy;Ix*Iy,Iy*Iy]
orig_image=ImageData;
fx=[-2,-1,0,1,2];
Ix=filter2(fx,orig_image);
fy=[-2;-1;0;1;2];
Iy=filter2(fy,orig_image);
Ix2=Ix.*Ix;
Iy2=Iy.*Iy;
Ixy=Ix.*Iy;

%2:��M���ĸ�Ԫ�ؽ��и�˹ƽ���˲����õ��µľ���M;
%�˲�ƽ��������ͻ����,�õ��µľ���M;
h=fspecial('gaussian',[GaussWindow,GaussWindow],sigma);     %�����˲�����
Ix2=filter2(h,Ix2);     %filter2����h�˲�������Ix2�ƶ�����ģ���˲�
Iy2=filter2(h,Iy2);     %����y�����ϵ�ͻأ��
Ixy=filter2(h,Ixy);

%��ȡǰ��ͼ������Ԥ����;
height=size(orig_image,1);       %����ͼ��������������
width=size(orig_image,2);        %����ͼ��������������
result=zeros(height,width);      % ��¼�ǵ�λ��,�ǵ㴦ֵΪ1 
R=zeros(height,width);           %������ͼ������С��ͬ�������
Rmax=0;                          % ͼ��������Rֵ 

%3:����������M�����Ӧ��ÿ�����صĽǵ���Ӧ����Cim(��R)��
%���㹫ʽΪ��R=det(M)-k*(trace(M))^2,����kΪһ��������������ѡȡ0.04�Ϳ���;
%����k��ȡֵ��Щ̫���⣬��ˣ����ô˹�ʽ�����µĹ�ʽ����R��R=det(M)/Tr(M);
%��Cim=R=[Ix*Ix*Iy*Iy-(Ix*Iy)*(Ix*Iy)]/[Ix*Ix+Iy*Iy];
for i=1:height
    for j=1:width
        M=[Ix2(i,j),Ixy(i,j);Ixy(i,j),Iy2(i,j)];        %%����ؾ���
        R(i,j)=det(M)-0.04*(trace(M))^2;                %% ����Rֵ,det()��һ�����������ʽ(Determinant);trace()����ļ������÷���Խ�����Ԫ��֮��;
        if  R(i,j)>Rmax
            Rmax=R(i,j);
        end
    end
end

%winsizeΪ�Ǽ������ƴ���
winr=(winsize-1)/2;        %the radius of the neighborhood
istart=winr+1;
jstart=winr+1;
iend=height-winr;
jend=width-winr;

cnt=0;
for i=istart:iend
    for j=jstart:jend
        subr=R((i-winr):(i+winr),(j-winr):(j+winr));        %ȡ��winr*winr�����������ĵľ���;
        subrmax=max(max(subr));
        if(R(i,j)>k*Rmax)&&(R(i,j)==subrmax)
            result(i,j)=1;
            cnt=cnt+1;
        end
    end
end

[posY,posX]=find(result==1);
% %cntΪ�������Ľǵ�ĸ���;
% figure(2);
% imshow(orig_image);
% hold on;
% plot(posX,posY,'ro','MarkerSize',15);
% disp(cnt);
end
