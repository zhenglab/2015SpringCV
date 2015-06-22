#include <iostream>
#include <opencv/cv.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/core.hpp>
#include <stdlib.h>


using namespace std;
using namespace cv;



int main(int, char* argv[])
{
    Mat mOriginImg=imread(argv[1],1);                  //输入原始图像
    Mat mSaMap=imread(argv[2],0);                   //输入saliency map的二值图像
    char* fig=argv[3];                      //框改变的大小
    float recSize=atof(fig);

    const int nRow=mOriginImg.rows;
    const int nCol=mOriginImg.cols;

    //~~~~~~~~~~~~~~~~Draw Rectangle~~~~~~~~~~~~~~~~~~~~//
    int i=0,j=0;
    int nRowMin=0, nRowMax=0, nColMin=0, nColMax=0;

    vector<int> width;
    vector<int> height;
    for(i=0; i<nRow; i++)
            for(j=0; j<nCol; j++)
            {
                    if(mSaMap.at<uchar>(i,j)==255)
                    {
                            width.push_back(j);
                            height.push_back(i);
                    }
            }

    nRowMin=height[0];
    nRowMax=height[0];
    for(i=0;i<height.size();i++)
    {
            if(nRowMin>height[i])
                    nRowMin=height[i];
            if(nRowMax<height[i])
                    nRowMax=height[i];
    }
    nColMin=width[0];
    nColMax=width[0];
    for(i=0;i<width.size();i++)
    {
            if(nColMin>width[i])
                    nColMin=width[i];
            if(nColMax<width[i])
                    nColMax=width[i];
    }
    nColMax-=recSize;
    nColMin+=recSize;
    nRowMax-=recSize;
    nRowMin+=recSize;
    Mat mDrawRec=mOriginImg.clone();
    Point2f pRecLeftUp,pRecRightDown;
    pRecLeftUp=cvPoint(nColMin,nRowMin);
    pRecRightDown=cvPoint(nColMax,nRowMax);
    rectangle( mDrawRec, pRecLeftUp,pRecRightDown, Scalar(0, 255, 0), 2);
    imwrite("/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/GrabcutCode/Rectangle_Grabcut/result/resRectangle/resRectangle.jpg", mDrawRec);

    //~~~~~~~~~~~~~~~~Implement grab cut~~~~~~~~~~~~~~~~~~~~//
    Rect rect(pRecLeftUp,pRecRightDown);
    Mat OutMask(mOriginImg.size(), CV_8UC1);
    Mat BgdModel, FgdModel;

    int nIteration=5;
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
    imwrite("/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/GrabcutCode/Rectangle_Grabcut/result/resGrabCut/resGrabCut.jpg", obj);

//~~~~~~~~~~~~~~~~Show segmentation result~~~~~~~~~~~~~~~~~~~~//
    Mat  mSegBinary=obj.clone();
    cvtColor(mSegBinary,mSegBinary,CV_RGB2GRAY);
    for(i=0;i<nRow;i++)
        for(j=0;j<nCol;j++)
        {
                if(mSegBinary.at<uchar>(i,j)>0)
                        mSegBinary.at<uchar>(i,j)=255;
        }
    imwrite("/Users/wangruchen/work/classComputerVision/assignment3_wo/code/part1GrabCut/GrabcutCode/Rectangle_Grabcut/result/resBinImg/resBinImg.jpg", mSegBinary);

    return 0;

}
