
function [ri,gce,vi]=compare_segmentations(sampleLabels1,sampleLabels2)



[imWidth,imHeight]=size(sampleLabels1);
[imWidth2,imHeight2]=size(sampleLabels2);
N=imWidth*imHeight;
if (imWidth~=imWidth2)||(imHeight~=imHeight2)
    disp( 'Input sizes: ' );
    disp( size(sampleLabels1) );
    disp( size(sampleLabels2) );
    error('Input sizes do not match in compare_segmentations.m');
end;

if min(min(sampleLabels1)) < 1
    sampleLabels1 = sampleLabels1 - min(min(sampleLabels1)) + 1;
end
if min(min(sampleLabels2)) < 1
    sampleLabels2 = sampleLabels2 - min(min(sampleLabels2)) + 1;
end

segmentcount1=max(max(sampleLabels1));
segmentcount2=max(max(sampleLabels2));

n=zeros(segmentcount1,segmentcount2);

for i=1:imWidth
    for j=1:imHeight
        u=sampleLabels1(i,j);
        v=sampleLabels2(i,j);
        n(u,v)=n(u,v)+1;
    end;
end;

ri = rand_index(n);
gce = global_consistancy_error(n);
vi = variation_of_information(n);

return;



function ri = rand_index(n)
N = sum(sum(n));
n_u=sum(n,2);
n_v=sum(n,1);
N_choose_2=N*(N-1)/2;
ri = 1 - ( sum(n_u .* n_u)/2 + sum(n_v .* n_v)/2 - sum(sum(n.*n)) )/N_choose_2;


function gce = global_consistancy_error(n)
N = sum(sum(n));
marginal_1 = sum(n,2);
marginal_2 = sum(n,1);

E1 = 1 - sum( sum(n.*n,2) ./ (marginal_1 + (marginal_1 == 0)) ) / N;
E2 = 1 - sum( sum(n.*n,1) ./ (marginal_2 + (marginal_2 == 0)) ) / N;
gce = min( E1, E2 );


function vi = variation_of_information(n)
N = sum(sum(n));
joint = n / N; % the joint pmf of the two labels
marginal_2 = sum(joint,1);  % row vector
marginal_1 = sum(joint,2);  % column vector
H1 = - sum( marginal_1 .* log2(marginal_1 + (marginal_1 == 0) ) ); % entropy of the first label
H2 = - sum( marginal_2 .* log2(marginal_2 + (marginal_2 == 0) ) ); % entropy of the second label
MI = sum(sum( joint .* log2_quotient( joint, marginal_1*marginal_2 )  )); % mutual information
vi = H1 + H2 - 2 * MI; 


function lq = log2_quotient( A, B )
lq = log2( (A + ((A==0).*B) + (B==0)) ./ (B + (B==0)) );