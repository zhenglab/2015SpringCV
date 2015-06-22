clear;
clc;
GT = '/home/dai/tmp/BSD500/GroudTruth/';
Res = '/home/dai/tmp/BSD500/Results/Hr';


IdsRes=dir(Res);
numX=0;
for i=1:length(IdsRes)
    if IdsRes(i).name(1)=='.'
        continue;
    end
        numX=numX+1;
        x(1,numX)=str2double(IdsRes(i).name);
        
        averageBoundaryError = 0;
        averageGCE = 0;
        CountImg=0;
        
        PathResIds=strcat(Res, '/', IdsRes(i).name);
        IdsResImg = dir(PathResIds);
        for j = 1:length(IdsResImg)
            if IdsResImg(j).name(1)=='.'
                continue;
            end
               ImgGT=strcat(GT,IdsResImg(j).name) ;
               Img=strcat(PathResIds, '/', IdsResImg(j).name);
               load(ImgGT);
               load(Img);
               
               CountImg = CountImg + 1;

               imageLabelCell=groundTruth;
               sampleLabels = imgLabel;
               
               sumBoundaryError = 0;
               sumGCE = 0;
               
               [imageX, imageY] = size(sampleLabels);
               [benchX, benchY] = size(imageLabelCell{1}.Segmentation);
               
                for benchIndex=1:length(imageLabelCell)
                     benchLabels = imageLabelCell{benchIndex}.Segmentation;

                % update the four error measures:        
                     sumBoundaryError = sumBoundaryError + compare_image_boundary_error(double(benchLabels), double(sampleLabels));        
                     [curRI,curGCE,curVOI] = compare_segmentations(sampleLabels,benchLabels);       
                     sumGCE = sumGCE + curGCE; 
                end
                
                 averageBoundaryError = averageBoundaryError + sumBoundaryError / length(imageLabelCell);
                  averageGCE = averageGCE + sumGCE / length(imageLabelCell);
        end
            arrayGCE(numX,1) = averageGCE/CountImg;
             arrayBE(numX,1) = averageBoundaryError/CountImg;
end

xNum = 0;
for i =1:length(x)
    if x(1,i)~=100;
        xNum = xNum+1;
        xFinal(1,xNum) = x(1,i);
        arrayGCEFinal(xNum,1) = arrayGCE(i,1);
        arrayBEFinal(xNum,1) = arrayBE(i,1);
    else
        xFinal(1,length(x)) = x(1,i);
        arrayGCEFinal(length(x),1) = arrayGCE(i,1);
        arrayBEFinal(length(x),1) = arrayBE(i,1);
    end
end


subplot(121);plot(xFinal,arrayBEFinal,'r'),title('BDE'),xlabel('hr'), ylabel('BDE');
subplot(122);plot(xFinal,arrayGCEFinal,'y'),title('GCE'),xlabel('hr'), ylabel('GCE');

 
