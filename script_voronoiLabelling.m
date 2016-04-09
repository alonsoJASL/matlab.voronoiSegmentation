% Script file: Voronoi Labelling
% Turn a poorly segmented image into an OK-labelled one usign a voronoi
% diagram of the well segmented red channel. 
% 

%% Test on manually annotated ground truth

clear all;
close all;
clc;

plat = 'linux';
[dn, ds] = loadnames('macros', plat);
imname = 'man0049'; 

[X, xatt] = readParseInput(strcat(dn,ds,imname,'.tif'));

a = strfind(xatt.fileName, '/');
gtfolder = strcat(xatt.fileName(1:a(end)-1),'_GT/');

load(strcat(gtfolder, imname, '.mat'));
%% Check for cells that are not on the green channel
% Add fake red cell nuclei to redBIN channel 
% (now, only )

b2 = dataBin(:,:,2)>0;
b3 = dataBin(:,:,3)>0;
%%

se = strel('disk',6); % careful here.
b1 = imerode(dataBin(:,:,3),se);

% working with these images now
redBIN = dataBin(:,:,1)>0;
redBIN = bitor(redBIN,b1);
greenBIN = bitor(b2, b3);

regs = regionprops(redBIN>0);

%%
XY = reshape([regs.Centroid], 2,length(regs))';
%
[V,C] = voronoin(XY);
[Vimage, subImage] = voronoizone(XY(:,1), XY(:,2), greenBIN);

labels = getPrimes(length(regs));

dataL = zeros(size(dataBin(:,:,1)));

for i=1:length(regs)
    binImage = bitand(greenBIN,Vimage==i);
    binRegs = regionprops(binImage);
    area = [binRegs.Area];
    maxArea = max(area);
    binImage = bwareafilt(binImage, [maxArea Inf]); % minblob
    dataL = dataL + binImage.*labels(i);
end
%% Add cells in blue channel to green channel without ruining overlapping.
%
Q = changeOverlapRepresentation(bwlabeln(dataBin(:,:,3)));
Q2 = changeOverlapRepresentation(Q);
Q3 = changeOverlapRepresentation(Q2);
Q4 = Q3>0;

R = changeOverlapRepresentation(dataBin(:,:,2));
%
R(:,:,end+1) = getPrimes(max(unique(R)),1).*Q4(:,:,1);
R(:,:,end+1) = getPrimes(max(unique(R)),1).*Q4(:,:,2);
R(:,:,end+1) = getPrimes(max(unique(R)),1).*Q4(:,:,3);
%
R2 = changeOverlapRepresentation(R);
%% Test results
% 
%close all;
n = length(regs); % amount of cells "detected".
m = length(unique(R))-1; % amount of cells on ground truth.
cmpMatrix = zeros(n, m);

figure(1)
subplot(221); imagesc(R2); axis off; cooljet3;
title('Ground truth');
subplot(222); imagesc(dataL); axis off;
title('Voronoi labelling');
for i=1:n
    segImage = dataL==labels(i);
    for j=1:m
      
        testGT = R(:,:,j)>0;
        
        AcapB = bitand(segImage,testGT);
        AcupB = bitor(segImage, testGT);
        cmpMatrix(i,j) = sum(AcapB(:))/sum(AcupB(:));
        
        if cmpMatrix(i,j)>0
            subplot(223);
            imagesc(AcapB); axis off;
            subplot(224);
            imagesc(cmpMatrix); axis off;
            colorbar;
            pause(0.05);
        end
    end
end

[maxScores, maxIndx] = max(cmpMatrix,[],2);
scoresMatrix = dataL;

for i=1:n
    scoresMatrix(scoresMatrix==labels(i)) = maxScores(i);
end
subplot(223);
imagesc(scoresMatrix);
axis off;
colorbar;
title('Accuracy image per label');

%% Present the results.

greyX = rgb2gray(X);

figure(1)
imagesc(greyX);
axis off;
cooljet2;

figure(2)
imagesc(greyX.*(dataL>0));
axis off;
cooljet2;

figure(3)
imagesc(dataL);
axis off;
cooljet3(max(dataL(:)));

figure(4)
imagesc(R2);
axis off;
cooljet3(max(R2(:)));

figure(5)
imagesc(Vimage);
colormap parula;

%% Active contour doodling

% test with normal images
plainRed = dataBin(:,:,1);
plainGreen = dataBin(:,:,2);
plainBlue = dataBin(:,:,3);

im = bitor(plainGreen, plainBlue);
%
mask = plainRed==0;
BW = activecontour(im, mask, 200, 'edge'); % ... or Chan-Vese

