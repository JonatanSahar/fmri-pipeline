function singleSubjectMultiT(subject,condition, tMapName, P)
    % percent signal change output variables: "data_all_LE", "data_all_RE", "labels_all_LE", "labels_all_RE"
    % saved in "subId_multiT_data_and_labels.mat"
    % ⇒ condition must be one of "LE", "RE"
    addpath("./helper_functions");
    % dataDir=P.dataDir;
    % TODO: ask Shahar
    dfile=dir(fullfile(P.multiResDirName,sprintf("%d_%s_%d_shuffels.mat", subject, condition, P.numShuffels)));
    if isempty(dfile)
        %% load mask
        % TODO: ask Shahar - is the PSC matrix not already clipped to the MNI brain? It went through applywarp
        niidata=niftiread(P.multiTMNIMask);
        niiheader=niftiinfo(P.multiTMNIMask);
        % This is the mapping between (brain, mask=1) voxels in 3D and their linear index in each row of the data=trialsXvoxels
        % the matrix
        linearIndex=find(niidata);
        [x,y,z]=ind2sub(size(niidata),linearIndex);
        locations=[x,y,z];
        % [linearIndex, locations ] = getLocationsFromMaskNii(niidata);
        % resultsDirName=P.multiResDirName;

        if ~exist(P.multiResDirName)
            mkdir(P.multiResDirName)
        end

        %% load PC data for one subject
        %If analyzing pc
        % data_loc=P.multiDataLoc;

        t = load(fullfile(P.multiDataLoc,sprintf("%d_multiT_data_and_labels.mat", subject)));
        labelsF=sprintf("labels_%s", condition);
        dataF=sprintf("data_%s", condition);
        labels = t.(labelsF);
        cond_data = t.(dataF);

        data   = zeros(size(cond_data,4),size(locations,1)); % initizlie data

        % load mask data from 3d:
        for t = 1:size(cond_data,4)
            t_data=squeeze(cond_data(:,:,:,t));
            peflat=t_data(linearIndex); % this is one row in our data matrix
            data(t,:)=peflat;
        end


        % this is how you use searchlight to itirate over all rows.
        idx = knnsearch(locations, locations, 'K', P.regionSize); % neighbours

        shufMatrix = createShuffMatrixFFX(data, P);
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
            % loop on voxels, collect the neighbourhood of each based on its labels
            for j=1:size(idx,1)
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
        outFilename = sprintf("%d_%s_%s_%d_shuffels", subject, condition, datestr(clock,30), P.numShuffels);
        save(fullfile(P.multiResDirName,outFilename), "ansMat", "linearIndex", '-v7.3');

        %%
        % figure;histogram(ansMat);
        % return;

        %% move results back to 3d:
        tMapImage = zeros(size(niidata));
        tMapImage(linearIndex) = single(ansMat(:,1));
        % mulTout_dir=fullfile(dataDir,num2str(subject) ,'/derive/multiTres_pc_2.4.20');
        if ~exist(P.multiout_dir)
            mkdir(P.multiout_dir);
        end

        outfile=fullfile(P.multiout_dir,tMapName)
        % save_untouch_nii(niifile,outfile);
        niftiwrite(single(tMapImage), outfile, niiheader, 'Compressed',true)
        fprintf("finished subject no. %d, condition: %s", subject, condition);
    end
end
