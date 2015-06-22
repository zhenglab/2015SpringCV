PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Org="/home/dai/tmp/PASCAL/PASCAL/"
Sal="/home/dai/tmp/PASCAL/PASCAL_Sal/"
Seg="/home/dai/tmp/PASCAL/PASCAL_Seg/"
Bin="/home/dai/tmp/PASCAL/PASCAL_Bin/"
Exe="/home/dai/tmp/Assignment#3/Code/Times/Rectangle/bin/Debug/rectangle"


time=2					
TimeUp=9
while [ "$time" != "$TimeUp" ]			#迭代次数从2 ～ 9
do
	if [ ! -d "$Seg$time" ]; then
		mkdir "$Seg$time"		#在分割目录，创建不同次数的目录，/2/ ~ /9/
	fi
	if [ ! -d "$Bin$time" ]; then
               mkdir "$Bin$time"		#在二值目录，创建不同次数的目录，/2/ ~ /9/
	fi
	SalImgNum="`ls -l "${Sal}" | egrep '.tif|.jpg|.bmp' | wc -l`"
						#wc -l 显示结果的行数
	j=1
	while [ "$j" != "$(($SalImgNum+1))" ]
	do
		SalImg=$(ls -1 "${Sal}"| egrep '.tif|.jpg|.bmp' | sed -n "$j p")
		Img=$(ls -1 "${Org}" | egrep '.tif|.jpg|.bmp' | sed -n "$j p")
		echo "$Org$Img"			#显示正在处理的图像
		echo "$Sal$SalImg"		#显示正在处理的显著图
		SalName=${SalImg%-*}
		ImgName=${Img%.*}	
		if [ ${SalName} -eq ${ImgName} ]; then	#判断是否是一张图，即1.jpg与1-sal.jpg
			echo "${ImgName} Done"
			$Exe "$Org$Img" "$Sal$SalImg" "$time"	#执行程序,输入原图，显著图，迭代次数
			ImgSeg="`ls -1 ${Org} | egrep 'seg' | sed -n "1p"`"
			ImgBin="`ls -1 ${Org} | egrep 'bin' | sed -n "1p"`"
			mv "$Org$ImgSeg" "$Seg$time/$ImgSeg"	#将分割与二值图移出
			mv "$Org$ImgBin" "$Bin$time/$ImgBin"
		else
			echo "${ImgName} No"
		fi
		j=$(($j+1))
	done
time=$(($time+1))
done
