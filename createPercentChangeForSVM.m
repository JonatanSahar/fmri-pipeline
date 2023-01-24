function params = createPercentChangeForSVM(params)
if ~exist(params.outDir)
    mkdir(params.outDir)
end
rng(params.seed);

%% load mask and split to beams
maskImg.data=niftiread(fullfile(params.mask.dir,params.mask.name));
maskImg.info=niftiinfo(fullfile(params.mask.dir,params.mask.name));
linearIndex=find(maskImg.data);
[x,y,z]=ind2sub(size(maskImg.data),linearIndex);
locations=[x,y,z];
idx = knnsearch(locations, locations, 'K', params.beamSize); % Find all neighbours in the mask
%% load data for each condition and create svm files
for session = 1:length(params.conditions)
    for con=1:length(params.conditions{session})
        cond=params.conditions{session}{con};
        if strcmp(params.conditions{session}{con},params.localizerName)
            continue
        end
        for s=1:length(params.subjects)
            tic
            disp(['analysing sub ', num2str(params.subjects(s)),' session ' ,num2str(session) , ' condition ', params.conditions{session}{con}]);
            if ~exist(fullfile(params.outDir,[num2str(params.subjects(s)),'_',cond,params.saveName]),'file') || params.override
                rh=1; %%zero counter!
                lh=1; %%zero counter!
                data_rh=zeros(10,size(linearIndex,1));
                data_lh=zeros(10,size(linearIndex,1));
                EV_dir=fullfile(params.mainDir,params.expName,num2str(params.subjects(s)),['session',num2str(session)],'EVs');
                for r=1:params.numOfRuns
                    disp(['run ',num2str(r)])
                    runDir=fullfile(params.mainDir,params.expName,num2str(params.subjects(s)),['session',num2str(session)],params.functionalFolder,cond,['sub',num2str(params.subjects(s)),'run',num2str(r),'.feat']);
                    if ~exist(fullfile(runDir,'filtered_func_data_MNI.nii.gz'),'file') ||params.override
                        cmd = ['applywarp -i ', (fullfile(runDir,'filtered_func_data.nii.gz')),' -o ', (fullfile(runDir,'filtered_func_data_MNI.nii.gz')), ' -r ', fullfile(runDir,'reg','standard'), ' --warp=' ,fullfile(runDir,'reg','highres2standard_warp'),' --premat=',fullfile(runDir,'reg','example_func2highres.mat')];
                        unix(cmd);
                        disp(['finished MNI transform for sub ', num2str(params.subjects(s)),' ',cond,' condition run ',num2str(r)]);
                    else
                        disp(['MNI transform for sub ', num2str(params.subjects(s)),' ',cond,' condition run ',num2str(r),' already exist']);
                        
                    end
                    funcData=niftiread(fullfile(runDir,'filtered_func_data_MNI.nii.gz'));
                    funcInfo=niftiinfo(fullfile(runDir,'filtered_func_data_MNI.nii.gz'));
                    percentChangeData=funcData./mean(funcData,4)*100-100;
                    %             if any(any(any(any(percentChangeData==0))))
                    %                zeroLocs=find(percentChangeData==0);
                    %                disp(['this scan has ', num2str(length(zeroLocs)),' zero voxels']);
                    %                percentChangeData(zeroLocs)=0.00001;
                    %             end
                    for h=1:length(params.laterality)
                        fid = fopen(fullfile(EV_dir, [num2str(params.subjects(s)),cond,num2str(r),params.laterality{h},'.txt'])) ;
                        Y = fgetl(fid);
                        while ischar(Y)
                            X=strsplit(Y);
                            TR=floor(str2double(X{1}))+params.TRafterStart;
                            Y = fgetl(fid);
                            data_all=percentChangeData(:,:,:,TR);
                            
                            if params.savenii
                                if ~exist([params.outDir,'/',num2str(params.subjects(s))],'dir')
                                    unix(['mkdir ',params.outDir,'/',num2str(params.subjects(s))]);
                                end
                                if params.useMasking
                                    niftiwrite(single(data_all.*maskImg.data),fullfile(params.outDir,num2str(params.subjects(s)),[cond,params.laterality{h},num2str(rh)]),maskImg.info);
                                else
                                    niftiwrite(single(data_all),fullfile(params.outDir,num2str(params.subjects(s)),[cond,params.laterality{h},num2str(rh)]),maskImg.info);
                                end
                            end
                            
                            if h==1
                                data_rh(rh,:)=data_all(linearIndex);
                                rh=rh+1;
                            else
                                data_lh(lh,:)=data_all(linearIndex);
                                lh=lh+1;
                            end
                        end
                        fclose(fid);
                    end
                end
                RH=size(data_rh,1);
                LH=size(data_lh,1);
                if RH>LH
                    num_to_trim=RH-LH;
                    smp = datasample(1:RH,num_to_trim,'Replace',false);
                    locs=1:RH;
                    locs(smp)=0;
                    data_rh=data_rh(locs>0,:);
                    clear locs
                    RH=LH;
                    if params.savenii
                        if length(smp)==1
                            unix(['rm ', fullfile(params.outDir,num2str(params.subjects(s)),[cond,params.laterality{1},num2str(smp),'.nii'])]);
                        else
                            for smpl=1:length(smp)
                                unix(['rm ', fullfile(params.outDir,num2str(params.subjects(s)),[cond,params.laterality{1},num2str(smpl),'.nii'])]);
                            end
                        end
                    end
                elseif LH>RH
                    num_to_trim=LH-RH;
                    smp = datasample(1:LH,num_to_trim,'Replace',false);
                    locs=1:LH;
                    locs(smp)=0;
                    data_lh=data_lh(locs>0,:);
                    clear locs
                    LH=RH;
                    if params.savenii
                        if length(smp)==1
                            unix(['rm ', fullfile(params.outDir,num2str(params.subjects(s)),[cond,params.laterality{2},num2str(smp),'.nii'])]);
                        else
                            for smpl=1:length(smp)
                                unix(['rm ', fullfile(params.outDir,num2str(params.subjects(s)),[cond,params.laterality{2},num2str(smpl),'.nii'])]);
                            end
                        end
                    end
                else
                    smp=0;
                end
%                 params.disq{s}=smp;
                data1=[data_rh;data_lh];
                labels=[ones(RH,1);ones(LH,1)*2];
                
                factor=ones(1,length(labels));
                data=zeros(length(labels),params.beamSize,length(linearIndex));
                for i=1:length(linearIndex)
                    data(:,:,i)=data1(:,idx(i,:));
                end
                save(fullfile(params.outDir,[num2str(params.subjects(s)),'_',cond,params.saveName]),...
                    'data', 'factor','labels','locations','linearIndex','params','maskImg','-v7.3');
            end
            disp(['finished subject ',num2str(params.subjects(s)),' ',cond,' in ',num2str(toc), 's']);
        end
    end
end