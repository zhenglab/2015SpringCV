#include "slic.h"
#include <cstdlib>
#include <cstdio>
#include <opencv2/opencv.hpp> 
#include <opencv2/core/core.hpp>

#include <opencv2/highgui/highgui.hpp>
#pragma comment( lib, "opencv_highgui300d.lib")
#pragma comment( lib, "opencv_core300d.lib")



using namespace std;
using namespace cv;


int Maxof1channelMatrix(Mat &Matrix)
{
	int max=0;
	for(int i=0;i<Matrix.rows;i++)
		for(int j=0;j<Matrix.cols;j++)
			if(max<Matrix.at<int>(i,j))
				max=Matrix.at<int>(i,j);
	return max;
}
int Minof1channelMatrix(Mat &Matrix)
{
	int min=0;
	for(int i=0;i<Matrix.rows;i++)
		for(int j=0;j<Matrix.cols;j++)
			if(min>Matrix.at<int>(i,j))
				min=Matrix.at<int>(i,j);
	return min;
}

Mat InitColExtrMatrix(Mat &img)
{
	Mat colExtraMatrixtemp;
	
	int m=img.rows;
	int n=img.cols*img.channels();
	 for(int j=0;j<m;j++)
	 {
		 uchar *data=img.ptr<uchar>(j);
		 for(int i=0;i<n;i++)
		 {
			 data[i]=data[i]/16*16 + 8;
		 }
	 }
	vector<Mat> solitChannel(img.channels());
	split(img,solitChannel);
	solitChannel[0].convertTo(solitChannel[0],CV_32SC1);
	solitChannel[1].convertTo(solitChannel[1],CV_32SC1);
	solitChannel[2].convertTo(solitChannel[2],CV_32SC1);
	//cout<<solitChannel[0];
	colExtraMatrixtemp=(solitChannel[0]/16)*16*16+(solitChannel[1]/16)*16+(solitChannel[2]/16);
	int min=Minof1channelMatrix(colExtraMatrixtemp);
	int max=Maxof1channelMatrix(colExtraMatrixtemp);
	Mat colExtraMatrixtemp_out=255*(colExtraMatrixtemp-min)/(max-min);
	colExtraMatrixtemp_out.convertTo(colExtraMatrixtemp_out,CV_8U);
	imshow("Image2Origin",colExtraMatrixtemp_out);
	//cout<<solitChannel[0];
	
	return colExtraMatrixtemp;
}


Mat  CenterPrior(Mat &img)
{
	  Mat centerMap;
    int sigmaD = 150*150;
    Mat coordinateMtx1(img.rows, img.cols, CV_32F, Scalar(0,0,0));
    Mat coordinateMtx2(img.rows, img.cols, CV_32F, Scalar(0,0,0));
    for (int i=0; i<img.cols; i++) {
        for (int j=0; j<img.rows; j++) {
            coordinateMtx1.at<float>(j, i)=j+1;
        }
    }
    for (int i=0; i<img.rows; i++) {
        for (int j=0; j<img.cols; j++) {
            coordinateMtx2.at<float>(i,j)=j+1;
        }
    }
    int centerX=img.rows/2;
    int centerY=img.cols/2;
    Mat centerXMtx=Mat::ones(img.rows, img.cols, CV_32F)*centerX;
    Mat centerYMtx=Mat::ones(img.rows, img.cols, CV_32F)*centerY;
    Mat sumMtx1=(coordinateMtx1-centerXMtx);
    Mat sumMtx2=(coordinateMtx2-centerYMtx);
    
    
    exp(-(sumMtx1.mul(sumMtx1)+sumMtx2.mul(sumMtx2))/sigmaD, centerMap);
    imshow("center-prior", centerMap);
 
   
    return centerMap;
	//cout<<centerMtx[0];
	//cout<<centerMtx[1];
	//cout<<coordinateMtx[0];
	//cout<<coordinateMtx[1];

}



