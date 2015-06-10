//
//  main.cpp
//  opencv
//
//  Created by wangruchen on 15/1/31.
//  Copyright (c) 2015年 wangruchen. All rights reserved.
//

#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/calib3d.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/features2d.hpp>
#include <opencv2/xfeatures2d.hpp>
#include <math.h>

using namespace cv;
using namespace std;
using namespace cv::xfeatures2d;

int main(int argc, const char * argv[]) {
    Mat objectImg=imread("object.png");
    Mat sceneImg=imread("scene.png");
    if( !objectImg.data && !sceneImg.data ){
        printf("Error loading img \n");
        return -1;
    }
    
    /*---------------Color space conversion-------------*/
    cvtColor(objectImg, objectImg, COLOR_BGR2GRAY);
    cvtColor(sceneImg, sceneImg, COLOR_BGR2GRAY);
    imshow("objectImg", objectImg);
    imshow("sceneImg", sceneImg);
    waitKey();
    imwrite("objectImg.png", objectImg);
    imwrite("sceneImg.png", sceneImg);
    
    /*--Features2D detection and calculate descriptors--*/
    Ptr<SIFT> sift=SIFT::create (400);//定义SIFT中的hessian阈值特征点检测算子
    vector<KeyPoint> keyPoiObj, keyPoiSce;
    Mat outKeyPoiObj, outKeyPoiSce;
    sift->detectAndCompute(objectImg, Mat(), keyPoiObj, outKeyPoiObj);
    sift->detectAndCompute(sceneImg, Mat(), keyPoiSce, outKeyPoiSce);//得到的keyPoiObj和keyPoiSce中存放了关键点的许多信息；矩阵outKeyPoiObj和outKeyPoiSce中存放了特征向量
    
    Mat objKeypointsImg,sceKeypointsImg;
    drawKeypoints(objectImg, keyPoiObj, objKeypointsImg);
    drawKeypoints(sceneImg, keyPoiSce, sceKeypointsImg);
    imshow("features2DObjectImg", objKeypointsImg);
    waitKey();
    imshow("features2DSceneImg", sceKeypointsImg);
    waitKey();
    
    /*--------Match descriptors:Brute-force match------*/
    BFMatcher matchOut;
    vector<DMatch> match;
    Mat matchImg;
    matchOut.match(outKeyPoiObj, outKeyPoiSce, match);
    drawMatches(objectImg, keyPoiObj, sceneImg, keyPoiSce, match, matchImg);
    imshow("matchImg", matchImg);
    waitKey();
    
    /*-------------------Min distance-----------------*/
    double maxDist=0;
    double minDist=100;
    double dist=0;
    for( int i = 0; i < outKeyPoiObj.rows; i++ )
    {
        dist = match[i].distance;
        if (dist < minDist) {
            minDist = dist;
        }
        else {
            maxDist = dist;
        }
    }
    
    /*-------------------Good match------------------*/
    vector<DMatch> goodMatch;
    for( int i = 0; i < outKeyPoiObj.rows; i++ )
    {
        if( match[i].distance <= 2*minDist )//距离小于3*mindistance
        {
            goodMatch.push_back( match[i]);
        }
    }
    Mat goodMatchImg;
    drawMatches(objectImg, keyPoiObj, sceneImg, keyPoiSce, goodMatch, goodMatchImg);
    imshow("goodMatchImg", goodMatchImg);
    waitKey();
    
    /*-----------Homography transformation-----------*/
    vector<Point2f> objectGoodPoint;
    vector<Point2f> sceneGoodPoint;
    for (int i=0; i<goodMatch.size(); i++) {
        objectGoodPoint.push_back( keyPoiObj [ goodMatch[i].queryIdx ].pt);//queryIdx为DMatch中目标对应的索引
        sceneGoodPoint.push_back(keyPoiSce[goodMatch[i].trainIdx].pt);//trainIdx为DMatch中背景对应的索引
    }
    Mat homgGray=findHomography(objectGoodPoint, sceneGoodPoint, LMEDS);

    /*------------Perspective transform--------------*/
    vector<Point2f> objectCon(4);
    vector<Point2f> sceneCon(4);
    objectCon[0]=Point2f(0,0);
    objectCon[1]=Point2f(objectImg.cols,0);
    objectCon[2]=Point2f(objectImg.cols,objectImg.rows);
    objectCon[3]=Point2f(0,objectImg.rows);
    perspectiveTransform(objectCon, sceneCon, homgGray);
    
    /*------------Localize the object----------------*/
    line(goodMatchImg, sceneCon[0] + Point2f( objectImg.cols, 0), sceneCon[1] + Point2f( objectImg.cols, 0), Scalar(0, 255, 0), 4 );
    line(goodMatchImg, sceneCon[1] + Point2f( objectImg.cols, 0), sceneCon[2] + Point2f( objectImg.cols, 0), Scalar(0, 255, 0), 4 );
    line(goodMatchImg, sceneCon[2] + Point2f( objectImg.cols, 0), sceneCon[3] + Point2f( objectImg.cols, 0), Scalar(0, 255, 0), 4 );
    line(goodMatchImg, sceneCon[3] + Point2f( objectImg.cols, 0), sceneCon[0] + Point2f( objectImg.cols, 0), Scalar(0, 255, 0), 4 );
    

    imshow("match", goodMatchImg);
    waitKey();
    imwrite("result.png", goodMatchImg);
    
    return 0;
}
