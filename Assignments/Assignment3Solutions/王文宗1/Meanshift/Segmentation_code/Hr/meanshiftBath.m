clear all;
clc;
t =cputime;
imgBSDPath = 'BSDS500/data/images/test/';
outputResLabPath = 'result/Label/';
outputResMSPath = 'result/MS/';

inputPath = dir(imgBSDPath);

%~~~~~~~~~~~~固定参数th,iteration,hs~~~~~~~~~~~~%
th = 0.1;%~~参数Iteration accuracy
iteration = 5;%~~参数The number of iterations
hs =40;%~~参数Spatial radius

%~~~~~~~~~~~~改变参数Color radius~~~~~~~~~~~~%
for hr = 10:10:100
    for imgNum = 1:length(inputPath)
        if inputPath(imgNum).name(1)=='.'
            continue;
        end
        inputImgName = strcat(inputPath(imgNum).name);
        inputImgPathAndName = [imgBSDPath inputImgName];

        inputImg = imread(inputImgPathAndName);
        outputResLabThIterationHsHrPath = [outputResLabPath num2str(th) '/' num2str(iteration) '/' num2str(hs) '/' num2str(hr) '/'];
        outputResMSThIterationHsHrPath = [outputResMSPath num2str(th) '/' num2str(iteration) '/' num2str(hs) '/' num2str(hr) '/'];
%~~~~~~~~~~~~建立文件夹~~~~~~~~~~~~%
        mkdir(outputResLabThIterationHsHrPath);
        mkdir(outputResMSThIterationHsHrPath);
%~~~~~~~~~~~~meanshift进行分割~~~~~~~~~~~~%
        [outputImg,aveMeanshift] = meanShiftPixCluster(inputImg,hs,hr,th,iteration);
%~~~~~~~~~~~~输出分割标号~~~~~~~~~~~~%
        imgInf = processSuperpixelImage(outputImg);
        imgLabel = double(imgInf.segimage);
        % imshow(uint8(outputImg));

        outputResLabParaImg = [outputResLabThIterationHsHrPath inputPath(imgNum).name(1:end-4) '.mat'];
        outputResMSParaImg = [outputResMSThIterationHsHrPath inputImgName];
        imwrite(uint8(outputImg),outputResMSParaImg);
        save(outputResLabParaImg,'imgLabel');
    end
end
t1 = cputime;
