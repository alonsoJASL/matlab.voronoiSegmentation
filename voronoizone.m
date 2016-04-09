function [voroimage,subImage] = voronoizone(x,y,img)
% Voronoi diagram based image zoning
%
% [voroimage,sub_image]=voronoizone(x,y,img)
% For a defined number of points on an image plane, voronoizone computes
% the voronoi diagram on the image space and divide the image into sub
% images according to the zones.

% Based on code by Kalyan S Dash, IIT Bhubaneswar, check original on: 
% 
% <http://uk.mathworks.com/matlabcentral/fileexchange/45893-voronoi-diagram-based-image-zoning/content/voronoizone.m>
%

szImg=size(img);
voroimage = zeros(szImg);
dis=zeros(length(x),1);

for i=1:szImg(1)
    for j=1:szImg(2)
                
        for k=1:length(x)
            dis(k)= (i-y(k))^2 + (j-x(k))^2;
        end
        
        %[~,index]=sort(dis,'ascend');
        
        [~,optk]=min(dis); %index(1);
        
        voroimage(i,j)=optk;
        
    end
end

if nargout > 1
    subImage = cell([length(x) 1]);
    for k=1:length(x)
        
        subImage{k}=img(find(voroimage==optk));
        
    end
    
end