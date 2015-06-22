clc;
clear all;
Imgnum=850;
threshold=0.05;
Files = dir(fullfile('C:\Users\Administrator\Desktop\assignment3\PASCAL','*.jpg'));
i=0;
Length = length(Files);
for h=1: Length
 image= imread(strcat('C:\Users\Administrator\Desktop\assignment3\PASCAL\',Files(h).name));
%mkdir(strcat('C:\Users\Administrator\Desktop\assignment3\PASCAL',num2str(threshold)));

    %image=imread(sprintf('C:\Users\Administrator\Desktop\assignment3/PASCAL/%d.jpg',h));
    param=default_signature_param();
    signmaplab=signatureSal(image,param);
    signmaplab=imresize(signmaplab,[size(image,1) size(image,2)]);
    for i=1:size(signmaplab,1)
        for j=1:size(signmaplab,2)
            if signmaplab(i,j)>=threshold
                signmaplab(i,j)=255;
            else
                signmaplab(i,j)=0;
            end
        end
    end            
    imwrite(signmaplab,strcat('C:\Users\Administrator\Desktop\assignment3\signmap',num2str(threshold),'/lab',[num2str(h),'.jpg']));
end
