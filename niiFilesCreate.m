function niiFilesCreate(params)
for s=params.subjects
    num_of_sessions = length(dir(fullfile(params.rawDCM,num2str(s)))) - 2;
    for session = 1:num_of_sessions
        scans=dir(fullfile(params.rawDCM,num2str(s),'session_1'));
        scans={scans(find([scans.isdir])).name};
        scans(ismember(scans,{'.','..','ignore'}))=[];
        scans = scans(cellfun('isempty', strfind(scans,'SBRef')));
        try
            load(fullfile(params.rawBehavioral,num2str(s),'trialOrder.mat'));
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
        anatomy = dir(fullfile(params.rawDCM,num2str(s),'session_1','*MPRAGE*'));
        for sc = 1:length({anatomy.name})
            an = strsplit(anatomy(sc).name, '_');
            scan_num(sc) = str2double(an{1});
        end
        anatomy_file = anatomy(scan_num == max(scan_num)).name;
        
        if ~exist(fullfile(params.experimentDir,num2str(s),'session_1',params.anatomyFolder,[num2str(s),'anatomy.nii.gz'])) || params.override
            file_dir = fullfile(params.experimentDir,num2str(s),'session_1',params.anatomyFolder);
            mkdir(fullfile(file_dir,'temp'));
            cmd = ['dcm2niix -z y -o ' , fullfile(file_dir,'temp'),' ' fullfile(params.rawDCM,num2str(s),'session_1',anatomy_file)];
            system(cmd);
            image = dir(fullfile(file_dir,'temp', '*.nii.gz'))
            movefile(fullfile(file_dir,'temp',image(1).name),fullfile(file_dir,[num2str(s),'anatomy','.nii.gz']));
            rmdir(fullfile(file_dir,'temp'),'s');
        end
        
        
        %% look for functional data
        condNumRum = 0;
        for i=1:length(scans)
            scan=strsplit(scans{i}, '_');
            if strcmp(scan{2},'cmrr') && length(scan)==5
                condNumRum = condNumRum + 1;
                runType = scan{5};
                % runNum = str2double(scan{1});
                runNum = scan{6};
                file_name = sprintf('sub%d_%s_%d.nii.gz',s, runType, condNumRum);
                file_dir = fullfile(params.experimentDir,...
                                    num2str(s),...
                                    'session_1',...
                                    params.functionalFolder,...
                                    params.conditions(order(runNum)))
                if ~exist(fullfile(file_dir,file_name),'file') || params.override
                    mkdir(fullfile(file_dir,'temp'));
                    cmd = ['dcm2niix -z y -o ' ,...
                           fullfile(file_dir,'temp'),...
                           ' ', ...
                           fullfile(params.rawDCM,num2str(s),...
                                        'session_1',...
                                        scans{i})]
                    system(cmd);
                    image = dir(fullfile(file_dir,'temp', '*.nii.gz'));
                    from =fullfile(file_dir, 'temp', image(1).name)
                    to = fullfile(file_dir, file_name)
                    movefile(from, to);
                    rmdir(fullfile(file_dir,'temp'), 's');
                end
            end
        end
    end
end
end
