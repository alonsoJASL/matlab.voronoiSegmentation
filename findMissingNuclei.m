function [fakeRed, fakeNuclei, fakeAtt] = findMissingNuclei(plainRed, plainGreen)
%       FIND MISSING NUCLEI (ON RED CHANNEL)
%
% Function that finds the (possibly) missing nuclei from an RGB image of
% cells (Macrophages).
%
% USAGE:
%   [fakeRed, fakeNuclei, fakeAtt] = findMissingNuclei(plainRed, plainGreen)
%

% Part of the matlab.vornoiSegmentation package hosted at:
% <https://github.com/alonsoJASL/matlab.voronoiSegmentation.git>

fakeRed = plainRed;
im = plainGreen;

regs = regionprops('table', fakeRed, 'Centroid', 'Area', ...
    'MajorAxisLength','MinorAxisLength');
XY = regs.Centroid;
mNucleiSize = min(regs.Area);

%[V,C] = voronoin(XY);
[Vimage, ~] = voronoizone(XY(:,1), XY(:,2), im); 

n=size(regs,1);
se = strel('disk',5);

for indx=1:n
    binImage = bitand(im,Vimage==indx);
    %imagesc(imopen(binImage,se));
    binImage = bwareafilt(binImage,[mNucleiSize, Inf]);
    
    binRegs = regionprops('table',binImage);
    
    %area = binRegs.Area;
    centroids = binRegs.Centroid;
    
    if size(binRegs,1)>1
        testMinDistance = zeros(size(binRegs,1),1);
        for j=1:size(binRegs,1)
            centroidTest = repmat(centroids(j,:),size(XY,1),1);
            distance = XY-centroidTest;
            norms = diag(sqrt(distance*distance'));
            testMinDistance(j) = min(norms);
        end
        [~,maxDistIndx] = max(testMinDistance);
        [artificialNuclei1(:,:,indx), fakeRed] = getArtificialNuclei(fakeRed,...
            centroids(maxDistIndx,:),mNucleiSize);
    end
end

if nargout > 1
    fakeNuclei = max(artificialNuclei1,[],3)>0;
    if nargout > 2
        fakeAtt.regs = regionprops('table',fakeNuclei);
        fakeAtt.numArtificial = size(fakeAtt.regs,1);
    end
end