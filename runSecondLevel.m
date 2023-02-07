function runSecondLevel(params)

order = [1,2,3,1,2;1,1,1,2,2];

for s=params.subjects
    disp(['analysing subject number ',num2str(s)]);
    parfor r=1:length(order)
        if ~exist(fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],params.functionalFolder,params.conditions{order(2,r)}{order(1,r)},'second_level.gfeat'),'dir') || params.override
            disp(['Session ',num2str(order(2,r)),' condition ',params.conditions{order(2,r)}{order(1,r)}]);
            if order(1,r) == 3
            fid = fopen(fullfile(params.fsfdir, 'second_lvl_loc.fsf')) ;
            else
            fid = fopen(fullfile(params.fsfdir, 'second_lvl_re.fsf')) ;
            end
            X = fread(fid) ;
            fclose(fid) ;
            X = char(X.') ;
            % replace strings for analysis
            %% set file directories % params
            Y = strrep(X, 'output_dir', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],params.functionalFolder,params.conditions{order(2,r)}{order(1,r)},'second_level')) ;
            Y = strrep(Y, 'run1', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],params.functionalFolder,params.conditions{order(2,r)}{order(1,r)},['sub',num2str(s),'run1.feat']));
            Y = strrep(Y, 'run2', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],params.functionalFolder,params.conditions{order(2,r)}{order(1,r)},['sub',num2str(s),'run2.feat']));
            if order(1,r) == 3
                Y = strrep(Y, 'is_loc' , num2str(0)) ;
                Y = strrep(Y, 'run3', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],params.functionalFolder,params.conditions{order(2,r)}{order(1,r)},['sub',num2str(s),'run1.feat']));
            else
                Y = strrep(Y, 'is_loc' , num2str(1)) ;
                Y = strrep(Y, 'run3', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],params.functionalFolder,params.conditions{order(2,r)}{order(1,r)},['sub',num2str(s),'run3.feat']));
            end
            fid2 = fopen(fullfile(params.fsfdir, ['fsfs',num2str(r),'.fsf']) ,'wt') ;
            fwrite(fid2,Y) ;
            fclose (fid2) ;
            cmd = ['feat ' fullfile(params.fsfdir , ['fsfs',num2str(r),'.fsf'])];
            unix(cmd);
            unix(['firefox ', fullfile(params.mainDir,params.expName,num2str(s),['session',num2str(order(2,r))],params.functionalFolder,params.conditions{order(2,r)}{order(1,r)},'second_level.gfeat/report_log.html')]);
            unix(['rm ', fullfile(params.fsfdir,['fsfs',num2str(r),'.fsf'])]);
        end
    end
    disp(['finished subject number ',num2str(s)]);
    
end

