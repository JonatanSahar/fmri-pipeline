%% load data
dataLoc_lvf=fullfile('..','LVFcorbin.nii.gz');
niidata=load_untouch_nii(dataLoc_lvf);
data_lvf=niidata.img;
dataLoc_rvf=fullfile('..','RVFCorbin.nii.gz');
niidata=load_untouch_nii(dataLoc_rvf);
data_rvf=niidata.img;

numsifvoxels_lvf=sum(sum(sum(data_lvf)));
numsifvoxels_rvf=sum(sum(sum(data_rvf)));

overlap=data_lvf.*data_rvf;
numofvoxels_overlap=sum(sum(sum(overlap)));

percent_overlap=[ numofvoxels_overlap/numsifvoxels_lvf , numofvoxels_overlap/numsifvoxels_rvf]