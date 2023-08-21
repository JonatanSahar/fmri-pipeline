function MAIN_doSearchLight_Directional_basedOnFFX_ND_stelzer_perms()
% This function uses previously run ND-FFX shuf matrices
% And runs a Directional FFX searchlight
subsToExtract = [20,150];
slsize = 27;
[fn,pn] = uigetfile('ND*.mat');
load(fullfile(pn,fn));
numshufs = 100;
numstlzrshufs = size(stlzerPermsAnsMat,2);
ffxResFold = 'F:\vocalDataSet\processedData\matFilesProcessedData\vocalDataSetResults\results_VocalDataSet_FFX_ND_norm_1000shuf_SL27_reg_perm_ar3';
resultsDir  = ffxResFold;
params = getParams;
params.numShuffels = numstlzrshufs-1;
params.regionSize = slsize;


subsToExtract = 20;
start = tic;
pool = parpool('local',7);
for i = 1:length(subsToExtract) % loop on fold 20 / 150 subjects
    substorun = subsUsedGet(subsToExtract(i)); % 150 / 20 for vocal data set
    fnTosave = ['DR' fn(3:end)];
    timeVec = [];
    for k = 1:numstlzrshufs % loop on shuffels
        for s = 1:length(substorun) % get data from each subject
            % find the data for this subject:
            ff = findFilesBVQX(ffxResFold,sprintf('*sub_%.3d*.mat',substorun(s)));
            load(ff{1},'data','mask','labels','shufMatrix','locations');
            %don't shuffle first itiration
            if k ==1 % don't shuffle data
                labelsuse = labels;
            else % shuffle data
                labelsuse = labels(shufMatrix(:,stlzerPermsAnsMat(s,k)-1));
            end
            dataX = mean(data(labelsuse==1,:),1); % mean delta x
            dataY = mean(data(labelsuse==2,:),1); % mean delta y
            delta(s,:) = dataX-dataY;
            % get delta data from each subject according to the shuff matrix
        end
        
        idx = knnsearch(locations, locations, 'K', slsize);
        parfor j=1:size(idx,1) % loop onvoxels
            deltabeam = delta(:,idx(j,:));
            [ansMat(j,k,:) ] = calcTstatAll([],deltabeam);
        end
        clc
        timeVec(k) = toc(start); reportProgress(fnTosave,k,params, timeVec);
    end
    
    pval = calcPvalVoxelWise(squeeze(ansMat(:,:,1)));
    SigFDR = fdr_bh(pval,0.05,'pdep','no');
    ansMatReal = squeeze(ansMat(:,1,1));
    subsExtracted = substorun;
    save(fullfile(resultsDir,fnTosave),...
        'ansMat','ansMatReal','pval',...
        'locations','mask','fnTosave','subsExtracted','SigFDR');
end
delete(pool);    
end
