function [precision recall Fmeasure]=prfCount(GroundTruth, SaliencyMap)

%GroundTruth, SaliencyMap must be double type by the function "im2double"
gtsize=size(GroundTruth);
    if numel(gtsize)>2
        GroundTruth = rgb2gray(GroundTruth);
    end
    smsize=size(SaliencyMap);
    if numel(smsize)>2
        SaliencyMap = rgb2gray(SaliencyMap);
    end

[gtH, gtW] = size(GroundTruth);
[algH, algW] = size(SaliencyMap);
if gtH~=algH || gtW~=algW
	SaliencyMap = imresize(SaliencyMap, [gtH, gtW]);
end

SaliencyMap  =  SaliencyMap(:);
GroundTruth = GroundTruth(:);
instance_count = ones(length(SaliencyMap),1);

total_positive = sum(GroundTruth);

if total_positive==0
	precision = [];
	recall = [];
        Fmeasure = [];
	return;
end

% [M N] = size(SaliencyMap);
% sumPixel = 0;
% for i = 1:M
%     for j = 1:N
%         sumPixel = sumPixel+SaliencyMap(i,j);
%     end
% end
% avePixel = sumPixel/(M*N);
% T = min(2*avePixel,255);

% idx   = (SaliencyMap >= T);
idx   = logical(SaliencyMap);
recall = sum(GroundTruth(idx)) / total_positive;
precision=sum(GroundTruth(idx)) / (sum(instance_count(idx))+eps); 
Fmeasure=(1.3*precision.*recall)/(0.3*precision+recall+eps);
