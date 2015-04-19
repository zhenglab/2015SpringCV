//
//  main.cpp
//  opencv
//
//  Created by wangruchen on 15/1/31.
//  Copyright (c) 2015年 wangruchen. All rights reserved.
//

#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/ximgproc.hpp>
#include <math.h>

using namespace cv;
using namespace std;

extern Mat quantize(Mat& img);
extern int superpixel(Mat& outSuperpixel, Mat& superpixelLabel);
vector<Mat> histogram(Mat& img,Mat& superpixelLabel,Mat& quaMatrix, int numSuperpixel);
extern Mat contrast(Mat& img, Mat& superpixelLabel, vector<Mat>& histEachSuperpixel, int numSuperpixel);
extern Mat centerPrior(Mat& img);

int main(int argc, const char * argv[]) {
    Mat img=imread("/Users/wangruchen/work/class/Lecture2-Saliency/Lecture2-assignment/saliency/pic/0_0_280.jpg",1);
    if( !img.data ){
        printf("Error loading img \n");
        return -1;
    }
    imshow("src", img);
    waitKey();
    Mat outSuperpixel=img.clone();
    
/*~~~superpixel~~~*/
    Mat superpixelLabel;
    int numSuperpixel=superpixel(outSuperpixel, superpixelLabel);
    
/*~~~quantize~~~~*/
    Mat quaMatrix(img.rows,img.cols,CV_32F);
    quaMatrix=quantize(img);
    
/*~~~h histogram~~~*/
    vector<Mat> histEachSuperpixel(numSuperpixel);
    histEachSuperpixel=histogram(img, superpixelLabel,quaMatrix, numSuperpixel);
    
/*~~~contrast~~~*/
    Mat saliencyVal=contrast(img,superpixelLabel,histEachSuperpixel,numSuperpixel);

/*~~~prior~~~*/
    Mat centerMap=centerPrior(img);

    saliencyVal.convertTo(saliencyVal, CV_32F);
    Mat finalSaliency(img.rows,img.cols,CV_32F);
    finalSaliency=saliencyVal.mul(centerMap);
    finalSaliency.convertTo(finalSaliency, CV_8U);
    
    imshow("saliency", finalSaliency);
    waitKey();
    imwrite("/Users/wangruchen/work/class/Lecture2-Saliency/Lecture2-assignment/saliency/pic/saliency.png", finalSaliency);
    return 0;
}
