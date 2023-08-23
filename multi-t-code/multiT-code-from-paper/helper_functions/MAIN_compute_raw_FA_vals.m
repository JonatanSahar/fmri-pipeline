function MAIN_compute_raw_FA_vals()
% This function creates raw FA vals and makes a VMP out of them.

subsToExtract = [20,150];
slsize = 27;
numshufs = 100;
ffxResFold = 'F:\vocalDataSet\processedData\matFilesProcessedData\vocalDataSetResults\results_VocalDataSet_FFX_ND_norm_100shuf_SL27_reg_perm_ar3';
resultsDir  = ffxResFold;
params = getParams;
params.numShuffels = numshufs;
params.regionSize = slsize;
params.numShuffels = numshufs;


subsToExtract = 20;
for i = 1:length(subsToExtract) % loop on fold 20 / 150 subjects
    substorun = subsUsedGet(subsToExtract(i)); % 150 / 20 for vocal data set
    timeVec = [];    fnTosave = sprintf('RAW_FA_VALS_ar3_%d-subs_%d-slsize.mat',...
        slsize,subsToExtract(i));

    for s = 1:length(substorun) % get data from each subject
        % find the data for this subject:
        ff = findFilesBVQX(ffxResFold,sprintf('*sub_%.3d*.mat',substorun(s)));
        load(ff{1},'data','mask','labels','shufMatrix','locations');
        labelsuse = labels; % just real data no shuffle 
        
        dataX = mean(data(labelsuse==1,:),1); % mean delta x
        dataY = mean(data(labelsuse==2,:),1); % mean delta y
        delta(s,:) = dataX-dataY;
        % get delta data from each subject according to the shuff matrix
    end
    idx = knnsearch(locations, locations, 'K', slsize);
    for j=1:size(idx,1) % loop onvoxels
        deltabeam = delta(:,idx(j,:));
        % delta beam for FA computation should be sphers x subs (hence
        % transpose) 
        [rawFA(j) ] = calcClumpingIndexSVDNoDemeaning(deltabeam');
        [rawFANonCentered(j) ] = calcClumpingIndexSVD(deltabeam');
    end
    save(fullfile(resultsDir,f  nTosave),...
        'rawFA','rawFANonCentered',...
        'locations','mask','fnTosave','substorun');
    % create and save VMP with FA val
    n = neuroelf;
    vmp = n.importvmpfromspms(fullfile(pwd,'temp.nii'),'a',[],3);
    mapstruc = vmp.Map;
    vmpdat = scoringToMatrix(mask,double(rawFA'),locations); % note that SigFDR must be row vector
    vmp.Map.VMPData = vmpdat;
    vmp.Map(1).LowerThreshold = min(vmpdat(:));
    vmp.Map(1).UpperThreshold = max(vmpdat(:));
    vmp.Map(1).UseRGBColor = 0;
    vmp.SaveAs(fullfile(resultsDir,[fnTosave(1:end-4),'.vmp']));
    vmp.ClearObject;
    clear vmp;
end



end