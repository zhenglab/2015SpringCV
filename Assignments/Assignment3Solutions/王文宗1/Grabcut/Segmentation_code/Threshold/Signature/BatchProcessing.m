clc
clear

%%Setting
InputImages = '/home/wubin/assignment3/PASCAL/';
OutputSal = '/home/wubin/assignment3/PASCAL_Sal/';
%%End Setting



IdsImages = dir(InputImages);       %IdsImages表示InputImages目录下的图片文件，为Ids（struct）格式
for threshold=0.2:0.1:0.8
    str=num2str(threshold)          %转换threshold，从数字型变为字符型
    DstOutSal = strcat(OutputSal, str, '/');    %在Sal目录下创建不同阈值输出目录
    for i =1 : length(IdsImages)
        if IdsImages(i).name(1) == '.'          %判断现在处理的文件是否为上级目录
             continue    
        else           
            if ~isdir(DstOutSal)             %判断是否创建了阈值输出目录
                mkdir(DstOutSal);
            end
            if strcmp(IdsImages(i).name((end-2):end), 'jpg') ||...  %在InputImags目录下，如果是图片才处理
                  strcmp(IdsImages(i).name((end-2):end), 'png') ||...
                   strcmp(IdsImages(i).name((end-2):end), 'tif')
                Img=IdsImages(i).name;                              %输入目录下的图像名
                ImgOutSal = strcat(DstOutSal, Img);                 %输出图像的路径与文件名
                CurImg = strcat(InputImages, Img);                  %当前处理图像的路径与文件名
                
                img = imread(CurImg);
                height=size(img,1);
                width=size(img,2);
                
                Sig = SIG_single(CurImg);                           %用SIG处理
                Sig = uint8(mat2gray(Sig)*255);                      %转换图像类型为unit8
                seg = im2bw(Sig, threshold);                        %分割图像
                
                seg=imresize(seg,[height width]);
                
                ImgOutSal = strrep(ImgOutSal,'.jpg','-sal.jpg')
                imwrite(seg,ImgOutSal)                              %输出（写入）图像
            end
                             
        end
    end
end