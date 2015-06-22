clear;
clc;

groundTruthPath = 'C:\Users\Owner\Desktop\新建文件夹\BSDS500\data\groundTruth\test\';
labelImgPath = 'C:\Users\Owner\Desktop\新建文件夹\LabeledImg';

% 批量读入文件名
labelImgList = dir(labelImgPath);
numX = 0;

for i = 1:length(labelImgList)
    if labelImgList(i).name(1)=='.'
        continue;
    end

        numX = numX+1;
        x(1, numX) = str2double(labelImgList(i).name);

%设置参数
        averageBoundaryError = 0;
        averageRI = 0;
        averageVOI = 0;
        averageGCE = 0;
        imageCount = 0;
        
% 生成带路径的文件名        
        labelImgPath = [labelImgPath '/' labelImgList(i).name];
        labelImgList = dir(labelImgPath);
        for j = 1:length(labelImgList)
            if labelImgList(j).name(1)=='.'
                continue;
            end

            groundTruthImgName = [groundTruthPath labelImgList(j).name];
            labelImgName = [labelImgPath '/' labelImgList(j).name];
          
% 读入文件
            load(groundTruthImgName);
            load(labelImgName);

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
            
% update the averages... note that sumRI / length(imageLabelCell) is
% equivalent to the PRI.
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
    if x(1,i)~=80;
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

% subplot(221);plot(xFinal,arrayRIFinal,'k'),title('Probabilistic Rand Index'),xlabel('hr'), ylabel('PRI');
% subplot(222);plot(xFinal,arrayVOIFinal,'b'),title('Variation of Information'),xlabel('hr'), ylabel('VOI');
subplot(121);plot(xFinal,arrayBEFinal,'b'),title('Global Consistency Error'),xlabel('hr'), ylabel('GCE');
subplot(122);plot(xFinal,arrayBEFinal,'r'),title('Boundary Displacement Error'),xlabel('hr'), ylabel('BDE');


