//
//  SuperPixelSegmentation.cpp
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

//定义子函数－超像素分割，对图像进行超像素分割，得到图像的超像素标记图、分割块数以及分割图
int SuperPixelSegmentation(Mat& superpixel_img, Mat& superpixel_label){
    Mat superpixel_contour;
    int superpixel_width=superpixel_img.size().width;
    int superpixel_height=superpixel_img.size().height;
    Ptr<cv::ximgproc::SuperpixelSEEDS> seeds=cv::ximgproc::createSuperpixelSEEDS(superpixel_width, superpixel_height, superpixel_img.channels(), 400, 4);
    seeds->iterate(superpixel_img); //迭代，访问每一个像素点的值
    seeds->getLabels(superpixel_label);//对每一个超像素块进行标号
    seeds->getLabelContourMask(superpixel_contour,false);//找边界信息
    int superpixel_number=seeds->getNumberOfSuperpixels();//超像素的块数
    superpixel_img.setTo(Scalar(0,0,255),superpixel_contour);//用颜色标记出来每一块超像素
    imshow("SuperPixel_img", superpixel_img);
    imwrite("images/SuperPixelImg.png",superpixel_img);
    waitKey();
    return superpixel_number;
}