% test with binary images
close all;
plainRed = dataBin(:,:,1)>0;
plainGreen = dataBin(:,:,2);
plainBlue = dataBin(:,:,3);

im = bitor(plainGreen, plainBlue);

%
mask = plainRed==0;
BW2 = activecontour(im, mask, 275, 'edge'); % ... or Chan-Vese
%
se2 = strel('disk',4);
BW3 = imopen(BW2==0,se2);
%%

regs2 = regionprops('table',BW3,'Area','Centroid',...
    'MajorAxisLength','MinorAxisLength');
area = sort([regs2.Area]);
BW4 = bwareafilt(BW3,[0 area(end-1)]);

se3 = strel('disk',5);
BW5 = imopen(BW4,se3);
regs3 = regionprops('table',BW5, 'Area', 'Centroid',...
    'MajorAxisLength','MinorAxisLength');
area2 = sort([regs3.Area]);

imagesc(bwlabeln(BW5));
% need to work on the removal of noise. This could be done by analysing the
% shape or something like it. 
%% Finding green cells that do not have a red nuclei

% 
close all;
clc;
plainRed = dataBin(:,:,1)>0;
plainGreen = dataBin(:,:,2)>0;
plainBlue = dataBin(:,:,3)>0;

fakeRed = plainRed;

im = bitor(plainGreen, plainBlue);

% initial finding of voronoi diagram

regs = regionprops('table', fakeRed, 'Centroid', 'Area', ...
    'MajorAxisLength','MinorAxisLength');
XY = regs.Centroid;
mNucleiSize = min(regs.Area);

[V,C] = voronoin(XY);
[Vimage, subImage] = voronoizone(XY(:,1), XY(:,2), im); 

n=size(regs,1);
se = strel('disk',5);

%indx=10;
for indx=1:n
    binImage = bitand(im,Vimage==indx);
    %imagesc(imopen(binImage,se));
    binImage = bwareafilt(binImage,[mNucleiSize, Inf]);
    
    binRegs = regionprops('table',binImage);
    
    area = binRegs.Area;
    centroids = binRegs.Centroid;
    
    testDistance = zeros(size(binRegs,1),1);
    if size(binRegs,1)>1
        for j=1:size(binRegs,1)
            centroidTest = repmat(centroids(j,:),size(XY,1),1);
            distance = XY-centroidTest;
            norms = diag(sqrt(distance*distance'));
            testMinDistance(j) = min(norms);
        end
        [~,maxDistIndx] = max(testMinDistance);
        [artificialNuclei1, fakeRed] = getArtificialNuclei(fakeRed,...
            centroids(maxDistIndx,:),mNucleiSize);
    end
end

fakeRegs = regionprops('table', fakeRed, 'Centroid', 'Area', ...
    'MajorAxisLength','MinorAxisLength');
XY = fakeRegs.Centroid;

[Vimage, subImage] = voronoizone(XY(:,1), XY(:,2), im); 

mNucleiSize = min(fakeRegs.Area);

[V,C] = voronoin(XY);
[Vimage, subImage] = voronoizone(XY(:,1), XY(:,2), im); 

n=size(regs,1);
se = strel('disk',5);

%indx=10;
for indx=1:n
    binImage = bitand(im,Vimage==indx);
    %imagesc(imopen(binImage,se));
    binImage = bwareafilt(binImage,[mNucleiSize, Inf]);
    
    binRegs = regionprops('table',binImage);
    
    area = binRegs.Area;
    centroids = binRegs.Centroid;
    
    testDistance = zeros(size(binRegs,1),1);
    if size(binRegs,1)>1
        for j=1:size(binRegs,1)
            centroidTest = repmat(centroids(j,:),size(XY,1),1);
            distance = XY-centroidTest;
            norms = diag(sqrt(distance*distance'));
            testMinDistance(j) = min(norms);
        end
        [~,maxDistIndx] = max(testMinDistance);
        [artificialNuclei1, fakeRed] = getArtificialNuclei(fakeRed,...
            centroids(maxDistIndx,:),mNucleiSize);
    end
end

fakeRegs = regionprops('table', fakeRed, 'Centroid', 'Area', ...
    'MajorAxisLength','MinorAxisLength');
XY = regs.Centroid;

[V,C] = voronoin(XY);
[Vimage, subImage] = voronoizone(XY(:,1), XY(:,2), im); 

n=size(fakeRegs,1);
dataL = zeros(size(dataBin(:,:,1)));
mNucleiSize = min(regs.Area);

labels = getPrimes(n);

for indx=1:n
    binImage = bitand(im,Vimage==indx);
    binImage = bwareafilt(binImage,[mNucleiSize, Inf]);
    dataL=dataL+labels(indx).*binImage;

end
