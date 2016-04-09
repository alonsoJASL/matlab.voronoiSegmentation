% script file: Voronoi segmentation testing
%

clear all;
close all;
clc;

plat = 'linux';
[dn,ds] = loadnames('macros',plat);

load(strcat(dn,ds(1:end-1),'_GT_mat_Ha/handles_sequence.mat'));
names = binAtt.names;
name = 'man00';

cmpMatrix_A = cell([length(names) 1]);
cmpMatrix_B = cell([length(names) 1]);
scoresPerLabel_A = cell([length(names) 1]);
scoresPerLabel_B = cell([length(names) 1]);
%
%i=1;
for i=1:length(names)
    
    frameName = strcat(name, num2str(names(i)));
    
    [X,xatt] = readParseInput(strcat(binAtt.fileName,frameName,'.tif'));
    [B, batt] = voronoiSegmentation(X,xatt);
    
    load(strcat(binAtt.outputfolder,frameName,'.mat'));
    
    gtMergedGreen = bitor(dataBin(:,:,2)>0,dataBin(:,:,3)>0);
    
    [gtFakeRed] = findMissingNuclei(dataBin(:,:,1)>0, gtMergedGreen);
    [bestCaseSeg, gtAtt] = voronoiLabelling(gtFakeRed, gtMergedGreen);
    
    Q = changeOverlapRepresentation(bwlabeln(dataBin(:,:,3)));
    Q2 = changeOverlapRepresentation(Q);
    Q3 = changeOverlapRepresentation(Q2);
    Q4 = Q3>0;
        
    R = changeOverlapRepresentation(dataBin(:,:,2));
    for q=1:size(Q4,3)
        batt.labels(end+1) = getPrimes(max(unique(R)),1);
        R(:,:,end+1) = getPrimes(max(unique(R)),1).*Q4(:,:,q);
    end
    
    R2 = changeOverlapRepresentation(R);
    
    nB = length(batt.labels); % amount of cells "detected".
    m = size(R,3); % amount of cells on ground truth.
    cmpMatrix_B{i} = zeros(nB,m);
    
    for j=1:nB
        segImage = B(:,:,2)==batt.labels(j);
        for k=1:m
            
            testGT = R(:,:,k)>0;
            
            AcapB = bitand(segImage,testGT);
            AcupB = bitor(segImage, testGT);
            cmpMatrix_B{i}(j,k) = sum(AcapB(:))/sum(AcupB(:));

        end
    end
    
    nA = length(gtAtt.labels); % amount of cells "detected".
    m = size(R,3); % amount of cells on ground truth.
    cmpMatrix_A{i} = zeros(nA,m);
    
    for j=1:nA
        segImage = bestCaseSeg(:,:,2)==gtAtt.labels(j);
        for k=1:m
            
            testGT = R(:,:,k)>0;
            
            AcapB = bitand(segImage,testGT);
            AcupB = bitor(segImage, testGT);
            cmpMatrix_A{i}(j,k) = sum(AcapB(:))/sum(AcupB(:));

        end
    end
    
    clear Q Q2 Q3 Q4;
    
    [mauxB imauxB] = max(cmpMatrix_B{i},[],2);
    [mauxA imauxA] = max(cmpMatrix_A{i},[],2);
    
    scoresPerLabel_B{i} =[imauxB mauxB];
    scoresPerLabel_A{i} =[imauxA mauxA];
end    
