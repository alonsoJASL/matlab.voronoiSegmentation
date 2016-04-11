function [dataL, att] = voronoiLabelling(plainRed, plainGreen)
%                       VORNONOI LABELLING
%
% Label the cells from the green channel (plainGreen) in order to match 
% the cells found on the red channel (plainRed).
%
% USAGE:
%       [dataL, att] = voronoiLabelling(plainRed, plainGreen)
% 

% Part of the matlab.vornoiSegmentation package hosted at:
% <https://github.com/alonsoJASL/matlab.voronoiSegmentation.git>

regs = regionprops('table', plainRed, 'Centroid', 'Area', ...
    'MajorAxisLength','MinorAxisLength');
XY = regs.Centroid;

[Vimage, ~] = voronoizone(XY(:,1), XY(:,2), plainGreen); 

n=size(regs,1);
dataL = zeros(size(plainGreen,1),size(plainGreen,2),3);
dataL(:,:,1) = plainRed;
mNucleiSize = min(regs.Area);

labels = getPrimes(n);

for indx=1:n
    binImage = bitand(plainGreen,Vimage==indx);
    binImageRed = bitand(plainRed, Vimage==indx);
    binImage = bwareafilt(binImage,[mNucleiSize, Inf]);
    dataL(:,:,1) = dataL(:,:,1)+labels(indx).*binImageRed;
    dataL(:,:,2) = dataL(:,:,2)+labels(indx).*binImage;
end

if nargout >1 
    att.labels = getPrimes(n);
    att.Vimage = Vimage;
end