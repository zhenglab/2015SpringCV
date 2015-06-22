#!/bin/bash
MatlabEXE='/Applications/MATLAB_R2013a.app/bin/matlab'
sigMatlabFileDir='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/signature/signatureBath.m'
evaMatlabFileDir='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/GrabcutCode/Evaluation/grabCutEvaBath.m'
GrabCutDir='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/grabcut.sh'
#signature得到显著图
${MatlabEXE} -nodesktop -nosplash -r "run ${sigMatlabFileDir};quit"
#阈值参数调整得到结果
${GrabCutDir}
#结果评价
${MatlabEXE} -nodesktop -nosplash -r "run ${evaMatlabFileDir};quit"