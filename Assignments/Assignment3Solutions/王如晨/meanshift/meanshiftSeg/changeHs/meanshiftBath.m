clear all;
clc;
t =cputime;
imgBSDPath = 'BSDS500/data/images/test/';
outputResLabPath = 'result/Label/';
outputResMSPath = 'result/MS/';

inputPath = dir(imgBSDPath);

%~~~~~~~~~~~~固定参数th,iteration,hr~~~~~~~~~~~~%
th = 0.1;%~~参数Iteration accuracy
iteration = 5;%~~参数The number of iterations
hr =10;%~~参数Color radius

%~~~~~~~~~~~~改变参数Spatial radius~~~~~~~~~~~~%
for hs = 10:10:100
    for imgNum = 1:length(inputPath)
        if inputPath(imgNum).name(1)=='.'
            continue;
        end
        inputImgName = strcat(inputPath(imgNum).name);
        inputImgPathAndName = [imgBSDPath inputImgName];

        inputImg = imread(inputImgPathAndName);
        outputResLabThIterationHrHsPath = [outputResLabPath num2str(th) '/' num2str(iteration) '/' num2str(hr) '/' num2str(hs) '/'];
        outputResMSThIterationHrHsPath = [outputResMSPath num2str(th) '/' num2str(iteration) '/' num2str(hr) '/' num2str(hs) '/'];
%~~~~~~~~~~~~建立文件夹~~~~~~~~~~~~%
        mkdir(outputResLabThIterationHrHsPath);
        mkdir(outputResMSThIterationHrHsPath);
%~~~~~~~~~~~~meanshift进行分割~~~~~~~~~~~~%
        [outputImg,aveMeanshift] = meanShiftPixCluster(inputImg,hs,hr,th,iteration);
%~~~~~~~~~~~~输出分割标号~~~~~~~~~~~~%
        imgInf = processSuperpixelImage(outputImg);
        imgLabel = double(imgInf.segimage);
        % imshow(uint8(outputImg));

        outputResLabParaImg = [outputResLabThIterationHrHsPath inputPath(imgNum).name(1:end-4) '.mat'];
        outputResMSParaImg = [outputResMSThIterationHrHsPath inputImgName];
        imwrite(uint8(outputImg),outputResMSParaImg);
        save(outputResLabParaImg,'imgLabel');
    end
end
t1 = cputime;
