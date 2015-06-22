clear;
close all;
clc;

file_path = 'E:\computer_vision\PASCAL_GT\' ;
salencymap_path_f='C:\Users\Owner\Desktop\output_k3\';

groundtruth_path_list = dir(strcat(file_path,'*.png'));
groundtruth_num = length(groundtruth_path_list);
saveall=[];



for threshold=0.2:0.1:0.8
    
 salencymap_path=strcat(salencymap_path_f,num2str(threshold),'\');
   salencymap_path_list = dir(strcat(salencymap_path,'*.jpg'));
   salencymap_num = length(salencymap_path_list);
   savedata=[];
   for i=1:salencymap_num
       groundtruth_name=groundtruth_path_list(i).name;
       salencymap_name=   salencymap_path_list(i).name;
       groundtruth=imread(strcat(file_path,groundtruth_name));
       salencymap=imread(strcat(salencymap_path,salencymap_name));
       [temp1 temp2 temp3]=prfCount(im2double(groundtruth), im2double(salencymap));
       temp=[temp1,temp2,temp3];
       savedata=[savedata;temp];  
   end
       savedata_mean=mean(savedata);
       saveall=[saveall;savedata_mean];
end
bar([0.2,0.3,0.4,0.5,0.6,0.7,0.8],saveall);
set(gca,'XTick',[0.2:0.1:0.8]);
legend('Precision','Recall','F-measure',4);
