#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/calib3d.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/features2d.hpp>
#include <opencv2/xfeatures2d.hpp>
#include <opencv2/xfeatures2d/nonfree.hpp>
#include <math.h>

using namespace cv;
using namespace std;
using namespace cv::xfeatures2d;

int main( int argc, char** argv )
{


  //**Step 1: 输入图像**
  Mat i_ob = imread( "object.png");//读入图像
  Mat i_sc = imread( "scene.png");

   imshow("目标图像",i_ob);//显示图像
   imshow("场景图像",i_sc);
   waitKey();




  //**Step 2: 色度空间转换**
  cvtColor(i_ob, i_ob, COLOR_BGR2GRAY);//灰度变换
  cvtColor(i_sc , i_sc , COLOR_BGR2GRAY);

  imshow("目标图像灰度图",i_ob);
  imshow("场景图像灰度图",i_sc);
  waitKey();




  //**Step 3: 2D特征检测**
  Ptr<SURF> surf=SURF::create (400);

  vector<KeyPoint> keypoints_ob, keypoints_sc;

  surf->detect( i_ob, keypoints_ob );//调用surf算法
  surf->detect( i_sc, keypoints_sc );

  //描述显示 关键点
  Mat i_keypoints_1; Mat i_keypoints_2;//定义关键点

  drawKeypoints( i_ob, keypoints_ob, i_keypoints_1, Scalar::all(-1), DrawMatchesFlags::DEFAULT );
  drawKeypoints( i_sc, keypoints_sc, i_keypoints_2, Scalar::all(-1), DrawMatchesFlags::DEFAULT );

  //展示描述的关键点图像
  imshow("关键点图像1", i_keypoints_1 );
  imshow("关键点图像2", i_keypoints_2 );
  waitKey();




  //**Step 4: 计算描述子 (特征向量)**
  Mat descriptors_ob, descriptors_sc;//定义描述子

  surf->compute( i_ob, keypoints_ob, descriptors_ob );
  surf->compute( i_sc, keypoints_sc, descriptors_sc );




  //**Step 5: 匹配描述子（特征向量）**
  FlannBasedMatcher matcher;
  std::vector< DMatch > matches;
  matcher.match( descriptors_ob, descriptors_sc, matches );

  double max_dist = 0; double min_dist = 100;

  //快速计算关键点距离的最大最小值
  for( int i = 0; i < descriptors_ob.rows; i++ )
  { double dist = matches[i].distance;
    if( dist < min_dist ) min_dist = dist;
    if( dist > max_dist ) max_dist = dist;
  }
  //若两个特征向量之间的欧氏距离越小，表明匹配度越高。

  printf("最大距离 : %f \n", max_dist );
  printf("最小距离 : %f \n", min_dist );

  //只显示好的匹配 即距离小于3倍min_dist的点
  std::vector< DMatch > good_matches;

  for( int i = 0; i < descriptors_ob.rows; i++ )
  {
     if( matches[i].distance < 3*min_dist )
     {
     good_matches.push_back( matches[i]);
     }
  }

  Mat i_matches;
  drawMatches( i_ob, keypoints_ob, i_sc, keypoints_sc,
               good_matches, i_matches, Scalar::all(-1), Scalar::all(-1),
               vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );

  imshow("筛选后的匹配图", i_matches );
  waitKey(0);

  // 区域化目标
  std::vector<Point2f> obj;
  std::vector<Point2f> scene;

  for( int i = 0; i < good_matches.size(); i++ )
  {
  //从筛选后的匹配图挑选关键点
    obj.push_back( keypoints_ob[ good_matches[i].queryIdx ].pt );
    scene.push_back( keypoints_sc[ good_matches[i].trainIdx ].pt );
              ///intqueryIdx:此匹配对应的查询图像的特征描述子索引
              ///inttrainIdx:此匹配对应的训练(模板)图像的特征描述子索引
  }




  //**Step 6:  homography 变换**
  Mat H = findHomography( obj, scene, RANSAC );
  for(int i = 0; i < H.rows; i++)
          {
          for(int j = 0;j <H.cols;j++)
                   {
                    printf("%d ", H.at<uchar>(i,j) );
                   }
          printf("/n");
           }

  //从第一幅图中找到边角 ( the object to be "detected" )
  std::vector<Point2f> obj_corners(4);
  obj_corners[0] = Point2f(0,0); obj_corners[1] = Point2f( i_ob.cols, 0 );
  obj_corners[2] = Point2f( i_ob.cols, i_ob.rows ); obj_corners[3] = Point2f( 0, i_ob.rows );
  std::vector<Point2f> scene_corners(4);




  //**Step 7: Perspective transform**
  perspectiveTransform( obj_corners, scene_corners, H);

  circle(i_matches,scene_corners[0] + Point2f( i_ob.cols, 0),3,Scalar(0, 0, 255),1,LINE_8,0);
  circle(i_matches,scene_corners[1] + Point2f( i_ob.cols, 0),3,Scalar(0, 0, 255),1,LINE_8,0);
  circle(i_matches,scene_corners[2] + Point2f( i_ob.cols, 0),3,Scalar(0, 0, 255),1,LINE_8,0);
  circle(i_matches,scene_corners[3] + Point2f( i_ob.cols, 0),3,Scalar(0, 0, 255),1,LINE_8,0);
  imshow( "PerspectiveTransform", i_matches );
  waitKey(0);
 // circle(InputOutputArray img, Point center, int radius,const Scalar& color, int thickness = 1,int lineType = LINE_8, int shift = 0);




  //**Step 8: Localize the object**
  line( i_matches, scene_corners[0] + Point2f( i_ob.cols, 0), scene_corners[1] + Point2f( i_ob.cols, 0), Scalar(0, 255, 0), 4 );
  line( i_matches, scene_corners[1] + Point2f( i_ob.cols, 0), scene_corners[2] + Point2f( i_ob.cols, 0), Scalar( 0, 255, 0), 4 );
  line( i_matches, scene_corners[2] + Point2f( i_ob.cols, 0), scene_corners[3] + Point2f( i_ob.cols, 0), Scalar( 0, 255, 0), 4 );
  line( i_matches, scene_corners[3] + Point2f( i_ob.cols, 0), scene_corners[0] + Point2f( i_ob.cols, 0), Scalar( 0, 255, 0), 4 );

  ///-- Show detected matches
  imshow( "筛选后匹配结果 & 目标检测", i_matches );
  imwrite("目标检测.png" , i_matches );

  waitKey(0);
  return 0;
  }
