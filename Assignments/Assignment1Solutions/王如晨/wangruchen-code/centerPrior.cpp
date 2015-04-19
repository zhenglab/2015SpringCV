//
//  centerPrior.cpp
//  saliency
//
//  Created by wangruchen on 15/4/14.
//  Copyright (c) 2015年 wangruchen. All rights reserved.
//

#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>

using namespace cv;
using namespace std;

Mat centerPrior(Mat& img)
{
    Mat centerMap;
    int sigmaD = 150*150;
    Mat coordinateMtx1(img.rows, img.cols, CV_32F, Scalar(0,0,0));
    Mat coordinateMtx2(img.rows, img.cols, CV_32F, Scalar(0,0,0));
    for (int i=0; i<img.cols; i++) {
        for (int j=0; j<img.rows; j++) {
            coordinateMtx1.at<float>(j, i)=j+1;
        }
    }
    for (int i=0; i<img.rows; i++) {
        for (int j=0; j<img.cols; j++) {
            coordinateMtx2.at<float>(i,j)=j+1;
        }
    }
    int centerX=img.rows/2;
    int centerY=img.cols/2;
    Mat centerXMtx=Mat::ones(img.rows, img.cols, CV_32F)*centerX;
    Mat centerYMtx=Mat::ones(img.rows, img.cols, CV_32F)*centerY;
    Mat sumMtx1=(coordinateMtx1-centerXMtx);
    Mat sumMtx2=(coordinateMtx2-centerYMtx);
    
    
    exp(-(sumMtx1.mul(sumMtx1)+sumMtx2.mul(sumMtx2))/sigmaD, centerMap);
    imshow("center-prior", centerMap);
    waitKey();
    imwrite("/Users/wangruchen/work/class/Lecture2-Saliency/Lecture2-assignment/saliency/pic/center-prior.png", centerMap);
    return centerMap;
}