int main(int argc, char** argv)
{
	if (argc != 3) {
		printf("usage: test_slic <filename> <number of superpixels>\n");
		exit(-1);
	}

	cv::Mat img,result,img2;
	
	
	

	
int *label,*labelstart;
	
	
	
	img = imread(argv[1]);
	cv::namedWindow("ImageOrigin1");
	cv::imshow("ImageOrigin1",img);

	Mat SupSegmatrix(img.rows,img.cols,CV_32SC1);
	cv::Mat ColExtrmatrix(img.rows,img.cols,CV_32SC1);
	int numSuperpixel = atoi(argv[2]);
    ColExtrmatrix=InitColExtrMatrix(img);//m*n matrix of color information 
	SLIC slic;
	slic.GenerateSuperpixels(img, numSuperpixel);
	cout<<Maxof1channelMatrix(ColExtrmatrix)<<" "<<Minof1channelMatrix(ColExtrmatrix);
	//cout<<img<<endl;
	if (img.channels() == 3) 
		result = slic.GetImgWithContours(cv::Scalar(0, 0, 0));
	else
		result = slic.GetImgWithContours(cv::Scalar(128));
	label=slic.GetLabel();//得到label一维数组首地址赋给label
	labelstart=label;
	//for(int i=0;i<img.cols*img.rows;i++)
	//	cout<<label[i]<<" ";
	cv::namedWindow("ImageOrigin3");
	cv::imshow("ImageOrigin3",result);
	for(int j=0;j<img.rows;j++)
	 {
		 int *data=SupSegmatrix.ptr<int>(j);
		 for(int i=0;i<img.cols;i++)
		 {
			 data[i]=*label;
			 label++;
		 }
	 }//将一维label数组转换为与图片位置相对应的二维数组


	//////////////step2///////////////////////////////
	int labelmax;
	labelmax=Maxof1channelMatrix(SupSegmatrix)-Minof1channelMatrix(SupSegmatrix)+1;
	//cout<<labelmax;
	label=labelstart;

	
	cv::Mat HistoMatrix(labelmax,2500,CV_32SC1);
	HistoMatrix=Mat::zeros(labelmax,2500,CV_32SC1);
	int *numcnt=new int[labelmax];//cout<<labelmax;
	for(int m=0;m<labelmax;m++)
	{
		*(numcnt+m)=0;
		for(int i=0;i<img.rows;i++)
		{
			for(int j=0;j<img.cols;j++)
			{
				if(SupSegmatrix.at<signed int>(i,j)==m)
				{
					HistoMatrix.at<int>(m,*(numcnt+m))=ColExtrmatrix.at<int>(i,j);
					(*(numcnt+m))++;

				}
			}
		}


	}//创建一个数组HistoMatrix，每一行存放label=行数的像素点的量化颜色信息值

	//cout<<HistoMatrix;
	vector<Mat> HistTemp(labelmax);
		
	for(int i=0;i<HistoMatrix.rows;i++)
	{
		//cout<<i<<" "<<*(numcnt+i)<<endl;
		HistTemp[i].create(1,*(numcnt+i),CV_32SC1);
		int *data=HistoMatrix.ptr<int>(i);
		for(int j=0;j<*(numcnt+i);j++)
		{
			HistTemp[i].at<int>(0,j)=data[j];
			
			
		}

	}//将HistoMatrix中的的每行的空余空间剔除掉，存放到HistTemp数组中
	
	vector<Mat> HistConv(labelmax);
	vector<Mat> HistSave(labelmax);
	for(int i=0;i<labelmax;i++)
		HistTemp[i].convertTo(HistConv[i],CV_32F);//转换成float类型存放，方便calcHist计算
	const int histSize=512;
	float range[]={0,Maxof1channelMatrix(ColExtrmatrix)};
	const float *ranges[] = {range};  
	const int channels = 0; 
	for(int i=0;i<labelmax;i++)
	{	
		cv::calcHist(&HistConv[i], 1, &channels, cv::Mat(), HistSave[i], 1, &histSize, &ranges[0], true, false); 
		//cout<<i<<" "<<HistSave[i]<<endl;
	}//vector<Mat> HistSave存放每一个label所对应的颜色信息的直方图

	///////////////////step3///////////////////////////////////////////////////
	float *HistValue=new float[labelmax];
	for(int i=0;i<labelmax;i++)
	{
		*(HistValue+i)=0;
		for(int j=0;j<labelmax;j++)
			{
				float a=(float)(*(numcnt+j))/(float)(img.rows*img.cols);
				*(HistValue+i)+=a*compareHist(HistSave[i],HistSave[j],HISTCMP_CHISQR_ALT);
		    }
		//	*(HistValue+i)/=labelmax;
       //cout<<i<<" "<<*(HistValue+i)<<endl;
	}
	int max=0,min=4096;
	for(int i=0;i<labelmax;i++)
	{
		if(max<*(HistValue+i))
			max=*(HistValue+i);
		if(min>*(HistValue+i))
			min=*(HistValue+i);
	}
	//cout<<max<<" "<<min;
	for(int i=0;i<labelmax;i++)
	{
		*(HistValue+i)=255*(*(HistValue+i)-min)/(max-min);
		//cout<<i<<" "<<*(HistValue+i)<<endl;
	}

	///////////////////step4/////////////////////////////////////////////////////
	Mat SaliencyMatrix(SupSegmatrix.rows,SupSegmatrix.cols,CV_32SC1);
	for(int i=0;i<SupSegmatrix.rows;i++)
	{
		for(int j=0;j<SupSegmatrix.cols;j++)
		{
			int mark=SupSegmatrix.at<int>(i,j);
			SaliencyMatrix.at<int>(i,j)=*(HistValue+mark);
		}
	}
	SaliencyMatrix.convertTo(SaliencyMatrix,CV_8U);
	cv::namedWindow("ImageOrigin4");
	cv::imshow("ImageOrigin4",SaliencyMatrix);
	
	///////////////////step5//////////////////////////////////////////////////////
	//cout<<CenterPrior(img);
	
	SaliencyMatrix.convertTo(SaliencyMatrix,CV_32F);
	Mat SaliencyOut=SaliencyMatrix.mul(CenterPrior(img));
	SaliencyOut.convertTo(SaliencyOut,CV_8U);
	
	
	cv::namedWindow("Image");
	cv::imshow("Image",SaliencyOut);
	cv::waitKey(0);
}