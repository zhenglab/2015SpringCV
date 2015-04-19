#include <iostream>
#include <cv.hpp>
#include <highgui.hpp>
#include <core.hpp>
#include <ximgproc.hpp>
#include <ximgproc/seeds.hpp>
#include <imgproc.hpp>
#include <imgcodecs.hpp>
#include <core/utility.hpp>

using namespace cv;
using namespace cv::ximgproc;
using namespace std;

extern int SuperPixel_Seg(Mat src, Mat &labels);
extern void Compare_Hist(vector<Mat> &hist, float *Hist_val, int num_hist);
extern Mat Center_Prior(Mat& img);
extern Mat Quantize(Mat &img);

int main(int argc, char* argv[] )
{
        char* filename = argc >= 2 ? argv[1] : (char*)"origin_image.jpg";
         Mat src=imread(filename,1);

         if( src.empty() )
        {
                cout << "Couldn'g open image. It's possible that the input image doesn't exist \n" ;
                return 0;
        }

        else
        {
             imshow("Origin Image",src);
             waitKey();

             const int nr=src.rows;
             const int nc=src.cols;

             //~~~~~~~Color Quantity~~~~~~~~~//
             Mat matImgQuantity=Quantize(src);
             matImgQuantity.convertTo(matImgQuantity,CV_32F);


             //~~~~~~~SuperPixel_Seg~~~~~~~~~~~//
             Mat matLabel ;                                                                                    //初始化
             int nNumSuperpixel = SuperPixel_Seg(src, matLabel);                   //返回超像素块的总数


             //~~~~~~~~~~ Initiation~~~~~~~~~~~//
            int histSize =256;                                                                     //直方图横坐标点的个数
            float range[] = { 0,256};                                                              //直方图横坐标的范围
            const float* histRange = { range};
            int i=0,j=0,k=0;
            vector<Mat>  vecSuperpixel(nNumSuperpixel);                            //定义矩阵，总素为块数，每个表示一个超像素块
            vector<Mat>  vecHist(nNumSuperpixel);                                      //定义直方图，表示每个像素块的直方图，其中下标对应超像素块的label值


            //~~~~~~~    Count Number of Superpixel    ~~~~~~~~~//
            float *fNumEachSuperpixel= new float [nNumSuperpixel]();       //num_each_superpixel表示每个超像素块的个数
            for(i=0;i<nr;i++)
                for(j=0;j<nc;j++)
                        fNumEachSuperpixel[matLabel.at<int>(i,j)]++;


            //~~~~~~~     Arrange Superpixel  and   Tranfer to Histgram~~~~~~~~~//
            int *pLocation = new int [nNumSuperpixel]();                                                                                               //pt表示指针位置
            for(k=0;k<nNumSuperpixel;k++)
                    vecSuperpixel[k]=Mat::zeros(1,  fNumEachSuperpixel[k], CV_32F);           //初始化，CV_32F 表示float，对像素点进行赋值与计算，必须进行数值转换

            for(i=0;i<nr;i++)
            {
                    for(j=0;j<nc;j++)
                    {
                            k=matLabel.at<int>(i,j);
                            vecSuperpixel[k].at<float>(0,pLocation[k])=matImgQuantity.at<float>(i,j);
                            pLocation[k]++;
                    }
            }
            for(k=0;k<nNumSuperpixel;k++)
                   calcHist( &vecSuperpixel[k], 1, 0, Mat(), vecHist[k], 1, &histSize, &histRange, true, false);    //计算每个像素块的直方图


            //~~~~~~~    Compute each superpixel    ~~~~~~~~~//
            float *fHistVal = new float [nNumSuperpixel]();         //动态创建一位数组，并且初始化，记录每个直方图与原图之间的距离值
            Compare_Hist(vecHist, fHistVal,nNumSuperpixel);


            //~~~~~~~    Convert pixel saliency    ~~~~~~~~~//
            Mat matSaliencyMap=Mat::zeros(nr,nc,CV_32F);              //用于输出的图像，初始化为cv_32F,即float型，用于后面计算
            for(i=0;i<nr;i++)
            {
                    for(j=0;j<nc;j++)
                    {
                            k=matLabel.at<int>(i,j);
                            matSaliencyMap.at<float>(i,j)=fHistVal[k];          //数值超过255，上限为4096
                    }
            }
            normalize(matSaliencyMap,matSaliencyMap,255,0,NORM_MINMAX);     //归一化saliency_map，使其像素值范围在0～255之间，用于输出
            matSaliencyMap.convertTo(matSaliencyMap,CV_8U);
            imshow("Initial Saliency",matSaliencyMap);
            waitKey();
 //           imwrite("Initial_Saliency.jpg",saliency_map);


            //~~~~~~~    Center Prior   ~~~~~~~~~//
            Mat matCenterPrior = Center_Prior(src);


            //~~~~~~~    Use Prior   ~~~~~~~~~//
            matSaliencyMap.convertTo( matSaliencyMap,CV_32F);
            Mat matFinalSaliency(nr, nc , CV_32F);
            matFinalSaliency = matSaliencyMap.mul(matCenterPrior);
            matFinalSaliency.convertTo(matFinalSaliency,CV_8U);

            imshow("Final Saliency",matFinalSaliency);
            waitKey();
//            imwrite("Final_Saliency.jpg",final_saliency);

            delete [ ] fHistVal;
            delete [ ] pLocation;
            delete [ ] fNumEachSuperpixel;
            return 0;
        }
}
