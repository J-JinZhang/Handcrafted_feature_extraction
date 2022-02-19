%%
clc;
clear all
close all


%%
filename = 'L:/FrothVideo/201791/20170901000039.avi'; 
Obj = VideoReader(filename);
nFrames = Obj.NumberOfFrames;
vidHeight = Obj.Height;     vidWidth = Obj.Width;
step = 15*2; %有15个重复帧
% start = 1+step0*13;     ending = nFrames-step0*0;        %test
% start = nFrames-600-step0*0;     ending = nFrames;      %test
start = 1+step*6;     ending = nFrames;
Options.upright=true;
Options.tresh=0.0001;
feature = [];
for k = start:step:ending
    im = read(Obj, k);
    close all
    % im = imread('D:/泡沫图像分割样本/锌/3.BMP');
    I = im2double(rgb2gray(im));
    temp = mapminmax(I(:)', 0, 1);
    I = reshape(temp, size(I));
    I = imresize(I, [600,800]);
    filter = fspecial('average', 3);
    I = imadjust(I);
    I = imfilter(imadjust(I), filter);
    figure, imshow(I)
        
    %%  图像增强  %%
    % 开重构：先腐蚀再重构
    se = strel('disk', 3);
    Ioc = imopen(I, se);
    Iobr = imreconstruct(Ioc, I);
    % 对开重构后的图像进行闭重构：先膨胀再重构
    Iobrd = imclose(Iobr, se);
    % Iobrcbr = imreconstruct(Iobr, Iobrd);
    Iobrcbr = imreconstruct(Iobrd, Iobr);
    % figure, imshow(Iobrcbr),    title('Iobrcbr image');     %%%% 开闭滤波图像

    %%  标签引导下的分水岭分割  %%
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

