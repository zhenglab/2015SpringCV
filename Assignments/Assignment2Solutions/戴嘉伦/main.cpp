#include <stdio.h>
#include <iostream>
#include <core.hpp>
#include <features2d/features2d.hpp>
#include <xfeatures2d.hpp>
#include <highgui.hpp>
#include <cv.hpp>

using namespace cv;
using namespace cv::xfeatures2d;
using namespace std;

void readme();

int main( int argc, char** argv )
{
  if( argc != 3 )
  {
        readme();
        return -1;
  }

  Mat mObj = imread( argv[1],0);
  Mat mScn = imread( argv[2], 0);

  if( !mObj.data || !mScn.data )
  {
        cout<< " --(!) Error reading images " <<endl;
        return -1;
}


  //~~~~~~~~~~~~~~~~~Detect KeyPoints in Object and Scene~~~~~~~~~~~~~~~~~~~~//
  int minHessian = 370;
  Ptr<SURF> surfDetector = SURF::create( minHessian );

  vector<KeyPoint> keypointObj, keypointScn;
  surfDetector-> detect( mObj, keypointObj);
  surfDetector -> detect( mScn, keypointScn);

  Mat mObjKeypoints=mObj.clone();
  Mat mScnKeypoints=mScn.clone();
  drawKeypoints(mObj, keypointObj, mObjKeypoints);
  drawKeypoints(mScn, keypointScn, mScnKeypoints);

  imshow("ObjKeyPoints", mObjKeypoints);
  imshow("ScnKeyPoints", mScnKeypoints);
  waitKey();


  //~~~~~~~~~~~~~~~~~~Describe KeyPoints to Descriptor (Feature Vector)~~~~~~~~~~~~~~~~~~~~~~~~~~~//
 Ptr<SURF> surfExtractor = SURF::create( );

  Mat mDescripObj, mDescripScn;
  surfExtractor->compute( mObj, keypointObj, mDescripObj);
  surfExtractor->compute( mScn, keypointScn, mDescripScn);


  //~~~~~~~~~~~~~~~~~ Match KeyPoints between Object and Scene~~~~~~~~~~~~~~~~~~~//
  FlannBasedMatcher flannMatcher;
  vector< DMatch > dmatchMatches;
  flannMatcher.match( mDescripObj, mDescripScn, dmatchMatches);



  //~~~~~~~~~~~~~~~~~~~Calculate Minimum in All Matches~~~~~~~~~~~~~~~~~~//
  int i=0;
  double dMinDist =  dmatchMatches[0].distance;
  for( i = 1; i < mDescripObj.rows; i++ )
  {
      if( dMinDist < dmatchMatches[i].distance) dMinDist=dmatchMatches[i].distance;
  }


  //~~~~~~~~~~~~~~~~~~ Select Some Good Matches~~~~~~~~~~~~~~~~~~//
 vector< DMatch > dmatchGoodMatches;

  for( i = 0; i < mDescripObj.rows; i++ )
  {
      if( dmatchMatches[i].distance < 2.5*dMinDist )
     {
         dmatchGoodMatches.push_back( dmatchMatches[i]);
     }
  }

//~~~~~~~~~~~~~~~~~~ Draw Lines between Keypoints in Object and Scene~~~~~~~~~~~~~~~~~~//
  Mat mImgMatch;
  drawMatches( mObj, keypointObj, mScn, keypointScn, dmatchGoodMatches, mImgMatch);
  imshow("match",mImgMatch);
  waitKey(0);


    //~~~~~~~~~~~~~~~~~~~Caculate Homography Transform~~~~~~~~~~~~~~~~~~~~~~~~~//
  vector<Point2f> p2fObj;
  vector<Point2f> p2fScn;
  for( int i = 0; i < (int)dmatchGoodMatches.size(); i++ )
  {
    p2fObj.push_back( keypointObj[ dmatchGoodMatches[i].queryIdx ].pt );
    p2fScn.push_back( keypointScn[ dmatchGoodMatches[i].trainIdx ].pt );
  }

  Mat mHomo = findHomography( p2fObj, p2fScn, RANSAC );


  //~~~~~~~~~~~~~~~~~~~~~Perspective Transform~~~~~~~~~~~~~~~~~~~~~~~//
  vector<Point2f> p2fObjCorner(4);
  p2fObjCorner[0] = cvPoint(0,0); p2fObjCorner[1] = cvPoint( mObj.cols, 0 );
  p2fObjCorner[2] = cvPoint( mObj.cols, mObj.rows ); p2fObjCorner[3] = cvPoint( 0, mObj.rows );
  vector<Point2f> p2fScnCorner(4);

  perspectiveTransform( p2fObjCorner, p2fScnCorner, mHomo);

 //~~~~~~~~~~~~~~~~~~~~~Draw Lines in Mapped Object in Scene Image~~~~~~~~~~~~~~~~~~~~~~~//
  line( mImgMatch, p2fScnCorner[0] + Point2f( mObj.cols, 0), p2fScnCorner[1] + Point2f( mObj.cols, 0), Scalar(0, 255, 0), 4 );
  line( mImgMatch, p2fScnCorner[1] + Point2f( mObj.cols, 0), p2fScnCorner[2] + Point2f( mObj.cols, 0), Scalar( 0, 255, 0), 4 );
  line( mImgMatch, p2fScnCorner[2] + Point2f( mObj.cols, 0), p2fScnCorner[3] + Point2f( mObj.cols, 0), Scalar( 0, 255, 0), 4 );
  line( mImgMatch, p2fScnCorner[3] + Point2f( mObj.cols, 0), p2fScnCorner[0] + Point2f( mObj.cols, 0), Scalar( 0, 255, 0), 4 );

  imshow( "Good Matches & Object detection", mImgMatch );
 waitKey(0);
  return 0;
  }

  void readme()
  {
        cout << " Usage: ./SURF_descriptor <img1> <img2>" <<endl;
  }
