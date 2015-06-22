clc;
clear all;
evalu=zeros(7,3);
i=1;
for threshold=0.2:0.1:0.8
    for num=1:850
        image1=imread(sprintf('E:/class/computer vision/assignment3/PASCAL_GT/%d.png',num));
        image1=im2double(image1);
        image2=im2double(imread(sprintf('E:/output/%2.1f/%d.jpg',threshold,num)));
        [precision recall Fmeasure]=prfCount(image1,image2);
        evalu(i,:)=evalu(i,:)+[precision recall Fmeasure];
    end
    i=i+1;
end

avrevalu=evalu/850;
x=[0.2,0.3,0.4,0.5,0.6,0.7,0.8];
bar(x,avrevalu,'group');legend('pecision','recall','Fmeasure');
    
        