//
//  CenterPrior.cpp
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

///制作中央先验图
Mat CenterPrior(Mat& img)
{
    Mat centerMap;
    int sigmaD=114*144;
    Mat coordinateMtx1(img.rows,img.cols,CV_32F,Scalar(0,0,0));
    Mat coordinateMtx2(img.rows,img.cols,CV_32F,Scalar(0,0,0));
    for(int i=0;i<img.cols;i++)
        for(int j=0;j<img.rows;j++)
            coordinateMtx1.at<float>(j,i)=j+1;
    for(int i=0;i<img.rows;i++)
        for(int j=0;j<img.cols;j++)
            coordinateMtx2.at<float>(i,j)=j+1;
    int centerX=img.rows/2;
    int centerY=img.cols/2;
    Mat centerXMtx=Mat::ones(img.rows,img.cols,CV_32F)*centerX;
    Mat centerYMtx=Mat::ones(img.rows,img.cols,CV_32F)*centerY;
    Mat sumMtx1=(coordinateMtx1-centerXMtx);
    Mat sumMtx2=(coordinateMtx2-centerYMtx);
    exp(-(sumMtx1.mul(sumMtx1)+sumMtx2.mul(sumMtx2))/sigmaD, centerMap);
    
    imshow("centerMap", centerMap);
    imwrite("images/centerMap.png", centerMap);
    waitKey();
    return centerMap;
}