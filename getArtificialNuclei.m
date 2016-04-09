function [artNuclei, newImage] = getArtificialNuclei(im, center, Area)
%           GET ARTIFICIAL NUCLEI FROM CENROID AND AREA
% 

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