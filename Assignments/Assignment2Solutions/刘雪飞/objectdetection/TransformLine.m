function TransformLine(imsize, keypoint, x1, y1, x2, y2)

% The scaling of the unit length arrow is set to approximately the radius
%   of the region used to compute the keypoint descriptor.
len = 6 * keypoint(3);

% Rotate the keypoints by 'ori' = keypoint(4)
s = sin(keypoint(4));
c = cos(keypoint(4));

% Apply transform
r1 = keypoint(1) - len * (c * y1 + s * x1);
c1 = keypoint(2) + len * (- s * y1 + c * x1);
r2 = keypoint(1) - len * (c * y2 + s * x2);
c2 = keypoint(2) + len * (- s * y2 + c * x2);
plot(c1,r1, 'o','markersize',5);
%line([c1 c2], [r1 r2], 'Color', 'c');
