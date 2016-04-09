function [dataLa, labAtt] = voronoiSegmentation(X, xatt)
%   OVERLAPPING CELLS (SHITTY) SEGMENTATION USING VORONOI DIAGRAMS
% 
% Segmentation of overlapping datasets using a simple voronoi diagram to
% seggregate one cell from the other. 
% 

% Segment red channel (blur, then segment)
% Also, segment green channel
red = X(:,:,1);
green = X(:,:,2);

f = fspecial('gaussian',[5 5],1);

filtRed = imfilter(red,f);
filtGreen = imfilter(green,f);

levRed = multithresh(filtRed,2);
levGreen = multithresh(filtGreen,2);

plainRed = binaryFromLevels(filtRed, levRed);
plainGreen = binaryFromLevels(filtGreen, levGreen);

% Postprocessing of binary levels
plainGreen = imfill(plainGreen,'holes');
se = strel('disk',3);
plainRed = imopen(plainRed,se);

% Find and place fake red cells. 
[fakeRed, ~, fakeAtt] = findMissingNuclei(plainRed, plainGreen);

% Break green channel with voronoi diagram.
[dataL, datta] = voronoiLabelling(fakeRed, plainGreen);

dataLa = dataL;

if nargout > 1
    labAtt = xatt;
    labAtt.numCells = length(datta.labels);
    labAtt.threslevs = levRed;
    labAtt.labels = datta.labels;
    labAtt.voroninspace = datta.Vimage;
    labAtt.dnumArtificial = fakeAtt.numArtificial;
end
    


