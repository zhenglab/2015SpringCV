#include <cv.hpp>
#include <highgui.hpp>
#include <core.hpp>

using namespace cv;
using namespace std;

void Compare_Hist(vector<Mat> &hist, float *hist_val, int num_hist)
{
        int i=0,j=0;
        for(i=0;i<num_hist;i++)
                for(j=0;j<num_hist;j++)
                        hist_val[i] += compareHist(hist[i],hist[j],CV_COMP_CHISQR_ALT);             //计算每个超像素块对应直方图与整图距离的值
}
