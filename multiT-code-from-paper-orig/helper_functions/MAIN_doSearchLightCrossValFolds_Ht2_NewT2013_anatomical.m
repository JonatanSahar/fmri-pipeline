function MAIN_doSearchLightCrossValFolds_Ht2_NewT2013_anatomical(subnum)
% get params 
params = get_and_set_params();
% load data / file naming / saving 
datadir = fullfile('..','..','data','stats_normalized_sep_beta_ar3'); 
fn = sprintf('data_%.3d.mat',subnum);
load(fullfile(datadir,fn));
fnTosave = sprintf('results_VocalDataSet_anatomical_FFX_ND_norm_%d-shuf_sub_-%.3d_',...
                    params.numShuffels,subnum);
resultsdir = fullfile('..','..','results'); 
resultsDirName = fullfile(resultsdir,sprintf('results_VocalDataSet_anatomical_FFX_ND_norm_%d-shuf',...
                            params.numShuffels));
mkdir(resultsDirName);
% pre compute values 
start = tic;
% load anatomcal idxs  
load('idxs_from_havard_cambridge_atlas.mat'); 
idx = knnsearch(locations, locations, 'K', params.regionSize); % find searchlight neighbours 
shufMatrix = createShuffMatrixFFX(data,params);

%% loop on all voxels in the brain to create T map
for i = 1:(params.numShuffels + 1) % loop on shuffels 
    %don't shuffle first itiration
    if i ==1 % don't shuffle data
        labelsuse = labels;
    else % shuffle data
        labelsuse = labels(shufMatrix(:,i-1));
    end
    idxX = find(labelsuse==1);
	idxY = find(labelsuse==2);
    for j=1:size(idxsout,1) % loop on voxels 
        dataX = removezeros( data(idxX,idxsout{j,1}) );
        dataY = removezeros( data(idxY,idxsout{j,1}) );
        [ansMat(j,i,:) ] = calcTstatMuniMengTwoGroup(dataX,dataY);
        if isnan(ansMat(j,i,:))
            x=2;
        end
    end
    timeVec(i) = toc(start); reportProgress(fnTosave,i,params, timeVec);
end
fnOut = [fnTosave datestr(clock,30) '_.mat'];
save(fullfile(resultsDirName,fnOut));
msgtitle = sprintf('Finished sub %.3d ',subnum);
end
