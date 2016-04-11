function [artNuclei, newImage] = getArtificialNuclei(im, center, Area)
%           GET ARTIFICIAL NUCLEI FROM CENROID AND AREA
% 
% Finds the possible locations of nuclei in the red channel that might have
% not been picked up by the segmentation (or were not annotated in the ground
% truth). This enables a better labelling of the overlapping cells.
%
% USAGE:
%      [artNuclei, newImage] = getArtificialNuclei(im, center, Area)
%

% Part of the matlab.vornoiSegmentation package hosted at:
% <https://github.com/alonsoJASL/matlab.voronoiSegmentation.git>

[imageSizeY,imageSizeX] = size(im);

[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = fix(center(1));
centerY = fix(center(2));

radius = fix(sqrt(Area/pi));
artNuclei = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;
% circlePixels is a 2D "logical" array.
% Now, display it.
if nargout > 1
    newImage = bitor(im, artNuclei);
end