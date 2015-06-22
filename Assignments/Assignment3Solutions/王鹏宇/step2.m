Imgnum=850;


mkdir(strcat('E:/class/computer vision/assignment3/signmap',num2str(threshold)));
for num=1:Imgnum
    image=imread(sprintf('E:/class/computer vision/assignment3/PASCAL/%d.jpg',num));
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
    imwrite(signmaplab,strcat('E:/class/computer vision/assignment3/signmap',num2str(threshold),'/lab',[num2str(num),'.jpg']));
      

end


