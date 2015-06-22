clear;
clc;
benchPath = 'groundTruth/test/';
testPath = '../meanshift/参数1/result/Label/0.1/5/10';

testList = dir(testPath);
numX = 0;
%  x = zeros(1,10);
for i = 1:length(testList)
    if testList(i).name(1)=='.'
        continue;
    end
%     if str2double(testList(i).name) ~= 100;
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
        %     i=length(imageLabelCell);
            for benchIndex=1:length(imageLabelCell)
                benchLabels = imageLabelCell{benchIndex}.Segmentation;

                % update the four error measures:        
                totalBoundaryError = totalBoundaryError + compare_image_boundary_error(double(benchLabels), double(sampleLabels));        
                [curRI,curGCE,curVOI] = compare_segmentations(sampleLabels,benchLabels);       
                sumRI = sumRI + curRI;
                sumVOI = sumVOI + curVOI;
                sumGCE = sumGCE + curGCE;        
            end

            % update the averages... note that sumRI / length(imageLabelCell) is
            % equivalent to the PRI.
            averageBoundaryError = averageBoundaryError + totalBoundaryError / length(imageLabelCell);
            averageRI = averageRI + sumRI / length(imageLabelCell);
            averageVOI = averageVOI + sumVOI / length(imageLabelCell);
            averageGCE = averageGCE + sumGCE / length(imageLabelCell);

    %         disp(['Current err:  Boundary  RI  VOI  GCE:']);
    %         disp([num2str(averageBoundaryError/imageCount) '  ' num2str(averageRI/imageCount) ...
    %              '  ' num2str(averageVOI/imageCount) '  ' num2str(averageGCE/imageCount)]);
        end
    %     averageBoundaryError = averageBoundaryError / imageCount;
    %     averageRI = averageRI / imageCount;
    %     averageGCE = averageGCE / imageCount;
    %     averageVOI = averageVOI / imageCount;
        arrayRI(numX,1) = averageRI/imageCount;
        arrayVOI(numX,1) = averageVOI/imageCount;
        arrayGCE(numX,1) = averageGCE/imageCount;
        arrayBE(numX,1) = averageBoundaryError/imageCount;
%     end
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

subplot(221);plot(xFinal,arrayBEFinal,'r'),title('BDE'),xlabel('hs'), ylabel('BDE');
subplot(222);plot(xFinal,arrayRIFinal,'k'),title('PRI'),xlabel('hs'), ylabel('PRI');
subplot(223);plot(xFinal,arrayVOIFinal,'b'),title('VOI'),xlabel('hs'), ylabel('VOI');
subplot(224);plot(xFinal,arrayBEFinal,'y'),title('GCE'),xlabel('hs'), ylabel('GCE');
