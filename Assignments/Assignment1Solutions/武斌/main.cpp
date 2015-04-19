//
//  main.cpp
//  opencv
//
//  Created by wubin on 15/4/10.
//  Copyright (c) 2015年 wubin. All rights reserved.
//

#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/ximgproc.hpp>
#include <math.h>

using namespace cv;
using namespace std;

//程序主函数
int main(int argc, const char * argv[]){
    
    //读取图像并且另存为新的图像
    Mat raw_img=imread("images/test.jpg",1);
    imshow("rawimg", raw_img);
    //imwrite("/Users/wubin/Workspace/Project/Xcode_project/saliency_wb_zhw/images/rawimg.png", raw_img);
    waitKey();
    
    //**对输入图像进行颜色特征提取
    Mat convertpixel_img=raw_img.clone(); //复制图像
    Mat convertchannel_img=raw_img.clone();
    Mat convert_pixel(raw_img.rows,raw_img.cols,CV_32F); //数据声明，CV_32F表示32位float型
    Mat convert_channel(raw_img.rows,raw_img.cols,CV_8UC1);
    //函数声明
    Mat ConvertChannel(Mat& img);
    //函数调用
    convert_channel=ConvertChannel(convertchannel_img);//获得灰度图
    
    //**超像素分割
    Mat superpixel_img=raw_img.clone();
    Mat superpixel_label;
    int SuperPixelSegmentation(Mat& superpixel_img, Mat& superpixel_label);
    int superpixel_number=SuperPixelSegmentation(superpixel_img, superpixel_label);//得到超像素分割的块数
    cout << superpixel_number;
    
    //**计算每个超像素的颜色直方图
    vector<Mat> PerPixelHist(superpixel_number);
    int hist_size=2048;//份数，根据效果进行调整
    float range[]={0,2048};
    const float* hist_ranges={range};
    int channel=0;
    
    for(int m=0;m<superpixel_number;m++)
    {
        Mat perpixelhist=Mat::zeros(2000,1,CV_32F);
        int num=0;
        for(int i=0;i<raw_img.rows;i++)
            for(int j=0;j<raw_img.cols;j++)
                if(superpixel_label.at<int>(i,j)==m)
                {
                    perpixelhist.at<float>(num,0)=convert_channel.at<float>(i,j);//将属于同一个超像素块的所有像素的像素值赋值到一个矩阵中
                    num++;
                }
        perpixelhist.resize(num);//去掉空数据
        calcHist (&perpixelhist,1,&channel,Mat(),PerPixelHist[m],1,&hist_size,&hist_ranges);//计算每一个超像素块的直方图
        normalize(PerPixelHist[m], PerPixelHist[m],1, NORM_MINMAX);//归一化
    }
    
    //**超像素直方图对比
    Mat ContrastSaliency(Mat& img,Mat& superpixel_label,vector<Mat>& PerPixelHist,int superpixel_number);
    Mat saliency_value=ContrastSaliency(raw_img,superpixel_label,PerPixelHist,superpixel_number);
    
    
    ///制作中心先验显著图
    Mat CenterPrior(Mat& img);
    Mat center_map=CenterPrior(raw_img);
    
    
    ///使用中心先验显著图增强显著效果
    saliency_value.convertTo(saliency_value,CV_32F);
    Mat finalsaliency(raw_img.rows,raw_img.cols,CV_32F);
    finalsaliency=saliency_value.mul(center_map);//中心先验显著图乘最初显著图得到最终显著图
    finalsaliency.convertTo(finalsaliency,CV_8U);
    
    imshow("saliency", finalsaliency);
    imwrite("images/saliency.png", finalsaliency);
    waitKey();
}


