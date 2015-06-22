#!/bin/bash
if [ ! -d "sizeResult" ]; then
	mkdir sizeResult
fi
cd sizeResult
if [ ! -d "resGrabCut" ]; then
	mkdir resGrabCut
fi
if [ ! -d "resBinImg" ]; then 
	mkdir resBinImg
fi
if [ ! -d "resRectangle" ]; then
	mkdir resRectangle
fi
cd ..
saliencyMapPath='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/signature/signatureResult/0.3'
origImgPath='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/PASCAL'
grabCutPro='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/GrabcutCode/Rectangle_Grabcut/grabcutSizePro'
resObjRecSegImgPath='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/GrabcutCode/Rectangle_Grabcut/result'
resPath='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/sizeResult'
imgPathList=$(ls $saliencyMapPath)
num="0 10 20 30 40 50 60"
for j in $num
do
	if [ ! -d "${resPath}/resGrabCut/${j}" ]; then
		mkdir "${resPath}/resGrabCut/${j}"
	fi
	if [ ! -d "${resPath}/resRectangle/${j}" ]; then
		mkdir "${resPath}/resRectangle/${j}"
	fi
	if [ ! -d "${resPath}/resBinImg/${j}" ]; then
		mkdir "${resPath}/resBinImg/${j}"
	fi
	for i in $imgPathList
	do
		binImgName=${saliencyMapPath}"/"$i
		origImgName=${origImgPath}"/"$i
		${grabCutPro} ${origImgName} ${binImgName} ${j}
		resObjRecSegImgPathList=$(ls $resPath)
		for m in $resObjRecSegImgPathList
		do
			#重命名
			mv ${resObjRecSegImgPath}"/"${m}"/"${m}".jpg" ${resObjRecSegImgPath}"/"${m}"/"${i}
			#移动
			mv ${resObjRecSegImgPath}"/"${m}"/"${i} ${resPath}"/"${m}"/"${j}
		done
	done
done