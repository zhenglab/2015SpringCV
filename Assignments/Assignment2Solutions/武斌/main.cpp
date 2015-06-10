/*
 * main.cpp
 * opencv-ObjectDection
 * Created by wubin on 15/4/30.
 * Copyright (c) 2015年 wubin. All rights reserved.
 * Reference Websites:
 * 1.http://blog.csdn.net/xiaowei_cqu/article/details/26478135
 * 2.http://www.opencv.org.cn/opencvdoc/2.3.2/html/modules/features2d/doc/common_interfaces_of_descriptor_matchers.html
 * 3.http://www.opencv.org.cn/opencvdoc/2.3.2/html/_sources/doc/tutorials/features2d/feature_homography/feature_homography.txt
 * 4.http://docs.opencv.org/doc/tutorials/features2d/feature_homography/feature_homography.html
 */

#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/calib3d.hpp>
#include <opencv2/features2d.hpp>
#include <opencv2/xfeatures2d.hpp>
#include <math.h>

using namespace cv;
using namespace std;
using namespace cv::xfeatures2d;

/* Main Funciton */
int main( int argc, char** argv )
{
    /* Step 1: Input image 
     * 利用imread函数，读入图像
     */
    Mat img_object_raw = imread( "images/object.png");
    Mat img_scene_raw = imread( "images/scene.png");
    
    if( !img_object_raw.data || !img_scene_raw.data )
    { cout<< " --(!) Error reading images " << endl; return -1; }
    
    imshow("object",img_object_raw);
    imshow("scene",img_scene_raw);
    waitKey();
    
    /* Step 2: Color space conversion 
     * 利用cvtColor函数，将彩色图像转换为灰度图像
     * Usage：cvtColor(InputArray src, OutputArray dst, int code, int dstCn=0 )
     * DocPages: http://docs.opencv.org/modules/imgproc/doc/miscellaneous_transformations.html
     */
    Mat img_object_gray,img_scene_gray;
    cvtColor(img_object_raw, img_object_gray, COLOR_BGR2GRAY);
    cvtColor(img_scene_raw, img_scene_gray, COLOR_BGR2GRAY);
    
    imshow("object_gray",img_object_gray);
    imshow("scene_gray",img_scene_gray);
    waitKey();
    
    /* Step 3: Features2D detection 
     * 利用特征点检测函数Features2D对灰度图进行特征点检测
     * Usage&Docpages: http://docs.opencv.org/doc/user_guide/ug_features2d.html
     * 特征点检测的算法主要有SIFT和SURF，本程序使用的是SIFT:
     * http://docs.opencv.org/modules/nonfree/doc/feature_detection.html
     */
    int minHessian = 400;
    //接受的关键点的阈值，http://www.4byte.cn/question/625574/whats-the-meaning-of-minhessian-surffeaturedetector.html
    Ptr<SIFT> sift=SIFT::create (minHessian);
    vector<KeyPoint> keypoints_object, keypoints_scene;
    sift->detect( img_object_gray, keypoints_object );
    sift->detect( img_scene_gray, keypoints_scene );
    
    //Draw keypoints
    Mat img_keypoints_object; Mat img_keypoints_scene;
    drawKeypoints( img_object_gray, keypoints_object, img_keypoints_object, Scalar::all(-1), DrawMatchesFlags::DEFAULT );
    drawKeypoints( img_scene_gray, keypoints_scene, img_keypoints_scene, Scalar::all(-1), DrawMatchesFlags::DEFAULT );
    
    //Show detected (drawn) keypoints
    imshow("Keypoints_object", img_keypoints_object);
    imshow("Keypoints_scene", img_keypoints_scene);
    waitKey();
    
    /* Step 4: Calculate descriptors (feature vectors)
     * 利用SIFT算法计算描述子
     */
    Mat descriptors_object, descriptors_scene;
    sift->compute( img_object_gray, keypoints_object, descriptors_object );
    sift->compute( img_scene_gray, keypoints_scene, descriptors_scene );
    
    /* Step 5: Matching descriptor vectors using FLANN matcher
     * 使用FLANN函数进行特征点匹配(代码基本参考OpenCV例子)
     * Usage: http://docs.opencv.org/2.4.9/modules/flann/doc/flann_fast_approximate_nearest_neighbor_search.html
     * Docpages: http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/features2d/feature_flann_matcher/feature_flann_matcher.html
     */
    FlannBasedMatcher matcher;
    vector<DMatch> matches;
    matcher.match(descriptors_object, descriptors_scene, matches);//调用函数进行匹配
    // 设置最大和最小距离
    double max_dist = 0;
    double min_dist = 100;
    
    // Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors_object.rows; i++ )
    {
        double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    printf("-- Max dist : %f \n", max_dist );
    printf("-- Min dist : %f \n", min_dist );
    
    // Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
    vector<DMatch> good_matches;
    
    for( int i = 0; i < descriptors_object.rows; i++ )
    {
        if( matches[i].distance < 3*min_dist )
        {
            good_matches.push_back( matches[i]);
        }
    }
    
    Mat img_matches;
    drawMatches( img_object_gray, keypoints_object, img_scene_gray, keypoints_scene,
                good_matches, img_matches, Scalar::all(-1), Scalar::all(-1),
                vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    
    imshow("Good_matches", img_matches );
    waitKey(0);
    
    // Localize the object
    vector<Point2f> object;
    vector<Point2f> scene;
    
    for(int i = 0; i < good_matches.size(); i++)
    {
        // Get the keypoints from the good matches
        object.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );//queryIdx对应的查询图像的特征描述子索引
        scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );//trainIdx对应的训练图像的特征描述子索引
    }
    
    /* Step 6: Find homography transformation
     * 利用findHomography函数在两个平面之间寻找单映射变换矩阵
     * UsagePage1:http://blog.csdn.net/chenjiazhou12/article/details/22825487
     * UsagePage2:http://blog.163.com/jinlong_zhou_cool/blog/static/2251150732014034425339/
     * Docpage:http://docs.opencv.org/doc/tutorials/features2d/feature_homography/feature_homography.html
     */
    Mat homography_transformation = findHomography( object, scene, RANSAC );
    for(int i = 0; i < homography_transformation.rows; i++)
    {
        for(int j = 0;j <homography_transformation.cols;j++)
        {
            printf("%d ", homography_transformation.at<uchar>(i,j) );
        }
        printf("/n");
    }
    
    // Get the corners from the image
    vector<Point2f> object_corners(4);
    object_corners[0] = Point2f(0,0);
    object_corners[1] = Point2f(img_object_gray.cols, 0);
    object_corners[2] = Point2f(img_object_gray.cols, img_object_gray.rows);
    object_corners[3] = Point2f(0, img_object_gray.rows );
    vector<Point2f> scene_corners(4);
    
    /* Step 7: Perspective transform
     * 利用perspectiveTransform函数来映射点
     * Docpage1:http://docs.opencv.org/modules/imgproc/doc/geometric_transformations.html
     * Docpage2:http://opencvexamples.blogspot.com/2014/01/perspective-transform.html
     * 利用circle函数画圆
     * Docpage3:http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/core/basic_geometric_drawing/basic_geometric_drawing.html
     */
    perspectiveTransform( object_corners, scene_corners, homography_transformation);
    
    circle(img_matches,scene_corners[0] + Point2f( img_object_gray.cols, 0),3,Scalar(0, 0, 255),1,LINE_8,0);
    circle(img_matches,scene_corners[1] + Point2f( img_object_gray.cols, 0),3,Scalar(0, 0, 255),1,LINE_8,0);
    circle(img_matches,scene_corners[2] + Point2f( img_object_gray.cols, 0),3,Scalar(0, 0, 255),1,LINE_8,0);
    circle(img_matches,scene_corners[3] + Point2f( img_object_gray.cols, 0),3,Scalar(0, 0, 255),1,LINE_8,0);
    imshow( "PerspectiveTransform", img_matches );
    waitKey(0);
    
    /* Step 8: Localize the object
     * 使用line函数画线
     * Docpage1:http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/core/basic_geometric_drawing/basic_geometric_drawing.html
     */
    line( img_matches, scene_corners[0] + Point2f( img_object_gray.cols, 0), scene_corners[1] + Point2f( img_object_gray.cols, 0), Scalar(0, 255, 0), 4 );
    line( img_matches, scene_corners[1] + Point2f( img_object_gray.cols, 0), scene_corners[2] + Point2f( img_object_gray.cols, 0), Scalar( 0, 255, 0), 4 );
    line( img_matches, scene_corners[2] + Point2f( img_object_gray.cols, 0), scene_corners[3] + Point2f( img_object_gray.cols, 0), Scalar( 0, 255, 0), 4 );
    line( img_matches, scene_corners[3] + Point2f( img_object_gray.cols, 0), scene_corners[0] + Point2f( img_object_gray.cols, 0), Scalar( 0, 255, 0), 4 );
    
    // Show detected matches
    imshow( "Good Matches & Object detection", img_matches );
    imwrite("Object_detection.png" , img_matches );
    waitKey(0);
    return 0;
}
