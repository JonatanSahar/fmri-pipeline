function calcPvalsAllSubs_ar3()
rootdir = fullfile('..','..','results','results_VocalDataSet_anatomical_AR6_FFX_ND_norm_100-shuf');

ff = findFilesBVQX(rootdir,'re*.mat');
for i = 1:length(ff) % loop on files
    load(ff{i},'ansMat','locations','mask','subnum');
    ansMat = squeeze(ansMat(:,:,1)); % first val is multi t 2013
    fprintf('B = sub %d has %d nans\n',i,sum(isnan(median(ansMat,2))))
    modeuse = 'anatomical'; % modes to deal with zeros also 'equal-zero', 'equal-min' and 'weight'
    ansMat = squeeze(ansMat(:,:,1)); % first val is multi t 2013
    fixedAnsMat = fixAnsMat(ansMat,locations,modeuse); % fix ansMat for zeros
    ansMat = fixedAnsMat;
    fprintf('A = sub %d has %d nans\n',i,sum(isnan(median(ansMat,2))))
    pval = calcPvalVoxelWise(ansMat);
    allpvals(:,i) = pval;
    subnums(i) = subnum;
end
save(fullfile(rootdir,'allPvals_FIR_ar6_150subs.mat'),'allpvals','subnums');
end