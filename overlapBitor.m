function [newBin, newBatt] = overlapBitor(B, batt)
%                       OVERLAP BIT-OR
% A bit-or operator that takes into account possible overlapping datasets.
% B has three levels, we're overlapping levels two and three. 
% 

% Part of the matlab.vornoiSegmentation package hosted at:
% <https://github.com/alonsoJASL/matlab.voronoiSegmentation.git>

Q = changeOverlapRepresentation(bwlabeln(B(:,:,3)));
Q2 = changeOverlapRepresentation(Q);
Q3 = changeOverlapRepresentation(Q2);
Q4 = Q3>0;

R = changeOverlapRepresentation(dataBin(:,:,2));
for q=1:size(Q4,3)
    batt.labels(end+1) = getPrimes(max(unique(R)),1);
    R(:,:,end+1) = getPrimes(max(unique(R)),1).*Q4(:,:,q);
end

R2 = changeOverlapRepresentation(R);

newBin = R2;

if nargout > 1
    newBatt = batt;
end