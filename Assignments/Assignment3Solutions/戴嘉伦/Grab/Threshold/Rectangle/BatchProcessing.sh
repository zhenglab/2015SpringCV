PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Org="/home/dai/tmp/PASCAL/PASCAL/"
Sal="/home/dai/tmp/PASCAL/PASCAL_Sal/"
Seg="/home/dai/tmp/PASCAL/PASCAL_Seg/"
Bin="/home/dai/tmp/PASCAL/PASCAL_Bin/"
Exe="/home/dai/tmp/Sig_Grab/Rectangle/bin/Debug/rectangle"


SalIdsNum="`ls -l ${Sal} | wc -l`"

i=1

while [ "$i" != "$(($SalIdsNum))" ]
do
	IdsSal=$(ls -1 ${Sal} | sed -n "$i p")	#IdsSal表示Sal目录下的目录名,/0.2/ ~ /0.8/
						#ls -1 只显示文件名
						#sed -n "$i p" 安静模式取第i行
	if [ ! -d "$Seg$IdsSal" ]; then
		mkdir "$Seg$IdsSal"		#在分割目录，创建不同阈值的目录,/0.2/ ~ /0.8/
	fi
	if [ ! -d "$Bin$IdsSal" ]; then
               mkdir "$Bin$IdsSal"		#在二值目录，创建不同阈值的目录,/0.2/ ~ /0.8/
	fi
	ImgNum="`ls -l "${Sal}${IdsSal}" | egrep '.tif|.jpg|.bmp' | wc -l`"
						#wc -l 显示结果的行数
	j=1
	while [ "$j" != "$(($ImgNum+1))" ]
	do
		Img=$(ls -1 "${Sal}${IdsSal}"| egrep '.tif|.jpg|.bmp' | sed -n "$j p")
		echo "$Org$Img"			#显示正在处理的原图像
		echo "$Sal$IdsSal/$Img"		#显示正在处理的显著图像图像
		$Exe "$Org$Img" "$Sal$IdsSal/$Img"	#执行程序，输入原图，显著图
		ImgSeg="`ls -1 ${Org} | egrep 'seg' | sed -n "1p"`"
		ImgBin="`ls -1 ${Org} | egrep 'bin' | sed -n "1p"`"
		mv "$Org$ImgSeg" "$Seg$IdsSal/$ImgSeg"		#将分割图像与二值图移出
		mv "$Org$ImgBin" "$Bin$IdsSal/$ImgBin"
		j=$(($j+1))
	done
	i=$(($i+1))
done
