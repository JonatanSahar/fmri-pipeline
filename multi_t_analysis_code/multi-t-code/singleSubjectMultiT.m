
function singleSubjectMultiT(subject,condition,numShuffels)
    % percent signal change output variables: "data_all_LE", "data_all_RE", "labels_all_LE", "labels_all_RE"
    % saved in "subId_multiT_data_and_labels.mat"
    % ⇒ condition must be one of "LE", "RE"
    P.regionSize      = 27; % sl size
    P.numShuffels     =numShuffels;
    P.multiResDirName=fullfile("../multi-t-results");
    P.TmapName=sprintf("%d_%s_%d_shuffels", subject, condition, numShuffels);
    P.dataDir=fullfile(pwd,"../multi-t-data");
    P.multiDataLoc=p.dataDir;
    P.multiout_dir=P.multiResDirName;
    addpath("../multit/code/helper_functions");
    %addpath('neuroelf');
    addpath(fullfile("../../niiTool"));
    % dataDir=P.dataDir;
    % TODO: ask Shahar
    dfile=dir(fullfile(P.multiResDirName,[subject condition '*' '_' num2str(numShuffels) '.mat']));
    if isempty(dfile)
        %% load mask
        % TODO: ask Shahar - is the PSC matrix not already clipped to the MNI brain? It went through applywarp
        maskfn = fullfile(P.dataDir,"standard_MNI_mask.nii.gz");
        niifile = load_untouch_nii(maskfn);
        niidata =  niifile.img;
        [lidx, locations ] = getLocationsFromMaskNii(niidata);
        % resultsDirName=P.multiResDirName;

        if ~exist(P.multiResDirName)
            mkdir(P.multiResDirName)
        end
        %% load pe data for one subject
        % %If analyzing pe
        %
        % % data_loc=fullfile(dataDir,num2str(subject),'/derive/PEs/zscore_PEs/all_z_PEs');
        % data_loc=fullfile(dataDir,num2str(subject),'/derive/PEs/multi_MNI_PEs/all_PEs_MNI');
        % l=load(fullfile(data_loc, [condition '_labels.mat']));
        % labels=l.(char(fieldnames(l)));
        % condList=load(fullfile(data_loc, [condition '_list.mat']));
        % peList=condList.(char(fieldnames(condList)));
        %
        % pefnms = findFilesBVQX(data_loc,peList);
        % data   = zeros(size(pefnms,1),size(locations,1)); % initizlie data
        % % load mask data from 3d:
        % for p = 1:length(pefnms)
        %     niifile = load_untouch_nii(pefnms{p});
        %     pedata = niifile.img;
        %     peflat  = pedata(lidx); % this is one row in our data matrix
        %     data(p,:)  =  peflat;
        % end

        %% load PC data for one subject
        %If analyzing pc
        % data_loc=P.multiDataLoc;

        t = load(fullfile(P.multiDataLoc,sprintf("%d_multiT_data_and_labels.mat", subId, condition)));
        labels=sprintf("t.labels_all_%s", condition);
        cond_data=sprintf("t.data_all_%s", condition);

        data   = zeros(size(cond_data,4),size(locations,1)); % initizlie data

        % load mask data from 3d:
        for t = 1:size(cond_data,4)
            t_data=squeeze(cond_data(:,:,:,t));
            peflat=t_data(lidx); % this is one row in our data matrix
            data(t,:)=peflat;
        end


        % this is how you use searchlight to itirate over all rows.
        idx = knnsearch(locations, locations, 'K', P.regionSize); % neighbours

        shufMatrix = createShuffMatrixFFX(data,params);
        %% start searchlight
        % check data for zeros
        labelsuse = labels;
        idxX = find(labelsuse==1);
        idxY = find(labelsuse==0);
        %% checks if there are any zeros in the data
        for j=1:size(idx,1) % loop on voxels
            dataX = data(idxX,idx(j,:));
            dataY = data(idxY,idx(j,:));
            xzeros(j) = sum(sum(dataX,1) == 0);
            yzeros(j) = sum(sum(dataX,1) == 0);
        end
        if max(xzeros(xzeros~=0)) == P.regionSize
            error('in your data x you %d have voxels with zeros')
            disp('\n %d search light with zeros  in x\n',...
                 sum(xzeros==P.regionSize));
            disp('\n %d x voxels with at least 1 zero voxel\n',...
                 sum(xzeros~=0));
        end
        if max(yzeros(yzeros~=0)) == P.regionSize
            error('in your data x you %d have voxels with zeros')
            disp('\n %d search light with zeros  in y\n',...
                 sum(yzeros==P.regionSize));
            disp('\n %d y voxels with at least 1 zero voxel\n',...
                 sum(yzeros~=0));
        end
        %% loop on all voxels in the brain to create T map
        start = tic;
        for i = 1:(P.numShuffels + 1) % loop on shuffels
                                           %don't shuffle first itiration
            if i ==1 % don't shuffle data
                labelsuse = labels;
            else % shuffle data
                labelsuse = labels(shufMatrix(:,i-1));
            end
            idxX = find(labelsuse==1);
            idxY = find(labelsuse==0);
            for j=1:size(idx,1) % loop on voxels
                dataX = data(idxX,idx(j,:));
                dataY = data(idxY,idx(j,:));
                [ansMat(j,i) ] = calcTstatMuniMengTwoGroup_v2(dataX,dataY);

            end
            timeVec(i) = toc(start);
            if mod(i,20)==0 || i==1
                disp(i);
            end
            %      reportProgress(fnTosave,i,params, timeVec);
        end
        timing=toc(start);
        fnOut = [subject,condition, datestr(clock,30) 'withShuffling_' num2str(P.numShuffels) '.mat'];
        save(fullfile(P.multiResDirName,fnOut));%,'-v7.3');
                                                     % msgtitle = sprintf('Finished sub %.3d ',subnum);

        %%
        % figure;histogram(ansMat);
        % return;

        %% move results back to 3d:
        zeroimag = zeros(size(niidata));
        zeroimag(lidx) = ansMat(:,1);
        niifile.img = zeroimag;
        % mulTout_dir=fullfile(dataDir,num2str(subject) ,'/derive/multiTres_pc_2.4.20');
        if ~exist(P.multiout_dir)
            mkdir(P.multiout_dir);
        end

        outfile=fullfile(P.multiout_dir,P.TmapName)
        save_untouch_nii(niifile,outfile);
    end
end
