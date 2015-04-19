#include <iostream>
#include <math.h>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/ximgproc.hpp>

using namespace std;
using namespace cv;

int main(int argc,char *argv[])
{
  ///输入一幅图像
  Mat img=imread("b.jpg",1);
  imshow("input",img);
  imwrite("input.png", img);
  waitKey();

  ///对输入图像进行颜色特征提取
  Mat input_img=img.clone();

  Mat ExtractImageInformation1(Mat img_input);
  Mat ExtractImageInformation2(Mat img_input);

  Mat quantize_img1(img.rows,img.cols,CV_32F);
  Mat quantize_img2(img.rows,img.cols,CV_8UC1);
  quantize_img1=ExtractImageInformation1(input_img);//256像素值变为16个像素值，显示效果
  quantize_img2=ExtractImageInformation2(img);//256像素值变为16个像素值，量化RGB像素值为0～4096


  ///对输入图像进行超像素分割
  Mat outSuperpixel=img.clone();
  Mat Superpixel_Label;
  int superpixel(Mat& outSuperpixel, Mat& Superpixel_Label);
  int numSuperpixel=superpixel(outSuperpixel, Superpixel_Label);//得到超像素分割的块数


  ///计算每个超像素的颜色直方图
  vector<Mat> EachSuperpixel_hist(numSuperpixel);
  int histSize=4096;
  float range[]={0,4096};
  const float* histRanges={range};
  int channel=0;

  for(int m=0;m<numSuperpixel;m++)
  {
  Mat eachSuperpixel=Mat::zeros(4000,1,CV_32F);
  int num=0;
  for(int i=0;i<img.rows;i++)
          for(int j=0;j<img.cols;j++)
                  if(Superpixel_Label.at<int>(i,j)==m)
                  {
                  eachSuperpixel.at<float>(num,0)=quantize_img2.at<float>(i,j);
                  num++;
                  }
  eachSuperpixel.resize(num);
  calcHist(&eachSuperpixel,1,&channel,Mat(),EachSuperpixel_hist[m],1,&histSize,&histRanges);
  normalize(EachSuperpixel_hist[m], EachSuperpixel_hist[m],1, NORM_MINMAX);
  }


  ///超像素直方图对比
  Mat contrast(Mat& img,Mat& Superpixel_Label,vector<Mat>& EachSuperpixel_hist,int numSuperpixel);
  Mat saliencyVal=contrast(img,Superpixel_Label,EachSuperpixel_hist,numSuperpixel);


  ///制作中心先验显著图
  Mat centerPrior(Mat& img);
  Mat centerMap=centerPrior(img);


  ///使用中心先验显著图增强显著效果
  saliencyVal.convertTo(saliencyVal,CV_32F);
  Mat finalsaliency(img.rows,img.cols,CV_32F);
  finalsaliency=saliencyVal.mul(centerMap);//中心先验显著图乘最初显著图得到最终显著图
  finalsaliency.convertTo(finalsaliency,CV_8U);

  imshow("saliency", finalsaliency);
  imwrite("saliency.png", finalsaliency);
  waitKey();

  ///进行阈值分割
  Mat dst;
  threshold( finalsaliency, dst, 30, 255,0 );
  imshow("segmentation", dst);
  imwrite("segmentation.png", dst);
  waitKey();
  return 0;
}

///定义函数将输入图像由256像素值量化为32像素值
Mat ExtractImageInformation1(Mat img_input)
{
    int div=8;
    for (int i=0;i<img_input.rows;i++)
           for (int j=0;j<img_input.cols;j++)
           {
           //img_input.at<Vec3b>(i,j)= img_input.at<Vec3b>(i,j)/16;
           img_input.at<Vec3b>(i,j)[0]=img_input.at<Vec3b>(i,j)[0]/div*div+div/2;
           img_input.at<Vec3b>(i,j)[1]=img_input.at<Vec3b>(i,j)[1]/div*div+div/2;
           img_input.at<Vec3b>(i,j)[2]=img_input.at<Vec3b>(i,j)[2]/div*div+div/2;
            }
    imshow("quantize_img1",img_input);
    imwrite("quantize_img1.png", img_input);
    waitKey();
    return img_input;
}

