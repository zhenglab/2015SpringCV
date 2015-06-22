clear all;
clc;

imgPath = 'PASCAL/';
sigRes = 'signatureResult/';

imgPathStru = dir(imgPath);
for thresholeValue = 0.1 : 0.1 : 0.9
    thrRes = [sigRes num2str(thresholeValue) '/'];
    mkdir(thrRes);
    for i = 1:length(imgPathStru)
        if imgPathStru(i).name(1) == '.' | ~strcmp(lower(imgPathStru(i).name(end-3:end)),'.jpg')
            continue;
        end
        imgName = [imgPath imgPathStru(i).name];
        SMresult=SIG_single(imgName);
        SMresult = uint8(mat2gray(SMresult)*255);
        seg = im2bw(SMresult, thresholeValue);
    %   imshow(seg,[]);
        sigResPath = [thrRes imgPathStru(i).name];
        imwrite(seg,sigResPath);
    end
end
