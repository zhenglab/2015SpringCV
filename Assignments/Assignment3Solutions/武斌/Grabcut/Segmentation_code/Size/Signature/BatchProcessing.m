clc
clear

%%Setting
InputImages = '/home/wubin/assignment3/PASCAL/PASCAL/';
OutputSal = '/home/wubin/assignment3/PASCAL/PASCAL_Sal/';
%%End Setting



IdsImages = dir(InputImages);       %IdsImages表示InputImages目录下的图片文件
for i =1 : length(IdsImages)
     if IdsImages(i).name(1) == '.'          %判断现在处理的文件是否为上级目录
             continue    
        else           
            if strcmp(IdsImages(i).name((end-2):end), 'jpg') ||...  %在InputImags目录下，如果是图片才处理
                  strcmp(IdsImages(i).name((end-2):end), 'png') ||...
                   strcmp(IdsImages(i).name((end-2):end), 'tif')
                Img=IdsImages(i).name;                              %输入目录下的图像名
                ImgOutSal = strcat(OutputSal, Img);                 %输出图像的路径与文件名
                CurImg = strcat(InputImages, Img);                  %当前处理图像的路径与文件名
                Sig = SIG_single(CurImg);                           %用SIG处理
                Sig = uint8(mat2gray(Sig)*255);                      %转换图像类型为unit8
                seg = im2bw(Sig, 0.2);                         	 %分割图像，阈值为0.2
                ImgOutSal = strrep(ImgOutSal,'.jpg','-sal.jpg')
                imwrite(seg,ImgOutSal)                              %输出（写入）图像
            end
                             
     end
end
