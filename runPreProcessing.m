function runPreProcessing(params)

%% RUN FEAT

order=[ones(1,3),ones(1,3)*2,3,3,ones(1,3),ones(1,3)*2;ones(1,8),ones(1,6)*2;1:3,1:3,1:2,1:3,1:3];

for s=params.subjects
    disp(['analysing subject number ',num2str(s)]);
    parfor r=1:length(order)
        if ~exist(fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],params.functionalFolder,params.conditions{order(2,r)}{order(1,r)},['sub',num2str(s),'run',num2str(order(3,r)),'.feat']),'dir') || params.override
            disp(['Session ',num2str(order(2,r)),' condition ',params.conditions{order(2,r)}{order(1,r)}, ' run number ',num2str(order(3,r))]);
            % distribute fsf files in functional dirs and run first level Feat
            if order(1,r)== 3
                fid = fopen(fullfile(params.fsfdir, 'localizer.fsf')) ;
            else
                if s == 1 && order(2,r) == 1
                    fid = fopen(fullfile(params.fsfdir, ['MRI_data_sub1.fsf'])) ;
                else
                fid = fopen(fullfile(params.fsfdir, ['MRI_data.fsf'])) ;
                end
            end
            X = fread(fid) ;
            fclose(fid) ;
            X = char(X.') ;
            % replace strings for analysis
            %% set file directories % params
            Y = strrep(X, 'pp_dir', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],params.functionalFolder,params.conditions{order(2,r)}{order(1,r)},['sub',num2str(s),'run',num2str(order(3,r)),'.nii.gz'])) ;
            Y = strrep(Y, 'out_dir' , fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],params.functionalFolder,params.conditions{order(2,r)}{order(1,r)},['sub',num2str(s),'run',num2str(order(3,r))])) ;
            Y = strrep(Y, 'templates_dir', params.templateDir) ;
            Y = strrep(Y, 'needs_fieldmap', num2str(params.fieldMap)) ;
            Y = strrep(Y, 'smoothing_param', num2str(params.smoothing)) ;
            Y = strrep(Y, 'is_normalized', num2str(params.normalization)) ;
            Y = strrep(Y, 'anatomy_dir', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],params.anatomyFolder,[num2str(s),'anatomy_brain.nii.gz']));
            %% set EVs
            if order(1,r) ~= 3
                Y = strrep(Y, 'right_ev', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],'EVs',[num2str(s),params.conditions{order(2,r)}{order(1,r)},num2str(order(3,r)),'_RIGHT.txt']));
                Y = strrep(Y, 'left_ev', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],'EVs',[num2str(s),params.conditions{order(2,r)}{order(1,r)},num2str(order(3,r)),'_LEFT.txt']));
                Y = strrep(Y, 'disq_ev', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],'EVs',[num2str(s),params.conditions{order(2,r)}{order(1,r)},num2str(order(3,r)),'_DISQ.txt']));
                %                 if order(2,r) == 2
                Y = strrep(Y, 'oddball_dir', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],'EVs',[num2str(s),params.conditions{order(2,r)}{order(1,r)},num2str(order(3,r)),'_ODD.txt']));
                %                 end
            else
                Y = strrep(Y, 'localizer_ev', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],'EVs',[num2str(s),'Visual_Localizer',num2str(order(3,r)),'_present.txt']));
                Y = strrep(Y, 'oddEV', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],'EVs',[num2str(s),'Visual_Localizer',num2str(order(3,r)),'_ODD.txt']));
                
            end
            fid2 = fopen(fullfile(params.fsfdir, ['fsfs',num2str(r),'.fsf']) ,'wt') ;
            fwrite(fid2,Y) ;
            fclose (fid2) ;
            cmd = ['feat ' fullfile(params.fsfdir , ['fsfs',num2str(r),'.fsf'])];
            unix(cmd);
            unix(['firefox ', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],params.functionalFolder,params.conditions{order(2,r)}{order(1,r)},['sub',num2str(s),'run',num2str(order(3,r))]), '.feat/report_log.html']);
            unix(['rm ', fullfile(params.fsfdir,['fsfs',num2str(r),'.fsf'])]);
        end
    end
    disp(['finished subject number ',num2str(s)]);
    
end

