//
//  ContrastSaliency.cpp
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


//定义子函数－对不同超像素块的颜色直方图之间进行距离计算，并转换为像素级的距离图，即为初始显著图
Mat ContrastSaliency(Mat& img,Mat& superpixel_label,vector<Mat>& PerPixelHist,int superpixel_number){
    Mat saliency_value=Mat::zeros(img.rows,img.cols,CV_8U);//全0矩阵
    Mat matrix_value(superpixel_number,1,CV_32F);//定义一组临时向量
    int i,j;
    for(i=0;i<superpixel_number;i++)
    {
        float hist_value=0;
        for(j=0;j<superpixel_number;j++)
        {
            hist_value=hist_value+compareHist(PerPixelHist[i],PerPixelHist[j],HISTCMP_CHISQR_ALT);//每一个像素块同其他像素块之间的距离作和
        }
        matrix_value.at<float>(i,0)=hist_value/superpixel_number;//像素块同所有其他像素块的距离的和取平均，表示当前块的像素值
    }
    
    normalize(matrix_value, matrix_value, 255, 0, NORM_MINMAX);//归一化
    
    for (int i=0; i<img.rows; i++){
        for (int j=0; j<img.cols; j++){
            for (int m=0; m<superpixel_number; m++){
                if (superpixel_label.at<int>(i,j)==m){
                    saliency_value.at<uchar>(i, j)=matrix_value.at<float>(m,0);//将上述获得的像素值赋值给每一个超像素块内的像素
                }
            }
        }
        
    }
    imshow("ContrastSaliency_img", saliency_value);
    imwrite("images/ContrastSaliencyImg.png", saliency_value);
    waitKey();
    return saliency_value;
}