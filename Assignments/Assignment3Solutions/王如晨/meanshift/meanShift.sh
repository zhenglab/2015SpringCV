#!/bin/bash
MatlabEXE='/Applications/MATLAB_R2013a.app/bin/matlab'
msMatlabFileDir='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part2Meanshift/批处理/meanshift/meanshiftBath.m'
evaMatlabFileDir='//Users/wangruchen/work/classComputerVision/assignment3_wo/code/part2Meanshift/批处理/SegmentationBenchmark/evaluationBatch.m'

#meanshift分割图像
${MatlabEXE} -nodesktop -nosplash -r "run ${msMatlabFileDir};quit"
#评价分割结果
${MatlabEXE} -nodesktop -nosplash -r "run ${evaMatlabFileDir};quit"