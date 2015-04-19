//
//  histogram.cpp
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

vector<Mat> histogram(Mat& img,Mat& superpixelLabel,Mat& quaMatrix, int numSuperpixel)
{
    vector<Mat> histEachSuperpixel(numSuperpixel);
    int histSize=1024;//bin的个数
    float range[]={0,1024};
    const float* histRanges={range};
    int channel=0;
    for (int m=0; m<numSuperpixel; m++) {
        Mat eachSuperpixel=Mat::zeros(2000, 1, CV_32F);
        int num=0;
        for (int i=0; i<img.rows; i++) {
            for (int j=0; j<img.cols; j++) {
                if (superpixelLabel.at<int>(i,j)==m) {
                    eachSuperpixel.at<float>(num,0)=quaMatrix.at<float>(i,j);
                    num++;
                }
            }
        }
        eachSuperpixel.resize(num);
        calcHist(&eachSuperpixel, 1, &channel, Mat(), histEachSuperpixel[m], 1, &histSize, &histRanges);//计算每一个超像素块的直方图
        normalize(histEachSuperpixel[m], histEachSuperpixel[m], 1, NORM_MINMAX);//直方图归一化
    }
    return histEachSuperpixel;
}