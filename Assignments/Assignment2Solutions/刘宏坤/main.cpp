#include <cstdlib>
#include <cstdio>
#include <opencv2/opencv.hpp> 
#include <opencv2/core/core.hpp>

#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include <opencv2/imgproc/types_c.h> 
#include <opencv2/nonfree/features2d.hpp>

using namespace std;
using namespace cv;



int main(int argc, char** argv)
{
	if(argc!=3)
	{
		printf("error");
		exit(-1);

	}
	Mat ObjectImage,SceneImage,ObjectImageGray,SceneImageGray;
	ObjectImage=imread(argv[1]);
	SceneImage=imread(argv[2]);
	cv::imshow("Object Original Image",ObjectImage);
	cv::imshow("Scene Original Image",SceneImage);
    
    ////////////////////step2/////////////////////////////////////////////////////////////////
	cvtColor(ObjectImage,ObjectImageGray,COLOR_BGR2GRAY);
	cvtColor(SceneImage,SceneImageGray,COLOR_BGR2GRAY);
	cv::imshow("Object Gray Image",ObjectImageGray);
	cv::imshow("Scene Gray Image",SceneImageGray);
	
	///////////////////step3/////////////////////////////////////////////////////////////////////
	int minHessian = 400;
    SurfFeatureDetector detector( minHessian );
    std::vector<KeyPoint> keypoints_object, keypoints_scene;
    Mat ObejectImageKP,SceneImageKP;//����������йؼ����object image��scene image
 
	detector.detect( ObjectImageGray, keypoints_object );//����object image�еĹؼ���
    detector.detect(SceneImageGray, keypoints_scene );//����scene image�еĹؼ���

  drawKeypoints(ObjectImageGray,keypoints_object,ObejectImageKP,Scalar::all(-1),DrawMatchesFlags::DEFAULT);
  drawKeypoints(SceneImageGray,keypoints_scene,SceneImageKP,Scalar::all(-1) ,DrawMatchesFlags::DEFAULT);
  cv::imshow("Object Image With Keypoint",ObejectImageKP);
  cv::imshow("Scene Image With Keypoint",SceneImageKP);
  /////////////////////step4//////////////////////////////////////////////////////////////
 Mat descriptors_object, descriptors_scene;
  SurfDescriptorExtractor extractor;

  extractor.compute(ObjectImageGray, keypoints_object, descriptors_object );//���ؼ����vector����ת����Mat����
  extractor.compute(SceneImageGray, keypoints_scene, descriptors_scene );//���ؼ����vector����ת����Mat����
  //imshow("test1",descriptors_object);
  //imshow("test2",descriptors_scene);
  /////////////////////step5///////////////////////////////////////////////////////////////////
  FlannBasedMatcher matcher;  
  vector< DMatch > matches;  

  matcher.match( descriptors_object, descriptors_scene, matches );  //�����object image��scene image֮���ƥ���

  double distance_min = 100;
  double distance_max=0;
  vector< DMatch > good_matches;
 

  for( int i = 0; i < descriptors_object.rows; i++ )
  { 
	double dist = matches[i].distance;
    if( dist < distance_min ) distance_min = dist;
	if(dist>distance_max)  distance_max=dist;
  }//�ҵ���С����


  for( int i = 0; i < descriptors_object.rows; i++ )
  {
	  if( matches[i].distance < 3*distance_min )
     { good_matches.push_back( matches[i]); }
  }//�������С��3������С���룬�ͱ���Ϊgood matches

  Mat img_matches;
  drawMatches( ObjectImageGray, keypoints_object, SceneImageGray, keypoints_scene,
               good_matches, img_matches, Scalar::all(-1), Scalar::all(-1),
               vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
  
 /////////////////////////step6////////////////////////////////////////////////////////////////////////////////////// 
  std::vector<Point2f> obj;
  std::vector<Point2f> scene;

  for( int i = 0; i < good_matches.size(); i++ )
  {
    //-- Get the keypoints from the good matches
    obj.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );//?????????????????
    scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );//????????????????
  }
//
  Mat H = findHomography( obj, scene, CV_RANSAC );//����object��scene֮��ĵ�Ӧ�Ծ���
  ///////////////////////step7///////////////////////////////////////////////
  std::vector<Point2f> obj_corners(4);
  obj_corners[0] = cvPoint(0,0); 
  obj_corners[1] = cvPoint( ObjectImageGray.cols, 0 );
  obj_corners[2] = cvPoint( ObjectImageGray.cols, ObjectImageGray.rows ); 
  obj_corners[3] = cvPoint( 0, ObjectImageGray.rows );
    
   std::vector<Point2f> scene_corners(4);

  perspectiveTransform( obj_corners, scene_corners, H);//���ݵ�Ӧ�Ա任�����object corners���scene corners
  imshow("Good matches",img_matches);
  ///////////////////////////////////////////step8//////////////////////////////////////////////////////////////////
  line( img_matches, scene_corners[0] + Point2f( ObjectImageGray.cols, 0), scene_corners[1] + Point2f( ObjectImageGray.cols, 0), Scalar(0, 255, 0), 4 );
  line( img_matches, scene_corners[1] + Point2f( ObjectImageGray.cols, 0), scene_corners[2] + Point2f( ObjectImageGray.cols, 0), Scalar( 0, 255, 0), 4 );
  line( img_matches, scene_corners[2] + Point2f(ObjectImageGray.cols, 0), scene_corners[3] + Point2f( ObjectImageGray.cols, 0), Scalar( 0, 255, 0), 4 );
  line( img_matches, scene_corners[3] + Point2f(ObjectImageGray.cols, 0), scene_corners[0] + Point2f( ObjectImageGray.cols, 0), Scalar( 0, 255, 0), 4 );
  imshow( "Good matches with lines", img_matches );
 
  waitKey(0);
 for(int i=0;i<good_matches.size();i++)
	  cout<<good_matches[i].distance<<endl;
   


}