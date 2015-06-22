PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Org="/home/dai/tmp/PASCAL/PASCAL/"
Sal="/home/dai/tmp/PASCAL/PASCAL_Sal/"
Seg="/home/dai/tmp/PASCAL/PASCAL_Seg/"
Bin="/home/dai/tmp/PASCAL/PASCAL_Bin/"
Exe="/home/dai/tmp/Assignment#3/Code/Times/Rectangle/bin/Debug/rectangle"


time=2
TimeUp=9
while [ "$time" != "$TimeUp" ]
do
	if [ ! -d "$Seg$time" ]; then
		mkdir "$Seg$time"		#在分割目录，创建不同次数的目录
	fi
	if [ ! -d "$Bin$time" ]; then
               mkdir "$Bin$time"		#在二值目录，创建不同次数的目录
	fi
	SalImgNum="`ls -l "${Sal}" | egrep '.tif|.jpg|.bmp' | wc -l`"
						#wc -l 显示结果的行数
	j=1
	while [ "$j" != "$(($SalImgNum+1))" ]
	do
		SalImg=$(ls -1 "${Sal}"| egrep '.tif|.jpg|.bmp' | sed -n "$j p")
		Img=$(ls -1 "${Org}" | egrep '.tif|.jpg|.bmp' | sed -n "$j p")
		echo "$Org$Img"		
		echo "$Sal$SalImg"
		SalName=${SalImg%-*}
		ImgName=${Img%.*}
		if [ ${SalName} -eq ${ImgName} ]; then
			echo "${ImgName} Done"
			$Exe "$Org$Img" "$Sal$SalImg" "$time"
			ImgSeg="`ls -1 ${Org} | egrep 'seg' | sed -n "1p"`"
			ImgBin="`ls -1 ${Org} | egrep 'bin' | sed -n "1p"`"
			mv "$Org$ImgSeg" "$Seg$time/$ImgSeg"
			mv "$Org$ImgBin" "$Bin$time/$ImgBin"
		else
			echo "${ImgName} No"
		fi
		j=$(($j+1))
	done
time=$(($time+1))
done
