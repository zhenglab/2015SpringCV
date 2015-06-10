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
	int minHessian=380;                                             //���ò���
	SurfFeatureDetector detector(minHessian);                       //ʹ��surf�㷨��ȡ�����㣬��������ֱ����keyp_object,keyp_scene��
	vector<KeyPoint>keyp_object,keyp_scene;
	detector.detect(object,keyp_object);
	detector.detect(scene,keyp_scene);


	//step4 calculate descriptors
	SurfDescriptorExtractor extractor;                             //������һ����ȡ�������㣬ʹ��surf�㷨�����������������ӣ���������ֱ����des_object��des_scene��
	Mat des_object,des_scene;
	extractor.compute(object,keyp_object,des_object);
	extractor.compute(scene,keyp_scene,des_scene);

	//step5 match descriptors
	//step5.1
	BFMatcher matcher;                                            //������һ�����ɵ����������ӣ����ñ���ƥ�䷽������������ƥ��,�������������֮��ľ���
	vector<DMatch>matches;
	matcher.match(des_object,des_scene,matches);
	//step5.2
	double mindis=1000,maxdis=0;                                  //�ҵ������������������С���벢��ʾ
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
	vector<DMatch>goodmatches;                                    //�ҵ�����С��3����С�����������ԣ�������ƥ�����goodmatches��
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
	for(int i=0;i<goodmatches.size();i++)                            //��goodmatches��ȡ��С��3����С�����������ԣ����ֱ����pointf_object��pointf_scene��
	{
		pointf_object.push_back(keyp_object[goodmatches[i].queryIdx].pt);
		pointf_scene.push_back(keyp_scene[goodmatches[i].trainIdx].pt);
	}
	 
	Mat H=findHomography(pointf_object,pointf_scene,CV_RANSAC);     //ʹ�û����������һ�����㷨���ҵ���Ӧ�б任���󣬲�����H��
	vector<Point2f>corner_object(4),corner_scene(4);
	corner_object[0]=cvPoint(0,0);                                  //ȡ������ͼ����ĸ��ǵ㣬������corner_object��
	corner_object[1]=cvPoint(object.cols,0);
	corner_object[2]=cvPoint(object.cols,object.rows);
	corner_object[3]=cvPoint(0,object.rows);

	//step7 perspective transform
	perspectiveTransform(corner_object,corner_scene,H);          //ʹ���ϲ��õ��ĵ�Ӧ�б任���������ͼ����ĸ��ǵ㣬�ҵ�����ͼ���еĶ�Ӧ�ǵ㣬
																 //������corner_scene��

	//step8 localize the object
	line(matchimage,corner_scene[0]+Point2f(object.cols,0),corner_scene[1]+Point2f(object.cols,0),Scalar(0,0,255),4);    //�����ϲ��õ����ĸ��ǵ���ƥ��ͼ�е�
	line(matchimage,corner_scene[1]+Point2f(object.cols,0),corner_scene[2]+Point2f(object.cols,0),Scalar(0,0,255),4);    //����ͼ�����ߣ����Ҫƥ�������
	line(matchimage,corner_scene[2]+Point2f(object.cols,0),corner_scene[3]+Point2f(object.cols,0),Scalar(0,0,255),4);
	line(matchimage,corner_scene[3]+Point2f(object.cols,0),corner_scene[0]+Point2f(object.cols,0),Scalar(0,0,255),4);

	//��ʾͼ��
	 imshow( "Good Matches & Object detection", matchimage );
	 imwrite("finalmatchimage.jpg",matchimage);
	waitKey(0);
	return 0;
}