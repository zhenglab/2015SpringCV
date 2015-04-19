//
//  quantize.cpp
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

Mat quantize(Mat& img)
{
    Mat quaMatrix;
    //    int imgRows=img.rows;
    //    int imgCols=img.cols * img.channels();;
    //    int qua=16;
    //    for (int x=0; x<imgRows; x++) {
    //        uchar* eachRow=img.ptr<uchar>(x);
    //        for (int y=0; y<imgCols; y++) {
    //            eachRow[y]=eachRow[y]/qua*qua+qua/2;
    //        }
    //    }
    //    imshow("quantize", img);
    //    waitKey();
    //    imwrite("/Users/wangruchen/work/class/Lecture2-Saliency/Lecture2-assignment/saliency/pic/quantize-image.png", img);
    int imgBins[]={8,8,8};
    vector<Mat> solitChannel(img.channels());
    split(img, solitChannel);
    
    solitChannel[0].convertTo(solitChannel[0], CV_32F);//类型转换为float
    solitChannel[1].convertTo(solitChannel[1], CV_32F);
    solitChannel[2].convertTo(solitChannel[2], CV_32F);
    
    quaMatrix=(solitChannel[0]/imgBins[0])*32*32+(solitChannel[1]/imgBins[1])*32+solitChannel[2]/imgBins[2];
    Mat normQuaMatrix;
    normalize(quaMatrix, normQuaMatrix, 255, NORM_MINMAX);
    imshow("qua", normQuaMatrix);
    waitKey();
    imwrite("/Users/wangruchen/work/class/Lecture2-Saliency/Lecture2-assignment/saliency/pic/quantize.png", normQuaMatrix);
    return quaMatrix;
}
