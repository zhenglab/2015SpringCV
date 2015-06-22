
 
clear;
clc;

benchPath = 'E:/computer_vision/BSDS500/data/groundTruth/train/';
testPath = 'E:/MS/SegImage/seg_img1010/';
cropBenchImage = true;

testImageList = dir(testPath);
if isempty(testImageList)
    error('Cannot find the image directories.');
end


averageBoundaryError = 0;
averageRI = 0;
averageVOI = 0;
averageGCE = 0;

imageCount = 0;
for imageIndex=1:length(testImageList)
    if testImageList(imageIndex).name(1)=='.'
        continue;
    end
    
    testFilename = [testPath testImageList(imageIndex).name];
    if ~strcmp(lower(testFilename(end-3:end)),'.mat')

        continue;
    end
    
    benchFilename = [benchPath testImageList(imageIndex).name];
    if isempty(dir(benchFilename))
     
        warning(['Cannot find the bench file for ' testImageList(imageIndex).name]);
    end
    
    disp(['Processing ' testImageList(imageIndex).name]);
    superpixelLabels = [];
    load(benchFilename);
    load(testFilename);
    imageCount = imageCount + 1;
    
    
    imageLabelCell=groundTruth;
    sampleLabels = seg_img.segimage;

    totalBoundaryError = 0;
    sumRI = 0;
    sumVOI = 0;
    sumGCE = 0;

    [imageX, imageY] = size(sampleLabels);
    [benchX, benchY] = size(imageLabelCell{1}.Segmentation);
    i=length(imageLabelCell);
    for benchIndex=1:length(imageLabelCell)
        benchLabels = imageLabelCell{benchIndex}.Segmentation;
        
   
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

    disp(['Current err:  Boundary  RI  VOI  GCE:']);
    disp([num2str(averageBoundaryError/imageCount) '  ' num2str(averageRI/imageCount) ...
         '  ' num2str(averageVOI/imageCount) '  ' num2str(averageGCE/imageCount)]);
end

averageBoundaryError = averageBoundaryError / imageCount
averageRI = averageRI / imageCount
averageGCE = averageGCE / imageCount
averageVOI = averageVOI / imageCount