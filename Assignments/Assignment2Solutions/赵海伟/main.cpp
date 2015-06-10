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

  ///-- Step 1: Input image
  Mat img_object = imread( "object.png");
  Mat img_scene = imread( "scene.png");

  if( !img_object.data || !img_scene.data )
  { std::cout<< " --(!) Error reading images " << std::endl; return -1; }

   imshow("object",img_object);
   imshow("scene",img_scene);
   waitKey();

  ///-- Step 2: Color space conversion
  cvtColor(img_object, img_object, COLOR_BGR2GRAY);
  cvtColor(img_scene , img_scene , COLOR_BGR2GRAY);

  imshow("object_gray",img_object);
  imshow("scene_gray",img_scene);
  waitKey();

  ///-- Step 3: Features2D detection
  int minHessian = 400;
  Ptr<SIFT> sift=SIFT::create (minHessian);

  vector<KeyPoint> keypoints_object, keypoints_scene;

  sift->detect( img_object, keypoints_object );
  sift->detect( img_scene, keypoints_scene );

  ///-- Draw keypoints
  Mat img_keypoints_1; Mat img_keypoints_2;

  drawKeypoints( img_object, keypoints_object, img_keypoints_1, Scalar::all(-1), DrawMatchesFlags::DEFAULT );
  drawKeypoints( img_scene, keypoints_scene, img_keypoints_2, Scalar::all(-1), DrawMatchesFlags::DEFAULT );

  ///-- Show detected (drawn) keypoints
  imshow("Keypoints_object", img_keypoints_1 );
  imshow("Keypoints_scene", img_keypoints_2 );
  waitKey();

  ///-- Step 4: Calculate descriptors (feature vectors)
  Mat descriptors_object, descriptors_scene;

  sift->compute( img_object, keypoints_object, descriptors_object );
  sift->compute( img_scene, keypoints_scene, descriptors_scene );

  ///-- Step 5: Matching descriptor vectors using FLANN matcher
  FlannBasedMatcher matcher;
  std::vector< DMatch > matches;
  matcher.match( descriptors_object, descriptors_scene, matches );

  double max_dist = 0; double min_dist = 100;

  ///-- Quick calculation of max and min distances between keypoints
  for( int i = 0; i < descriptors_object.rows; i++ )
  { double dist = matches[i].distance;
    if( dist < min_dist ) min_dist = dist;
    if( dist > max_dist ) max_dist = dist;
  }
  ///float distance:两个特征向量之间的欧氏距离，越小表明匹配度越高。

  printf("-- Max dist : %f \n", max_dist );
  printf("-- Min dist : %f \n", min_dist );

  ///-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
  std::vector< DMatch > good_matches;

  for( int i = 0; i < descriptors_object.rows; i++ )
  {
     if( matches[i].distance < 3*min_dist )
     {
     good_matches.push_back( matches[i]);
     }
  }

  Mat img_matches;
  drawMatches( img_object, keypoints_object, img_scene, keypoints_scene,
               good_matches, img_matches, Scalar::all(-1), Scalar::all(-1),
               vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );

  imshow("Good_matches", img_matches );
  waitKey(0);

  ///-- Localize the object
  std::vector<Point2f> obj;
  std::vector<Point2f> scene;

  for( int i = 0; i < good_matches.size(); i++ )
  {
  ///-- Get the keypoints from the good matches
    obj.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );
    scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );
              ///intqueryIdx:此匹配对应的查询图像的特征描述子索引
              ///inttrainIdx:此匹配对应的训练(模板)图像的特征描述子索引
  }

  ///-- Step 6: Find homography transformation
  Mat H = findHomography( obj, scene, RANSAC );
  for(int i = 0; i < H.rows; i++)
          {
          for(int j = 0;j <H.cols;j++)
                   {
                    printf("%d ", H.at<uchar>(i,j) );
                   }
          printf("/n");
           }

  ///-- Get the corners from the image_1 ( the object to be "detected" )
  std::vector<Point2f> obj_corners(4);
  obj_corners[0] = Point2f(0,0); obj_corners[1] = Point2f( img_object.cols, 0 );
  obj_corners[2] = Point2f( img_object.cols, img_object.rows ); obj_corners[3] = Point2f( 0, img_object.rows );
  std::vector<Point2f> scene_corners(4);

  ///-- Step 7: Perspective transform
  perspectiveTransform( obj_corners, scene_corners, H);

  circle(img_matches,scene_corners[0] + Point2f( img_object.cols, 0),3,Scalar(0, 0, 255),1,LINE_8,0);
  circle(img_matches,scene_corners[1] + Point2f( img_object.cols, 0),3,Scalar(0, 0, 255),1,LINE_8,0);
  circle(img_matches,scene_corners[2] + Point2f( img_object.cols, 0),3,Scalar(0, 0, 255),1,LINE_8,0);
  circle(img_matches,scene_corners[3] + Point2f( img_object.cols, 0),3,Scalar(0, 0, 255),1,LINE_8,0);
  imshow( "PerspectiveTransform", img_matches );
  waitKey(0);
 // circle(InputOutputArray img, Point center, int radius,const Scalar& color, int thickness = 1,int lineType = LINE_8, int shift = 0);

  ///-- Step 8: Localize the object
  line( img_matches, scene_corners[0] + Point2f( img_object.cols, 0), scene_corners[1] + Point2f( img_object.cols, 0), Scalar(0, 255, 0), 4 );
  line( img_matches, scene_corners[1] + Point2f( img_object.cols, 0), scene_corners[2] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
  line( img_matches, scene_corners[2] + Point2f( img_object.cols, 0), scene_corners[3] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
  line( img_matches, scene_corners[3] + Point2f( img_object.cols, 0), scene_corners[0] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );

  ///-- Show detected matches
  imshow( "Good Matches & Object detection", img_matches );
  imwrite("Object_detection.png" , img_matches );

  waitKey(0);
  return 0;
  }
