#include <cv.hpp>
#include <highgui.hpp>
#include <core.hpp>


using namespace cv;
using namespace std;

Mat Quantize(Mat &img)
{
        Mat quantity(img.rows, img.cols, CV_8U);
        Mat quantity_out(img.rows, img.cols, CV_8U);
        int bins[]={16,16,16};
        vector<Mat> rgb_planes(img.channels());
        split(img, rgb_planes);                                                 //分离图像三通道的值，可以用merge进行合并

        rgb_planes[0].convertTo(rgb_planes[0],CV_32F);
        rgb_planes[1].convertTo(rgb_planes[1],CV_32F);
        rgb_planes[2].convertTo(rgb_planes[2],CV_32F);

       quantity=rgb_planes[0]/bins[0]*bins[1]*bins[2]+rgb_planes[1]/bins[1]*bins[2]+rgb_planes[2]/bins[2];

       normalize(quantity,quantity_out,255,0,NORM_MINMAX);    //归一化，将量化图像范围限定在0~255之间，用来输出
       quantity_out.convertTo(quantity_out,CV_8U);                          //图像格式转换为从cv_8u，即uchar型，且像素值在255以下，才能正常显示

        imshow("Quantity",quantity_out);
        waitKey();
//        imwrite("Quantity.jpg",quantity_out);
        return quantity;
}

