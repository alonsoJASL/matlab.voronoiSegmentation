function [connectionMatrix] = getCellsOverlappingMatrix(groundTruth, att)
%               GET CONNECTION MATRIX FOR OVERLAPPING CELLS
%
% Takes a segmented image, i.e ground truth on overlapped datasets, and
% creates an upper triangular square matrix of size = NUMBER_OF_LABELS 
% that represents the overlapping of the cells. 
%
% USAGE: 
%        [connectionMatrix] = getCellsOverlappingMatrix(groundTruth, att)
% 
% INPUT:
%                   gt := original 2D image.
%                  att := Structure of attributes of the image
%                         MUST include:
%                           - att.Depth := number of 3D slices of thew
%                                          image
%                           - att.overlap := boolean (always true, given
%                                           the context)
%                           - att.overlaptype := either 'primes' or
%                             'levels'.
%                           - att.overlaplevels
%                           
% OUTPUT:
%     connectionMatrix := Matrix that shows the cells' overlapping
%                       interacions.
% 

% Part of the matlab.vornoiSegmentation package hosted at:
% <https://github.com/alonsoJASL/matlab.voronoiSegmentation.git>

if nargin < 2
    sizeGT = size(groundTruth);
    att.Height = sizeGT(1);
    att.Width = sizeGT(2);
    att.Depth = size(groundTruth, 3);
    
    att.overlap = true;
    if att.Depth > 1
        att.overlaptype = 'levels';
        att.overlapindx = [];
        att.ovelaplabels = [];
    else
        att.overlaptype  = 'primes';
        labelsGT = unique(groundTruth);
        overlapindx = find(~isprime(labelsGT));
        overlapindx(1) = [];
        
        att.overlapindx = overlapindx;  
        overlaplabels = labelsGT(overlapindx);
        att.overlaplabels = overlaplabels;  
    end
    att.overlaplevels = att.Depth;
else % two arguments sent: gt image and attributes structure.
    try
        att.overlaptype = lower(att.overlaptype);
    catch e
        disp('ERROR. Set the attributes struct right!');
        newGT = [];
        newAtt = [];
        return;
    end
end

switch att.overlaptype
    case {'primes','prime'}
        % From prime-based to layered ground truth.
        labelsOnImage = unique(groundTruth);
        labelsOnImage(1) = [];
        indxNotPrime = find(~isprime(labelsOnImage));
        
        actualLabels = [];
        for i=1:length(labelsOnImage)
            actualLabels = [actualLabels factor(labelsOnImage(i))];
        end
        actualLabels = unique(actualLabels);
        
        connectionMatrix = eye(length(actualLabels));
        
        for i=1:length(indxNotPrime)
            compoundLabel = labelsOnImage(indxNotPrime(i));
            factorisedLabel = factor(compoundLabel);
            for j=1:(length(factorisedLabel)-1)
                oneIndx = find(actualLabels==factorisedLabel(j));
                for k=(j+1):length(factorisedLabel)
                    secIndex = find(actualLabels==factorisedLabel(k));
                    connectionMatrix(oneIndx, secIndex) = 1;
                end
            end
        end
        
    case {'levels', 'level'}
        % Convert to primes representation and get matrix from it.
        [primesGT, primesAtt] = changeOverlapRepresentation(groundTruth, att);
        [connectionMatrix] = getCellsOverlappingMatrix(primesGT, primesAtt);
        
    otherwise
        disp('ERROR. Found atributes.overlaptype, but options do not match.');
        disp('Try again. Available options are: "LEVELS" or "PRIMES".');
        newGT = [];
        newAtt = [];
        return;
end