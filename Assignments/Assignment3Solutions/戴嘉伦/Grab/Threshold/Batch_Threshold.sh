PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Sig="/home/dai/tmp/Assignment#3/Threshold/Signature/BatchProcessing.m"
Rect="/home/dai/tmp/Assignment#3/Threshold/Rectangle/BatchProcessing.sh"
Eva="/home/dai/tmp/Assignment#3/Threshold/Evaluation/BatchProcessing.m"

MatlabExe="/opt/Matlab2013/bin/matlab"

${MatlabExe} -nodesktop -nosplash -r "run ${Sig};quit"

sh ${Rect}

${MatlabExe} -nodesktop -nosplash -r "run ${Eva};quit"