///定义函数将输入图像分解为RGB三通道并且将像素值量化为0～32*32*32
Mat ExtractImageInformation2(Mat img)
{
    Mat quantize_img;
    vector<Mat> rgb_planes;
    split(img, rgb_planes);
    rgb_planes[0].convertTo(rgb_planes[0], CV_32F);//类型转换
    rgb_planes[1].convertTo(rgb_planes[1], CV_32F);
    rgb_planes[2].convertTo(rgb_planes[2], CV_32F);
    quantize_img=(rgb_planes[0]/8)*32*32+(rgb_planes[1]/8)*32+(rgb_planes[2]/8);
    Mat quantize_img3;
    normalize(quantize_img, quantize_img3, 255, 0, NORM_MINMAX);
    imshow("quantize_img2",quantize_img3);
    imwrite("quantize_img2.png", quantize_img3);
    waitKey();
    return quantize_img;
}

///对输入图像进行超像素分割，得到超像素标记图，超像素分割块数，超像素分割输出图
int superpixel(Mat& outSuperpixel, Mat& Superpixel_Label)
{

    Mat outSupContour;
    Ptr<cv::ximgproc::SuperpixelSEEDS> seeds=cv::ximgproc::createSuperpixelSEEDS(outSuperpixel.size().width, outSuperpixel.size().height, outSuperpixel.channels(), 400, 4);
    seeds->iterate(outSuperpixel);
    seeds->getLabels(Superpixel_Label);
    seeds->getLabelContourMask(outSupContour,false);
    int numSuperpixel=seeds->getNumberOfSuperpixels();
    outSuperpixel.setTo(Scalar(0,0,255),outSupContour);
    imshow("superpixel", outSuperpixel);
    imwrite("superpixel.png", outSuperpixel);
    waitKey();
    return numSuperpixel;
}

///对不同超像素块的颜色直方图之间进行距离计算，并转换为像素级的距离图，即为初始显著图
Mat contrast(Mat& img,Mat& Superpixel_Label,vector<Mat>& EachSuperpixel_hist,int numSuperpixel)
{
Mat saliency_map1=Mat::zeros(img.rows,img.cols,CV_8U);
Mat contrast_value(numSuperpixel,1,CV_32F);
int i,j;
for(i=0;i<numSuperpixel;i++)
       {
       float Hist_value=0;
       for(j=0;j<numSuperpixel;j++)
             {
                   Hist_value=Hist_value+compareHist(EachSuperpixel_hist[i],EachSuperpixel_hist[j],HISTCMP_CHISQR_ALT);
             }
            contrast_value.at<float>(i,0)=Hist_value/numSuperpixel;
       }

normalize(contrast_value, contrast_value, 255, 0, NORM_MINMAX);

for (int i=0; i<img.rows; i++)
        for (int j=0; j<img.cols; j++)
            for (int m=0; m<numSuperpixel; m++)
                if (Superpixel_Label.at<int>(i,j)==m)
                    saliency_map1.at<uchar>(i, j)=contrast_value.at<float>(m,0);

imshow("Saliency1", saliency_map1);
imwrite("Saliency1.png", saliency_map1);
waitKey();
return saliency_map1;
}

///制作中心先验图
Mat centerPrior(Mat& img)
{
    Mat centerMap;
    int sigmaD=114*144;
    Mat coordinateMtx1(img.rows,img.cols,CV_32F,Scalar(0,0,0));
    Mat coordinateMtx2(img.rows,img.cols,CV_32F,Scalar(0,0,0));
    for(int i=0;i<img.cols;i++)
          for(int j=0;j<img.rows;j++)
              coordinateMtx1.at<float>(j,i)=j+1;
    for(int i=0;i<img.rows;i++)
          for(int j=0;j<img.cols;j++)
              coordinateMtx2.at<float>(i,j)=j+1;
    int centerX=img.rows/2;
    int centerY=img.cols/2;
    Mat centerXMtx=Mat::ones(img.rows,img.cols,CV_32F)*centerX;
    Mat centerYMtx=Mat::ones(img.rows,img.cols,CV_32F)*centerY;
    Mat sumMtx1=(coordinateMtx1-centerXMtx);
    Mat sumMtx2=(coordinateMtx2-centerYMtx);
    exp(-(sumMtx1.mul(sumMtx1)+sumMtx2.mul(sumMtx2))/sigmaD, centerMap);

    imshow("centerMap", centerMap);
    imwrite("centerMap.png", centerMap);
    waitKey();
    return centerMap;
}



















