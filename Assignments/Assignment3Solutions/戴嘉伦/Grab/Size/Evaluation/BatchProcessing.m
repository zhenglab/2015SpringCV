clc
clear

%%Setting
InputBin = '/home/dai/tmp/PASCAL/PASCAL_Seg/';
InputGT = '/home/dai/tmp/PASCAL/PASCAL_GT/';
%%End Setting


IdsSeg = dir(InputBin);                 %% 列出5~65
for i =1 : length(IdsSeg)

        if IdsSeg(i).name(1) == '.'     %%检测. ..目录
             continue    
        else
            NameSeg = IdsSeg(i).name;       %%列出文件夹下的文件夹名字 0.4,0.5,0.6
            PathSeg=strcat(InputBin, NameSeg, '/');  %%Seg文件夹绝对路径/home/PASCAL_Seg/0.6/
            IdsSegImg=dir(PathSeg);    %%列出文件夹下文件1-seg.jpg~20-seg.jpg
            ImgNum=length(IdsSegImg)-2;
            precision = cell(1, ImgNum);
            recall = cell(1, ImgNum);
            Fmeasure = cell(1, ImgNum);
            for j =1 : length(IdsSegImg)   %%文件个数，20
                if IdsSegImg(j).name == '.'
                    continue
                else                  
                    Img=strcat(PathSeg,IdsSegImg(j).name); %%Seg文件夹的具体文件/home/PASCAL_Seg/0.6/20-seg.jpg
                    ImgGT=strrep(IdsSegImg(j).name,'-seg.jpg','.png'); %%  img_gt=20.png
                    ImgGT=strcat(InputGT, ImgGT);%%GT文件夹的具体文件/home/PASCAL_GT/20.png
                    Seg=im2double(imread(Img));  %%20-seg.jpg   
                    GT=im2double(imread(ImgGT)); %%20.png
                    [curPrecision, curRecall, curFmeasure] = prfCount(GT, Seg); 
                    precision{j-2} = curPrecision;  %%j=3开始
                    recall{j-2} = curRecall;
                    Fmeasure{j-2} = curFmeasure;
                end
            end

            precision = mean(cell2mat(precision), 2);     %% 0.4,0.5,0.6的平均值
            savePrecision = strcat('precision', '_',NameSeg);   %%precision_0.4,precision_0.5,precision_0.6
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

InputResults = './prf/';

load('5.mat');
%load('10.mat');
load('15.mat');
%load('20.mat');
load('25.mat');
%load('30.mat');
load('35.mat');
%load('40.mat');
load('45.mat');
%load('50.mat');
load('55.mat');
%load('60.mat');
%load('65.mat');

%{
bar_all=[precision_5 ,recall_5,Fmeasure_5;precision_10 ,recall_10,Fmeasure_10;...
         precision_15 ,recall_15,Fmeasure_15;precision_20,recall_20,Fmeasure_20;...
         precision_25,recall_25,Fmeasure_25;precision_30,recall_30,Fmeasure_30;
         precision_35,recall_35,Fmeasure_35;precision_40,recall_40,Fmeasure_40;
         precision_45,recall_45,Fmeasure_45;precision_50,recall_50,Fmeasure_50;
         precision_55,recall_55,Fmeasure_55;precision_60,recall_60,Fmeasure_60;
         precision_65,recall_65,Fmeasure_65;];
%}
bar_all=[precision_5 ,recall_5,Fmeasure_5;precision_15 ,recall_15,Fmeasure_15;...
          precision_25,recall_25,Fmeasure_25; precision_35,recall_35,Fmeasure_35;...
          precision_45,recall_45,Fmeasure_45;precision_55,recall_55,Fmeasure_55;];
      
bar(bar_all,'group');
set(gca,'XTickLabel',{'5','15','25','35','45','55'});
legend('Precision','Recall','F-measure',4);
set(gca,'xgrid','on');
grid;
print('-dpng', 'evalutaion.png'); 
