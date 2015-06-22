#include <iostream>
#include <cv.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include<string>
#include<contrib/contrib.hpp>


using namespace std;
using namespace cv;



int main()
{
	for(int threshold=2;threshold<3;threshold++)
	{
		
		Directory origin_dir,salency_dir;
		char temp[1];
		itoa(threshold,temp,10);
		string threst=temp;
		string origin_path="D:/研一/assignment3/PASCAL/PASCAL";
		string salency_path="D:/研一/assignment3/PASCAL/PASCAL_SALENCY_0."+threst;
		string exten="*.jpg";
		string extenout=".jpg";
		string filenames3;
		bool addPath = true;
		string output="D:/研一/assignment3/PASCAL/output_k6/0."+threst+"/";
		char numch[1];
	
	
		vector<string> filenames1 = origin_dir.GetListFiles(origin_path, exten, addPath);
		vector<string> filenames2 = salency_dir.GetListFiles(salency_path, exten, addPath);
	
		for(int n=11;n<50;n++)
		{
			itoa(n+1,numch,10);
			filenames3=output+numch+extenout;
	
			Mat mOriginImg=imread(filenames1[n],1);                  //输入原始图像
	        Mat mSaMap=imread(filenames2[n],0);                       //输入saliency map的二值图像
	
	        const int nRow=mOriginImg.rows;
	        const int nCol=mOriginImg.cols;
	
	
	
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
	
	        int nIteration=6;
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
			imwrite(filenames3,mSegBinary);
	        cvtColor(mSegBinary,mSegBinary,CV_RGB2GRAY);
	        for(i=0;i<nRow;i++)
	            for(j=0;j<nCol;j++)
	            {
				        if(mSegBinary.at<uchar>(i,j)>0)
			                    mSegBinary.at<uchar>(i,j)=255;
		        }
	
			cout<<n+1<<endl;
		}
		

	}
	return 0;
}