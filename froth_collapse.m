"""
Author: Dr. Jin Zhang 
E-mail: j.zhang.vision@gmail.com
Created on 2022.02.22
"""

%%
clc;
clear all
close all


im_a = imresize( imread(fullfile(tmp_folder_3, name_a)), [300,300]);
    
im_a_ = im2double( rgb2gray( imresize( imread(fullfile(tmp_folder_3, name_a_)), [300,300]) ));

diff_a = im2double(rgb2gray(im_a));

Ipts_Base = OpenSurf(diff_a(1:scale,:,:),Options);
Desp_Base = reshape([Ipts_Base.descriptor],64,[]);

Err_Set_value = [];
for location = intervals
    Ipts_Dect = OpenSurf(im_a_(location+1:location+scale,:,:),Options);
    Desp_Dect = reshape([Ipts_Dect.descriptor],64,[]);
    DespErr = [];
    Coor_Min = [];
    for k=1:length(Ipts_Base)
        Dist_Desp = sum((Desp_Dect-repmat(Desp_Base(:,k),[1 length(Ipts_Dect)])).^2,1);
        [DespErr(end+1),Coor_Min(end+1)]=min(Dist_Desp);
    end
    Err_Frame = sort(DespErr);
    Err_Set_value(end+1) = sum(Err_Frame(1:length(Ipts_Base)*0.7));
end
[val, index] = min(Err_Set_value);
if rem(index,length(intervals))~=0
    speed = intervals(rem(index,length(intervals)));
else
    speed = intervals(end);
end
load_a = im_a_(speed:end,:) - diff_a(1:301-speed,:);
collapse_mask_a = load_a>=0.5;
collapse_a = sum(collapse_mask_a(:))/numel(collapse_mask_a)*10;
