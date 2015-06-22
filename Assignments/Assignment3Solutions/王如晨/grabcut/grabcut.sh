#!/bin/bash
if [ ! -d "result" ]; then
	mkdir result
fi
cd result
if [ ! -d "obj" ]; then
	mkdir obj
fi
if [ ! -d "SegmentationResult" ]; then 
	mkdir SegmentationResult
fi
if [ ! -d "Rectangle" ]; then
	mkdir Rectangle
fi
cd ..
saliencyMapPath='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/signature/signatureResult'
origImgPath='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/PASCAL'
grabCutPro='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/GrabcutCode/Rectangle_Grabcut/grabcutPro'
resObjRecSegImgPath='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/GrabcutCode/Rectangle_Grabcut/result'
resPath='/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/result'
imgPathList=$(ls $saliencyMapPath)

for i in $imgPathList
do
	if [ ! -d "${resPath}/obj/${i}" ]; then
		mkdir "${resPath}/obj/${i}"
	fi
	if [ ! -d "${resPath}/Rectangle/${i}" ]; then
		mkdir "${resPath}/Rectangle/${i}"
	fi
	if [ ! -d "${resPath}/SegmentationResult/${i}" ]; then
		mkdir "${resPath}/SegmentationResult/${i}"
	fi
	imgPathName=${saliencyMapPath}"/"${i}
	imgList=$(ls $imgPathName)

	for j in $imgList
	do
		imgName=${imgPathName}"/"${j}
		origImgName=${origImgPath}"/"${j}
		${grabCutPro} ${origImgName} ${imgName}
		resObjRecSegImgPathList=$(ls $resObjRecSegImgPath)
		for n in $resObjRecSegImgPathList
		do
			#重命名
			mv ${resObjRecSegImgPath}"/"${n}"/"${n}".jpg" ${resObjRecSegImgPath}"/"${n}"/"${j}
			#移动
			mv ${resObjRecSegImgPath}"/"${n}"/"${j} ${resPath}"/"${n}"/"${i}
		done
	done
done

