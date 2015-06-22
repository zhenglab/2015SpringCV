function outMap = signatureSal( img , param )

%
%  inputs: 
%     img    : either matrix of intensities or filename
%     param  : optional parameters, should have fields as set in default_signature_param
%
%  output
%     outMap : a saliency map for the image 
%
%
%  This algorithm is described in the following paper:
%  "Image Signature: Highlighting sparse salient regions", by Xiaodi Hou, Jonathan Harel, and Christof Koch.
%  IEEE Transactions on Pattern Analysis and Machine Intelligence, 2011.
%  
%  Coding by Xiaodi Hou and Jonathan Harel, 2011
% 
%  License: Code may be copied & used for any purposes as long as the use is acknowledged and cited.
%

% read in file if img is filename
if ( strcmp(class(img),'char') == 1 ) img = imread(img); end

% convert to double if image is uint8
if ( strcmp(class(img),'uint8') == 1 ) img = double(img)/255; end

if ( ~exist( 'param' , 'var' ) )
  param = default_signature_param;
end

img = imresize(img, param.mapWidth/size(img, 2));

numChannels = size( img , 3  );      %返回img的第三维信息，即通道数

if ( numChannels == 3 )
  
  if ( isequal( lower(param.colorChannels) , 'lab' ) )      %lower表示将大写转化为小写
    
    labT = makecform('srgb2lab');                           %makeform色彩转换命令，将rgb转为lab
    tImg = applycform(img, labT);                           %实现颜色空间的转换，为Lab格式
    
  elseif ( isequal( lower(param.colorChannels) , 'rgb' ) )
    
    tImg = img;                                             %保持rgb不变
    
  elseif ( isequal( lower(param.colorChannels) , 'dkl' ) )
    
    tImg = rgb2dkl( img );                                  %为dkl图像格式
    
  end

else
  
  tImg = img;

end

cSalMap = zeros(size(img));                                 %创建与img同样大小的全零矩阵

for i = 1:numChannels
  cSalMap(:,:,i) = idct2(sign(dct2(tImg(:,:,i)))).^2;       %DCT反变换，//（：，：，i）表示所有行和列，取第i页，结果为二维数组
end

outMap = mean(cSalMap, 3);                                  %对第3维求平均

if ( param.blurSigma > 0 )
  kSize = size(outMap,2) * param.blurSigma;
  outMap = imfilter(outMap, fspecial('gaussian', round([kSize, kSize]*4), kSize));
end

if ( param.resizeToInput )
  outMap = imresize( outMap , [ size(img,1) size(img,2) ] );
end
  
outMap = mynorm( outMap , param );
