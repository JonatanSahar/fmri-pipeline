function pc_funcData=percentChange_correct(outDir,fname)
%this function normalizes functional data from each run and saves it in a
%new pc_data dir

%     cmd=['cp -r ',runDir, ' ', outDir]; %copy feat dir with fitered func data file
%     unix(cmd)
%     cmd=['rm -r ',fullfile(outDir,['multi_run' num2str(r) '.feat'],'filtered_func_data.nii.gz')];% remove func_data
%     unix(cmd)

%         if ~exist(fullfile(runDir,'filtered_func_data_MNI.nii.gz'))
%             cmd = ['applywarp -i ', (fullfile(runDir,'filtered_func_data.nii.gz')),' -o ', (fullfile(runDir,'filtered_func_data_MNI.nii.gz')), ' -r ', fullfile(runDir,'reg','standard'), ' --warp=' ,fullfile(runDir,'reg','highres2standard_warp'),' --premat=',fullfile(runDir,'reg','example_func2highres.mat')];
%             unix(cmd);
%         end

funcData=niftiread(fullfile(outDir,fname));
funcInfo=niftiinfo(fullfile(outDir,fname));
                    if any(any(any(any(funcData==0))))
                       zeroLocs=find(funcData==0);
                       disp(['this scan has ', num2str(length(zeroLocs)),' zero voxels']);
                       funcData(zeroLocs)=0.00001;
                    end
pc_funcData=zeros(size(funcData));
for x=1:size(funcData,1)
    for y=1:size(funcData,2)
        for z=1:size(funcData,3)
        pc_funcData(x,y,z,:)=(funcData(x,y,z,:)/mean(squeeze(funcData(x,y,z,:)))).*100-100;

        end
    end
end

pc_funcData=single(pc_funcData);


% save(fullfile(outDir,['pc_native' fname]),'pc_funcData','funcInfo','-v7.3')
niftiwrite(pc_funcData,fullfile(outDir,['pc_native' fname]),funcInfo,'Compressed',true)
end