condition={'RVF','LVF'};
for cond=1:2
if cond==1
    load('../results/2nd_level/ND_FFX_VDS_24-subs_27-slsze_1-fld_400shufs_10000-stlzer_mode-equal-min_newT2013_RVF.mat');
    maskfn = fullfile('..','data','raw_data','LV1_mask.nii.gz');
else
    load('../results/2nd_level/ND_FFX_VDS_22-subs_27-slsze_1-fld_400shufs_10000-stlzer_mode-equal-min_newT2013_LVF.mat');
    maskfn = fullfile('..','data','raw_data','RV1_mask.nii.gz');
end
%% load visual mask
niifile_roi = load_untouch_nii(maskfn);
niidata_roi =  niifile_roi.img;
[lidx_roi, locations_roi ] = getLocationsFromMaskNii(niidata_roi);
%%load common mask
maskfn = fullfile('..','data','raw_data',['commonAllSubs',condition{cond},'.nii.gz']);
niifile = load_untouch_nii(maskfn);
niidata =  niifile.img;
[lidx, locations ] = getLocationsFromMaskNii(niidata);
rel_idx=intersect(lidx_roi,lidx);
for i=1:5000
    zeroimag = zeros([91,109,91]);
    alldataimg(lidx) = avgAnsMat(:,i+1);
    maskeddataimg=zeros([91,109,91]);
    maskeddataimg(rel_idx)=alldataimg(rel_idx);
    max_t(i)=max(max(max(maskeddataimg)));
end
real_ts=zeros([91,109,91]);
real_ts(lidx)= avgAnsMat(:,1);
maskedrealts=zeros([91,109,91]);
maskedrealts(rel_idx)=real_ts(rel_idx);
maskedrealts_flat=real_ts(rel_idx);
for k=1:length(maskedrealts_flat)
    pvals(k)=mean(maskedrealts_flat(k)>=max_t);
end
    zeroimag = zeros([91,109,91]);
    zeroimag(rel_idx) = pvals;
    niifile_roi.img = zeroimag;
    save_untouch_nii(niifile_roi,['FWER_',condition{cond}]);
    clear pvals max_t lidx lidx_roi rel_idx
end
