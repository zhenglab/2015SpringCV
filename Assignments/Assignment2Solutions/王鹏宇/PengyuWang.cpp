#include<stdio.h>
#include<iostream>
#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/calib3d/calib3d.hpp>
#include<opencv2/nonfree/nonfree.hpp>
#include<opencv2/nonfree/features2d.hpp>

using namespace std;
using namespace cv;

int main(int argc,char** argv)
{
	//step1 input image
	if(argc>3)
	{
		cout<<"Usage: ./SURF_descriptor <img1> <img2>"<<endl;
		return -1;
	}
	if(argc<3)
	{
		argv[1]="E:/object.jpg";
		argv[2]="E:/scene.jpg";
	}


	//step2 colorspace conversion
	Mat object,scene;
	object=imread(argv[1],0);
	scene=imread(argv[2],0);

	if(!object.data||!scene.data)
	{
		cout<<"Error reading images."<<endl;
		return -1;
	}


	//step3 features2d detection
	int minHessian=380;                                             //设置参数
	SurfFeatureDetector detector(minHessian);                       //使用surf算法提取特征点，并将结果分别存入keyp_object,keyp_scene中
	vector<KeyPoint>keyp_object,keyp_scene;
	detector.detect(object,keyp_object);
	detector.detect(scene,keyp_scene);


	//step4 calculate descriptors
	SurfDescriptorExtractor extractor;                             //利用上一步提取的特征点，使用surf算法计算生成特征描述子，并将结果分别存入des_object，des_scene中
	Mat des_object,des_scene;
	extractor.compute(object,keyp_object,des_object);
	extractor.compute(scene,keyp_scene,des_scene);

	//step5 match descriptors
	//step5.1
	BFMatcher matcher;                                            //利用上一步生成的特征描述子，利用暴力匹配方法进行特征点匹配,并算出各特征点之间的距离
	vector<DMatch>matches;
	matcher.match(des_object,des_scene,matches);
	//step5.2
	double mindis=1000,maxdis=0;                                  //找到特征点间的最大距离和最小距离并显示
	for(int i=0;i<des_object.rows;i++)
	{
		double dist=matches[i].distance;
		if(dist<mindis)
			mindis=dist;
		else if(dist>maxdis)
			maxdis=dist;
	}
	printf("-- Max dist : %f \n", maxdis );
    printf("-- Min dist : %f \n", mindis );
	//step5.3
	vector<DMatch>goodmatches;                                    //找到距离小于3倍最小距离的特征点对，并将该匹配存入goodmatches中
	for(int i=0;i<des_object.rows;i++)
	{
		if(matches[i].distance<3*mindis)
		{
			goodmatches.push_back(matches[i]);
		}
	}
	
	Mat matchimage;
	drawMatches(object,keyp_object,scene,keyp_scene,goodmatches,matchimage,Scalar::all(-1),
				Scalar::all(-1),vector<char>(),DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);
	imwrite("matchimage.jpg",matchimage);

	//step6 find homography transformation
	vector<Point2f>pointf_object,pointf_scene;
	for(int i=0;i<goodmatches.size();i++)                            //从goodmatches中取出小于3倍最小距离的特征点对，并分别存入pointf_object和pointf_scene中
	{
		pointf_object.push_back(keyp_object[goodmatches[i].queryIdx].pt);
		pointf_scene.push_back(keyp_scene[goodmatches[i].trainIdx].pt);
	}
	 
	Mat H=findHomography(pointf_object,pointf_scene,CV_RANSAC);     //使用基于随机采样一致性算法，找到单应行变换矩阵，并存入H中
	vector<Point2f>corner_object(4),corner_scene(4);
	corner_object[0]=cvPoint(0,0);                                  //取出物体图像的四个角点，并存入corner_object中
	corner_object[1]=cvPoint(object.cols,0);
	corner_object[2]=cvPoint(object.cols,object.rows);
	corner_object[3]=cvPoint(0,object.rows);

	//step7 perspective transform
	perspectiveTransform(corner_object,corner_scene,H);          //使用上步得到的单应行变换矩阵和物体图像的四个角点，找到场景图像中的对应角点，
																 //并存入corner_scene中

	//step8 localize the object
	line(matchimage,corner_scene[0]+Point2f(object.cols,0),corner_scene[1]+Point2f(object.cols,0),Scalar(0,0,255),4);    //根据上步得到的四个角点在匹配图中的
	line(matchimage,corner_scene[1]+Point2f(object.cols,0),corner_scene[2]+Point2f(object.cols,0),Scalar(0,0,255),4);    //场景图中连线，框出要匹配的物体
	line(matchimage,corner_scene[2]+Point2f(object.cols,0),corner_scene[3]+Point2f(object.cols,0),Scalar(0,0,255),4);
	line(matchimage,corner_scene[3]+Point2f(object.cols,0),corner_scene[0]+Point2f(object.cols,0),Scalar(0,0,255),4);

	//显示图像
	 imshow( "Good Matches & Object detection", matchimage );
	 imwrite("finalmatchimage.jpg",matchimage);
	waitKey(0);
	return 0;
}