clear all;
clc;
groundTruth = 'PASCAL_GT/';
saliencyMap = '../../result/SegmentationResult/';

saliencyMapList = dir(saliencyMap);
paraNum = 0;
for i = 1:length(saliencyMapList)
    if saliencyMapList(i).name(1)=='.'
        continue;
    end
    paraNum = paraNum + 1;
    imgNum = 0;
    saliencyMapParaList = [saliencyMap saliencyMapList(i).name];
    x(1,paraNum) = str2double(saliencyMapList(i).name);
    saliencyMapNameList = dir(saliencyMapParaList);
    precisionSum = 0;
    recallSum = 0;
    FmeasureSum = 0;
    for j = 1:length(saliencyMapNameList)
        if saliencyMapNameList(j).name(1)=='.'
            continue;
        end
        imgNum = imgNum + 1;
        saliencyMapName = [saliencyMapParaList '/' saliencyMapNameList(j).name];
        groundTruthName = [groundTruth saliencyMapNameList(j).name(1:end-4) '.png'];
        saliencyMapImg = im2double(imread(saliencyMapName));
        groundTruthImg = im2double(imread(groundTruthName));
        [precision recall Fmeasure]=prfCount(groundTruthImg, saliencyMapImg);
        precisionSum = precisionSum + precision;
        recallSum = recallSum + recall;
        FmeasureSum = FmeasureSum + Fmeasure; 
    end
    paraMatirx(paraNum,1) = precisionSum/imgNum;
    paraMatirx(paraNum,2) = recallSum/imgNum;
    paraMatirx(paraNum,3) = FmeasureSum/imgNum;
end
x=[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];
bar(x,paraMatirx);
