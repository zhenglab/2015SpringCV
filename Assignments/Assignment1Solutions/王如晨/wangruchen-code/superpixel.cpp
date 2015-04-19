//
//  superpixel.cpp
//  saliency
//
//  Created by wangruchen on 15/4/14.
//  Copyright (c) 2015年 wangruchen. All rights reserved.
//

#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/ximgproc.hpp>

using namespace cv;
using namespace std;

int superpixel(Mat& outSuperpixel, Mat& superpixelLabel)
{
    
    Mat outSupContour;
    int supWidth=outSuperpixel.size().width;
    int supHeight=outSuperpixel.size().height;
    Ptr<ximgproc::SuperpixelSEEDS> seeds=cv::ximgproc::createSuperpixelSEEDS(supWidth, supHeight, outSuperpixel.channels(), 400, 4);
    seeds->iterate(outSuperpixel);//超像素分割迭代次数
    seeds->getLabels(superpixelLabel);//超像素分割标号
    seeds->getLabelContourMask(outSupContour,false);//超像素分割的边缘
    int numSuperpixel=seeds->getNumberOfSuperpixels();//超像素分割的数目
    outSuperpixel.setTo(Scalar(0,0,255),outSupContour);
    imshow("superpixel", outSuperpixel);
    waitKey();
    imwrite("/Users/wangruchen/work/class/Lecture2-Saliency/Lecture2-assignment/saliency/pic/superpixel.png", outSuperpixel);
    return numSuperpixel;
}
