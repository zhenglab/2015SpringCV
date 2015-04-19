//
//  ConvertChannel.cpp
//  WuBin
//
//  Created by 武斌 on 15/4/16.
//  Copyright (c) 2015年 WuBin. All rights reserved.
//


#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/ximgproc.hpp>
#include <math.h>

using namespace cv;
using namespace std;

//定义子函数－通道转换，将图像分解为RGB三个通道，并且将像素值量化为0~32*32*32，得到灰度图
Mat ConvertChannel(Mat& img){
    Mat ConvertChannel_img;
    vector<Mat> img_channel;
    split(img, img_channel);
    img_channel[0].convertTo(img_channel[0], CV_32F);
    img_channel[1].convertTo(img_channel[1], CV_32F);
    img_channel[2].convertTo(img_channel[2], CV_32F);
    ConvertChannel_img=(img_channel[0]/8)*32*32+(img_channel[1]/8)*32+(img_channel[2]/8);//用一个数来表示
    Mat ConvertChannel_img_nor;
    normalize(ConvertChannel_img, ConvertChannel_img_nor, 255, 0, NORM_MINMAX);  //归一化
    imshow("ConvertChannel_img",ConvertChannel_img_nor);
    imwrite("images/ConvertChannelImg.png", ConvertChannel_img_nor);
    waitKey();
    return ConvertChannel_img;
}

