//
//  contrast.cpp
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

Mat contrast(Mat& img, Mat& superpixelLabel, vector<Mat>& histEachSuperpixel, int numSuperpixel)
{
    Mat saliencyVal=Mat::zeros(img.rows, img.cols, CV_8U);
    Mat valMatrix(numSuperpixel,1,CV_32F);
    for (int i=0 ; i<numSuperpixel; i++) {
        float valHist=0;
        for (int j=0; j<numSuperpixel; j++) {
            valHist=valHist+compareHist(histEachSuperpixel[i], histEachSuperpixel[j], HISTCMP_CHISQR_ALT);
        }
        valMatrix.at<float>(i,0)=valHist/numSuperpixel;//每一个超像素块与全局的距离
    }
    normalize(valMatrix, valMatrix, 255, 0, NORM_MINMAX);
    for (int i=0; i<img.rows; i++) {
        for (int j=0; j<img.cols; j++) {
            for (int m=0; m<numSuperpixel; m++) {
                if (superpixelLabel.at<int>(i,j)==m) {
                    saliencyVal.at<uchar>(i, j)=valMatrix.at<float>(m,0);//将距离赋个每一个像素
                    break;
                }
            }
        }
    }
    imshow("initSaliency", saliencyVal);
    waitKey();
    imwrite("/Users/wangruchen/work/class/Lecture2-Saliency/Lecture2-assignment/saliency/pic/initSaliency.png", saliencyVal);
    return saliencyVal;
}