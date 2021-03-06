clc
clear

%%Setting
InputSeg = '/home/dai/tmp/PASCAL/PASCAL_Seg/';
InputGT = '/home/dai/tmp/PASCAL/PASCAL_GT/';
%%End Setting


IdsSeg = dir(InputSeg);                 %% 列出分割目录下次数文件夹名字
for i =1 : length(IdsSeg)

        if IdsSeg(i).name(1) == '.'     %%检测上级或本级目录
             continue    
        else
            NameSeg = IdsSeg(i).name;       %%列出目录下的次数文件夹名字 2 ～ 9
            PathSeg=strcat(InputSeg, NameSeg, '/');  %%Seg文件夹绝对路径/home/PASCAL_Bin/6/
            IdsSegImg=dir(PathSeg);    %%列出文件夹下文件1-seg.jpg~850-seg.jpg
            ImgNum=length(IdsSegImg)-2;
            precision = cell(1, ImgNum);
            recall = cell(1, ImgNum);
            Fmeasure = cell(1, ImgNum);
            for j =1 : length(IdsSegImg)   %%文件个数，852
                if IdsSegImg(j).name == '.'	%%检测上级或本级目录
                    continue
                else                  
                    Img=strcat(PathSeg,IdsSegImg(j).name); %%Seg文件夹的具体文件/home/PASCAL_Seg/0.6/20-seg.jpg
                    ImgGT=strrep(IdsSegImg(j).name,'-seg.jpg','.png'); %% ImgGT=20.png
                    ImgGT=strcat(InputGT, ImgGT);%%GT文件夹的具体文件/home/PASCAL_GT/20.png
                    Seg=im2double(imread(Img));  %%20-seg.jpg   
                    GT=im2double(imread(ImgGT)); %%20.png
                    [curPrecision, curRecall, curFmeasure] = prfCount(GT, Seg); 
                    precision{j-2} = curPrecision;  %%j=3开始
                    recall{j-2} = curRecall;
                    Fmeasure{j-2} = curFmeasure;
                end
            end

            precision = mean(cell2mat(precision), 2);     %%次数文件夹 2 ～ 9 下图像评价的平均值
            savePrecision = strcat('precision', '_', NameSeg);   %%precision_0.4,precision_0.5,precision_0.6
            eval( [ savePrecision, '= precision'] );
            
            recall = mean(cell2mat(recall), 2);
            saveRecall = strcat('recall', '_', NameSeg);
            eval( [saveRecall, ' = recall'] );
           
            Fmeasure = mean(cell2mat(Fmeasure), 2);
            saveFmeasure = strcat('Fmeasure', '_', NameSeg);
            eval( [saveFmeasure,' = Fmeasure'] );
            
            Outfilename=strcat(NameSeg, '.mat');
           save(Outfilename, savePrecision, saveRecall, saveFmeasure);
        end
end

%{
InputResults = './prf/';

load('0.2.mat');
load('0.3.mat');
load('0.4.mat');
load('0.5.mat');
load('0.6.mat');
load('0.7.mat');
load('0.8.mat');
%}

load('2.mat');
load('3.mat');
load('4.mat');
load('5.mat');
load('6.mat');
load('7.mat');
load('8.mat');

bar_all=[precision_2 ,recall_2,Fmeasure_2;precision_3,recall_3,Fmeasure_3;...
         precision_4 ,recall_4,Fmeasure_4;precision_5,recall_5,Fmeasure_5;...
         precision_6,recall_6,Fmeasure_6;precision_7,recall_7,Fmeasure_7;precision_8,recall_8,Fmeasure_8;];

bar(bar_all,'group');
set(gca,'XTickLabel',{'2','3','4','5','6','7','8'});
legend('Precision','Recall','F-measure',4);
set(gca,'xgrid','on');
grid;
print('-dpng', 'evalutaion.png'); 
