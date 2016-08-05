function [dataLa, labAtt] = voronoiSegmentation(X, xatt)
%   OVERLAPPING CELLS (SHITTY) SEGMENTATION USING VORONOI DIAGRAMS
% 
% Segmentation of overlapping datasets using a simple voronoi diagram to
% seggregate one ovrelapping cell from the other. 
%
% USAGE:
%           [dataLa] = voronoiSegmentation(X, xatt)
%           [dataLa, labAtt] = voronoiSegmentation(X, xatt)
% 

% Part of the matlab.vornoiSegmentation package hosted at:
% <https://github.com/alonsoJASL/matlab.voronoiSegmentation.git>

[plainRed, plainGreen] = simpleClumpsSegmentation(X);

% Find and place fake red cells. 
[fakeRed, ~, fakeAtt] = findMissingNuclei(plainRed, plainGreen);

% Break green channel with voronoi diagram.
[dataL, datta] = voronoiLabelling(fakeRed, plainGreen);

dataLa = dataL;

if nargout > 1
    labAtt = xatt;
    labAtt.numCells = length(datta.labels);
    labAtt.labels = datta.labels;
    labAtt.voroninspace = datta.Vimage;
    labAtt.dnumArtificial = fakeAtt.numArtificial;
end
    


