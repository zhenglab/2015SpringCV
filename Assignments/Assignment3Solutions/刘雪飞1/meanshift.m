param1=[10 10;10 20;10 30;10 40;10 50;10 60;10 70;10 80;10 90;10 100];
param2=[10 40;20 40;30 40;40 40;50 40;60 40;70 40;80 40;90 40;100 40];
Files1=dir('C:\Users\Administrator\Desktop\assignment3\input/*.jpg');
LengthFiles1=length(Files1);
Files2=dir('C:\Users\Administrator\Desktop\assignment3\groundTruth/*.mat');
for n=1:2
    if n==1
        param=param1;
    else
        param=param2;
    end
    for numpa=1:10
      for i=1:LengthFiles1
            Img1=imread(strcat('C:\Users\Administrator\Desktop\assignment3\input/',Files1(i).name));
            Output=zeros(size(Img1));
            [Output,m]=meanShiftPixCluster(Img1,param(numpa,1),param(numpa,2));
            Lable=processSuperpixelImage(Output);
            save(sprintf('C:\Users\Administrator\Desktop\assignment3\output/%d/%d/%i.mat',n,numpa,i),'Lable');
      end
    end
end
Path1='C:\Users\Administrator\Desktop\assignment3\output/1';
Path2='C:\Users\Administrator\Desktop\assignment3\output/2';
benchPath = 'C:\Users\Administrator\Desktop\assignment3\groundTruth';
for n=1:2
    if(n==1)
        testpath=Path1;
    else
        testpath=Path2;
    end
    EvaluationBatch(benchpath,testpath);
end
        