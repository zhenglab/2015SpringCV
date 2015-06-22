clear;
close all;
clc;
file_path = 'C:\Users\Administrator.NTPVB2AO09XFWFK\Desktop\liuchang_assignment3\PASCAL_GT' ;
binary_map_path_f='C:\Users\Administrator.NTPVB2AO09XFWFK\Desktop\liuchang_assignment3\Grab_cut1\imgSignature';
groundtruth_path_list = dir(strcat(file_path,'*.png'));
groundtruth_num = length(groundtruth_path_list);
saveall=[];
for threshold=0.3:0.1:0.7    
   binary_map_path=strcat(binary_map_path_f,num2str(threshold),'\');
   binary_map_path_list = dir(strcat(binary_map_path,'*.jpg'));
   binary_map_num = length(binary_map_path_list);
   savedata=[];
   for i=1:50
       groundtruth_name=groundtruth_path_list(i).name;
       binary_map_name= binary_map_path_list(i).name;
       groundtruth=imread(strcat(file_path,groundtruth_name));
       salencymap=imread(strcat(salencymap_path,salencymap_name));
       [temp1 temp2 temp3]=prfCount(im2double(groundtruth), im2double(salencymap));
       temp=[temp1,temp2,temp3];
       savedata=[savedata;temp];  
   end
       savedata_mean=mean(savedata);
       saveall=[saveall;savedata_mean];
end
bar([0.3,0.4,0.5,0.6,0.7],saveall);
set(gca,'XTick',[0.3:0.1:0.7]);
legend('Precision','Recall','F-measure',4);
