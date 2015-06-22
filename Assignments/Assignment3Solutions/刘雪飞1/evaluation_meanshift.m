Path1='C:\Users\Administrator\Desktop\assignment3\output/1';
Path2='C:\Users\Administrator\Desktop\assignment3\output/2';
benchPath = C:\Users\Administrator\Desktop\assignment3\groundTruth';
for n=1:2
    if(n==1)
        testpath=Path1;
    else
        testpath=Path2;
    end
    EvaluationBatch(benchpath,testpath);
End
