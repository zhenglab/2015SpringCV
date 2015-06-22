#include <iostream>
#include<string>
#include<contrib/contrib.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <cv.hpp>


using namespace std;
using namespace cv;



int main()
{
	for(int threshold=2;threshold<8;threshold++)
	{

		Directory directory1,directory2;
		char threch[1];
		itoa(threshold,threch,10);
		string threstring=threch;
		string ori_path="E:\computer_vision\PASCAL"; //原始图像
		string salien_path="E:\computer_vision\saliency_map0."+threstring;//显著性图，二值图
		string exten="*.jpg";
		string extenout=".jpg";
		string output_filename;
		bool addPath1 = true;
		string output_path="E:/output/0."+threstring+"/";
		char numch[1];


		vector<string> ori_filename = directory1.GetListFiles(ori_path, exten, addPath1);//存储原始图像名
		vector<string> salien_filename = directory2.GetListFiles(salien_path, exten, addPath1);//存储显著性图片名字

		for(int n=0;n<ori_filename.size();n++)
		{
			itoa(n+1,numch,10);
			output_filename=output+numch+extenout;//输出文件名

			Mat orig_img=imread(ori_filename[n],1); //输入原始图像
	        Mat salien_map=imread(salien_filename[n],0);//输入显著性图，二值图像

	        const int nRow=orig_img.rows;
	        const int nCol=salien_map.cols;



	        //~~~~~~~~~~~~~~~~Draw Rectangle~~~~~~~~~~~~~~~~~~~~//
	        int i=0,j=0,c=0;
	        int nRowMin=0, nRowMax=0, nColMin=0, nColMax=0;

			for(i=0;i<nRow;i++)
			{
				for(j=0;j<nCol;j++)
				{
					if(mSaMap.at<uchar>(i,j)==255)
					{
						nColMin=j;
						nColMax=j;
						nRowMin=i;
						nRowMax=i;
						c=1;
						break;
					}
				}
				if(c==1)
					break;
			}
			for(c=0,j=0;j<nColMin;j++)
			{
				for(i=nRowMin;i<nRow;i++)
				{
					if(mSaMap.at<uchar>(i,j)==255)
					{
						nRowMax=i;
						nColMin=j;
						c=1;
						break;
					}
				}
				if(c==1)
					break;
			}
			for(c=0,i=nRow-1;i>nRowMax;i--)
			{
				for(j=nColMin;j<nCol;j++)
				{
					if(mSaMap.at<uchar>(i,j)==255)
					{
						nRowMax=i;
						if(j>nColMax)
							nColMax=j;
						c=1;
						break;
					}
				}
				if(c==1)
					break;
			}
			for(c=0,j=nCol-1;j>nColMax;j--)
			{
				for(i=nRowMin;i<nRowMax;i++)
				{
					if(mSaMap.at<uchar>(i,j)==255)
					{
						nColMax=j;
						c=1;
						break;
					}
				}
				if(c==1)
					break;
			}


	        Mat mDrawRec=mOriginImg.clone();
	        Point2f pRecLeftUp,pRecRightDown;
	        pRecLeftUp=cvPoint(nColMin,nRowMin);
	        pRecRightDown=cvPoint(nColMax,nRowMax);
	        rectangle( mDrawRec, pRecLeftUp,pRecRightDown, Scalar(0, 255, 0), 2);



	        //~~~~~~~~~~~~~~~~Implement grab cut~~~~~~~~~~~~~~~~~~~~//
	        Rect rect(pRecLeftUp,pRecRightDown);
	        Mat OutMask(mOriginImg.size(), CV_8UC1);
	        Mat BgdModel, FgdModel;

	        int nIteration=3;
	        Mat mask;
	        Mat obj;
	        bool isInitialized=false;

	        for(i=0; i<nIteration; i++)
	        {
	                if(!isInitialized)
	                {
	                        grabCut(mOriginImg, OutMask, rect, BgdModel, FgdModel, 1, GC_INIT_WITH_RECT);
	                        isInitialized=true;
	                }
	                else
	                {
	                        grabCut(mOriginImg, OutMask, rect, BgdModel, FgdModel, 1);
	                }
	        }
	        compare(OutMask, GC_PR_FGD, mask, CMP_EQ);
	        mOriginImg.copyTo(obj, mask);


    //~~~~~~~~~~~~~~~~Show segmentation result~~~~~~~~~~~~~~~~~~~~//
	        Mat  mSegBinary=obj.clone();
	        cvtColor(mSegBinary,mSegBinary,CV_RGB2GRAY);
	        for(i=0;i<nRow;i++)
	            for(j=0;j<nCol;j++)
	            {
				        if(mSegBinary.at<uchar>(i,j)>0)
			                    mSegBinary.at<uchar>(i,j)=255;
		        }

			imwrite(output_path,mSegBinary);
			cout<<n+1<<endl;
		}


	}
	return 0;
}
