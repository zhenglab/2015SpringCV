clc
clear
 
%%Setting
Org='/home/dai/tmp/BSD500/Images/' ;
Res='/home/dai/tmp/BSD500/Results/Hr/';       %Res中存储mat型数据
Out='/home/dai/tmp/BSD500/OutImages/Hr/';     %Out中存储输出图像

%%Initialization
hs=40;  %80~100
hr=10;  %20~40
th=0.1; 
iteration=5;
%%Initialization

if ~isdir(Res)
    mkdir(Res);
end

if ~isdir(Out)
    mkdir(Out);
end

for hr=10:10:100
    str=num2str(hs);
    %%%~~~~~~~~~  Res   ~~~~~~~~~~~%%
    ResHsIds=strcat(Res,str);         
    if ~isdir(ResHsIds)
        mkdir(ResHsIds);
    end
    
    %%%~~~~~~~~~  Out   ~~~~~~~~~~~%%
    OutHsIds=strcat(Out,str);
    if ~isdir(OutHsIds)
        mkdir(OutHsIds);
    end
    
    IdsImages=dir(Org);
    for i=1:length(IdsImages)
        if IdsImages(i).name(1) == '.'
             continue
        else
             if strcmp(IdsImages(i).name((end-2):end), 'jpg') ||...
                  strcmp(IdsImages(i).name((end-2):end), 'png') ||...
                   strcmp(IdsImages(i).name((end-2):end), 'tif')                   
                    
            NameImg=IdsImages(i).name;
            Img=strcat(Org,NameImg);
            CurImg=imread(Img);
            
            %%%~~~~~  meanshift   ~~~~~~~%%%
            [OutImg,AveMeanshift] = meanShiftPixCluster(CurImg,hs,hr,th,iteration);
            PathOutImg=strcat(OutHsIds,'/',NameImg);
            imwrite(uint8(OutImg), PathOutImg);
            
            InfImg = processSuperpixelImage(OutImg);
            LabelImg = double(InfImg.segimage);
            PathOutRes=strcat(ResHsIds,'/',NameImg);
            PathOutRes=strrep(PathOutRes,'.jpg','.mat'); %Res的路径   
            save(PathResImg,'LabelImg');         %%输出数据
                        
              end
         end
    end
end

