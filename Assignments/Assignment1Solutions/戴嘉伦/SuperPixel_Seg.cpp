#include <cv.hpp>
#include <highgui.hpp>
#include <core.hpp>
#include <ximgproc.hpp>
#include <ximgproc/seeds.hpp>
#include <imgproc.hpp>
#include <imgcodecs.hpp>

using namespace cv;
using namespace cv::ximgproc;


int SuperPixel_Seg(Mat src, Mat &matLabels)
{
        int height =src.rows, width=src.cols;
         int num_superpixels=500;
        int num_level=4;
        int prior=2;
        int num_histogram_bins=5;
        double double_step=false;
        int num_iterations=4;
        Mat mask=src.clone(),result=src.clone();
        Ptr<SuperpixelSEEDS>  seeds;
        seeds = createSuperpixelSEEDS(width,  height,  src.channels(),  num_superpixels,  num_level,  prior,  num_histogram_bins, double_step);
        Mat converted;
        cvtColor(src, converted, COLOR_RGB2HSV);
        seeds -> iterate(converted,num_iterations);
        int superpixels_num=0;
        superpixels_num = seeds ->  getNumberOfSuperpixels();
        seeds -> getLabels(matLabels);
        seeds -> getLabelContourMask(mask,false);
        result.setTo(Scalar(0,0,255), mask);

        imshow("SuperPixel",result);
        waitKey();
//        imwrite("Superpixel.jpg",result);
        return superpixels_num;
}
