function [simpleRed, simpleGreen] = simpleClumpsSegmentation(X)
%
%

if size(X,3) == 1
    green = X;
    
    f = fspecial('gaussian',[5 5],1);
    
    filtGreen = imfilter(green,f); 
    levGreen = multithresh(filtGreen,2);
    
    simpleGreen = binaryFromLevels(filtGreen, levGreen);
    
    % Postprocessing of binary levels
    simpleGreen = imfill(simpleGreen,'holes');
    seG = strel('sphere',3);
    simpleGreen = imopen(simpleGreen,seG);
    simpleRed = [];
    
    if nargout < 2
        simpleRed = simpleGreen;
    end
else
    
    red = X(:,:,1);
    green = X(:,:,2);
    
    f = fspecial('gaussian',[5 5],1);
    
    filtRed = imfilter(red,f);
    filtGreen = imfilter(green,f);
    
    levRed = multithresh(filtRed,2);
    levGreen = multithresh(filtGreen,2);
    
    simpleRed = binaryFromLevels(filtRed, levRed);
    simpleGreen = binaryFromLevels(filtGreen, levGreen);
    
    % Postprocessing of binary levels
    simpleGreen = imfill(simpleGreen,'holes');
    seR = strel('disk',3);
    seG = strel('sphere',3);
    simpleRed = imopen(simpleRed,seR);
    simpleGreen = imopen(simpleGreen,seG);
end