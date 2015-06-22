clear all;
clc;
t =cputime;
imgBSDPath = 'BSDS500/data/images/test/';
outputResLabPath = 'result/Label/';
outputResMSPath = 'result/MS/';

% mkdir(outputResLabPath);
% mkdir(outputResMSPath);

inputPath = dir(imgBSDPath);


%     hs=10;
%     hr=10;
%     th=0.1;
%     iteration=5;

for th = 0.1:0.5:0.1
    for iteration = 5:3:5
        for hr =10:10:10
            for hs = 10:10:10
                for imgNum = 1:length(inputPath)
                    if inputPath(imgNum).name(1)=='.'
                        continue;
                    end
                    inputImgName = strcat(inputPath(imgNum).name);
                    inputImgPathAndName = [imgBSDPath inputImgName];

                    inputImg = imread(inputImgPathAndName);
                    outputResLabThIterationHrHsPath = [outputResLabPath num2str(th) '/' num2str(iteration) '/' num2str(hr) '/' num2str(hs) '/'];
                    outputResMSThIterationHrHsPath = [outputResMSPath num2str(th) '/' num2str(iteration) '/' num2str(hr) '/' num2str(hs) '/'];
                    mkdir(outputResLabThIterationHrHsPath);
                    mkdir(outputResMSThIterationHrHsPath);
                    
                    [outputImg,aveMeanshift] = meanShiftPixCluster(inputImg,hs,hr,th,iteration);
                    imgInf = processSuperpixelImage(outputImg);
                    imgLabel = double(imgInf.segimage);
                    % imshow(uint8(outputImg));

                    outputResLabParaImg = [outputResLabThIterationHrHsPath inputPath(imgNum).name(1:end-4) '.mat'];
                    outputResMSParaImg = [outputResMSThIterationHrHsPath inputImgName];
                    imwrite(uint8(outputImg),outputResMSParaImg);
                    save(outputResLabParaImg,'imgLabel');
                    
                end
            end
        end
    end
    
end
t1 = cputime;
