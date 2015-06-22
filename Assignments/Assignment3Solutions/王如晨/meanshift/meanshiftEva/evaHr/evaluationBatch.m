clear;
clc;
benchPath = 'groundTruth/test/';
testPath = '../meanshift/参数2/result/Label/0.1/5/40';

testList = dir(testPath);
numX = 0;
for i = 1:length(testList)
    if testList(i).name(1)=='.'
        continue;
    end
        numX = numX+1;
        x(1,numX) = str2double(testList(i).name);

        averageBoundaryError = 0;
        averageRI = 0;
        averageVOI = 0;
        averageGCE = 0;
        imageCount = 0;
        testImgPath = [testPath '/' testList(i).name];
        testImgList = dir(testImgPath);
        for j = 1:length(testImgList)
            if testImgList(j).name(1)=='.'
                continue;
            end
            benchImgName = [benchPath testImgList(j).name];
            testImgName = [testImgPath '/' testImgList(j).name];
            load(benchImgName);
            load(testImgName);

            imageCount = imageCount + 1;
            imageLabelCell=groundTruth;
            sampleLabels = imgLabel;

            % Comparison script
            totalBoundaryError = 0;
            sumRI = 0;
            sumVOI = 0;
            sumGCE = 0;

            [imageX, imageY] = size(sampleLabels);
            [benchX, benchY] = size(imageLabelCell{1}.Segmentation);
            for benchIndex=1:length(imageLabelCell)
                benchLabels = imageLabelCell{benchIndex}.Segmentation;

                % update the four error measures:        
                totalBoundaryError = totalBoundaryError + compare_image_boundary_error(double(benchLabels), double(sampleLabels));        
                [curRI,curGCE,curVOI] = compare_segmentations(sampleLabels,benchLabels);       
                sumRI = sumRI + curRI;
                sumVOI = sumVOI + curVOI;
                sumGCE = sumGCE + curGCE;        
            end
            averageBoundaryError = averageBoundaryError + totalBoundaryError / length(imageLabelCell);
            averageRI = averageRI + sumRI / length(imageLabelCell);
            averageVOI = averageVOI + sumVOI / length(imageLabelCell);
            averageGCE = averageGCE + sumGCE / length(imageLabelCell);
        end
        arrayRI(numX,1) = averageRI/imageCount;
        arrayVOI(numX,1) = averageVOI/imageCount;
        arrayGCE(numX,1) = averageGCE/imageCount;
        arrayBE(numX,1) = averageBoundaryError/imageCount;
end
xNum = 0;
for i =1:length(x)
    if x(1,i)~=100;
        xNum = xNum+1;
        xFinal(1,xNum) = x(1,i);
        arrayRIFinal(xNum,1) = arrayRI(i,1);
        arrayVOIFinal(xNum,1) = arrayVOI(i,1);
        arrayGCEFinal(xNum,1) = arrayGCE(i,1);
        arrayBEFinal(xNum,1) = arrayBE(i,1);
    else
        xFinal(1,length(x)) = x(1,i);
        arrayRIFinal(length(x),1) = arrayRI(i,1);
        arrayVOIFinal(length(x),1) = arrayVOI(i,1);
        arrayGCEFinal(length(x),1) = arrayGCE(i,1);
        arrayBEFinal(length(x),1) = arrayBE(i,1);
    end
end

subplot(221);plot(xFinal,arrayBEFinal,'r'),title('BDE'),xlabel('hr'), ylabel('BDE');
subplot(222);plot(xFinal,arrayRIFinal,'k'),title('PRI'),xlabel('hr'), ylabel('PRI');
subplot(223);plot(xFinal,arrayVOIFinal,'b'),title('VOI'),xlabel('hr'), ylabel('VOI');
subplot(224);plot(xFinal,arrayBEFinal,'y'),title('GCE'),xlabel('hr'), ylabel('GCE');
