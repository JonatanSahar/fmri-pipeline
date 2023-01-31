function niiFilesCreate(params)
for s=params.subjects
    num_of_sessions = length(dir(fullfile(params.rawDCM,num2str(s)))) - 2;
    for session = 1:num_of_sessions
        scans=dir(fullfile(params.rawDCM,num2str(s),['session_',num2str(session)]));
        scans={scans(find([scans.isdir])).name};
        scans(ismember(scans,{'.','..','ignore'}))=[];
        try
            load(fullfile(params.rawBehavioral,num2str(s),['trialOrder_session_',num2str(session),'.mat']));
            order = trialOrder;
            % if isempty(params.alt_DCM_order{session,params.subjects==s})
            %     order = trialOrder(1,:,3);
            % else
            %     order = trialOrder(1,params.alt_DCM_order{session,params.subjects==s},3);
            % end
        catch
            error(['no behavioral data found for subject ', num2str(s), ' session ' ,num2str(session)]);
        end
        %% look for anatomy data
        anatomy = dir(fullfile(params.rawDCM,num2str(s),['session_',num2str(session)],'*MPRAGE*'));
        for sc = 1:length({anatomy.name})
            an = strsplit(anatomy(sc).name, '_');
            scan_num(sc) = str2double(an{1});
        end
        anatomy_file = anatomy(scan_num == max(scan_num)).name;
        
        if ~exist(fullfile(params.experimentDir,num2str(s),['session_',num2str(session)],params.anatomyFolder,[num2str(s),'anatomy.nii.gz'])) || params.override
            file_dir = fullfile(params.experimentDir,num2str(s),['session_',num2str(session)],params.anatomyFolder);
            mkdir(fullfile(file_dir,'temp'));
            cmd = ['dcm2niix -o ' , fullfile(file_dir,'temp'),' ' fullfile(params.rawDCM,num2str(s),['session_',num2str(session)],anatomy_file)];
            system(cmd);
            image = dir(fullfile(file_dir,'temp', '*.nii.gz'));
            movefile(fullfile(file_dir,'temp',image(1).name),fullfile(file_dir,[num2str(s),'anatomy','.nii.gz']));
            rmdir(fullfile(file_dir,'temp'),'s');
        end
        
        
        %% look for functional data
        for i=1:length(scans)
            scan=strsplit(scans{i}, '_');
            if strcmp(scan{2},'cmrr') && length(scan)==5
                runNum = str2double(scan{end}(end));
                file_name = ['sub',num2str(s),'run',num2str(params.run_nums(runNum)),'.nii.gz'];
                file_dir = fullfile(params.experimentDir,num2str(s),['session_',num2str(session)], params.functionalFolder,params.conditions{session}{order(runNum)});
                if ~exist(fullfile(file_dir,file_name),'file') || params.override
                    mkdir(fullfile(file_dir,'temp'));
                    cmd = ['dcm2niix -o ' , fullfile(file_dir,'temp'),' ' fullfile(params.rawDCM,num2str(s),['session_',num2str(session)],scans{i})];
                    system( cmd );
                    image = dir(fullfile(file_dir,'temp', '*.nii.gz'));
                    movefile(fullfile(file_dir,'temp',image(1).name),fullfile(file_dir,file_name));
                    rmdir(fullfile(file_dir,'temp'));
                end
            end
        end
    end
end
end
