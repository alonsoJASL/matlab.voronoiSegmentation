function [voronoiImage,subImage] = voronoizone(x,y,Im)
%           VORONOI DIAGRAM BASED IMAGE ZONING
% 
% For a defined number of points on an image plane, voronoizone computes
% the voronoi diagram on the image space and divide the image into sub
% images according to the zones.
%
% USAGE:
%           [voronoiImage,subImage] = voronoizone(x,y,Im)
% 
%
% Based on code by Kalyan S Dash, IIT Bhubaneswar, check original on: 
% <http://uk.mathworks.com/matlabcentral/fileexchange/45893-voronoi-diagram-based-image-zoning/content/voronoizone.m>
%

% Part of the matlab.vornoiSegmentation package hosted at:
% <https://github.com/alonsoJASL/matlab.voronoiSegmentation.git>

szImg=size(Im);
voronoiImage = zeros(szImg);

for i=1:szImg(1)
    for j=1:szImg(2)              
        dis = (i-y).^2 + (j-x).^2;
       
        [~,optk]=min(dis); 
        voronoiImage(i,j)=optk(1);
    end
end

if nargout > 1
    subImage = cell([length(x) 1]);
    for k=1:length(x)
        subImage{k}=Im(voronoiImage==optk(1));
    end
    
end