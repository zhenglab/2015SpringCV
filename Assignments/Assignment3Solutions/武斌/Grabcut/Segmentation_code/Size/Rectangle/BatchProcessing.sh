PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Org="/home/wubin/assignment3/PASCAL/"
Sal="/home/wubin/assignment3/PASCAL/PASCAL_Sal/"
Seg="/home/wubin/assignment3/PASCAL/PASCAL_Seg/"
Bin="/home/wubin/assignment3/PASCAL/PASCAL_Bin/"
Rect="/home/wubin/assignment3/PASCAL/PASCAL_Rect/"
Exe="/home/wubin/assignment3/export/rectangle"

size=5
SizeUp=70
while [ "$size" != "$SizeUp" ]
do
	if [ ! -d "$Seg$size" ]; then
		mkdir "$Seg$size"		#在分割目录，创建不同次数的目录
	fi
	if [ ! -d "$Bin$size" ]; then
                mkdir "$Bin$size"		#在二值目录，创建不同次数的目录
	fi
        if [ ! -d "$Rect$size" ]; then
                mkdir "$Rect$size"               #在二值目录，创建不同次数的目录
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
#		echo "$SalName"
#		echo "$ImgName"
		if [ ${SalName} -eq ${ImgName} ]; then
			echo "${ImgName} Done"
			$Exe "$Org$Img" "$Sal$SalImg" "$size"
			ImgSeg="`ls -1 ${Org} | egrep 'seg' | sed -n "1p"`"
			ImgBin="`ls -1 ${Org} | egrep 'bin' | sed -n "1p"`"
			ImgRect="`ls -1 ${Org} | egrep 'rect' | sed -n "1p"`"
			mv "$Org$ImgSeg" "$Seg$size/$ImgSeg"
			mv "$Org$ImgBin" "$Bin$size/$ImgBin"
			mv "$Org$ImgRect" "$Rect$size/$ImgRect"
		else
			echo "${ImgName} No"
		fi
		j=$(($j+1))
	done
size=$(($size+5))
done
