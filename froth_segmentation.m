"""
Author: Dr. Jin Zhang 
E-mail: j.zhang.vision@gmail.com
Created on 2022.02.20
"""


clc;
clear all
close all


%%
filename = 'L:/FrothVideo/20160601000012.avi'; 
Obj = VideoReader(filename);
nFrames = Obj.NumberOfFrames;
vidHeight = Obj.Height;     vidWidth = Obj.Width;
step = 15*2; 
start = 1+step*6;     ending = nFrames;
Options.upright=true;
Options.tresh=0.0001;
feature = [];
for k = start:step:ending
    im = read(Obj, k);
    close all
    
    I = im2double(rgb2gray(im));
    temp = mapminmax(I(:)', 0, 1);
    I = reshape(temp, size(I));
    I = imresize(I, [600,800]);
    filter = fspecial('average', 3);
    I = imadjust(I);
    I = imfilter(imadjust(I), filter);
    figure, imshow(I)
        
    se = strel('disk', 3);
    Ioc = imopen(I, se);
    Iobr = imreconstruct(Ioc, I);
    
    Iobrd = imclose(Iobr, se);
    % Iobrcbr = imreconstruct(Iobr, Iobrd);
    Iobrcbr = imreconstruct(Iobrd, Iobr);
    % figure, imshow(Iobrcbr),    title('Iobrcbr image');

    Iec_minimal = imadjust(imcomplement(Iobrcbr));
    figure, imshow(Iec_minimal, []);
    flag_minimal = imextendedmin(Iec_minimal,30/255);   
    Iec_minimal = imimposemin(Iec_minimal,flag_minimal);
    DL = watershed(Iec_minimal);
    ridges_minimal = DL==0;
    ridges_minimal = bwmorph(ridges_minimal, 'bridge');
    I(ridges_minimal)=255;
    figure, imshow(I)%, title('minimal seg image');
    
end

