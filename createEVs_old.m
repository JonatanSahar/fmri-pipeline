function params=createEVs_old(params)
%create EVs based on the randomized block order, and save in the results directory
% returns number of disqualified blcoks in each condition in params

%% MAIN LOOP
for s = params.subjects
    num_of_sessions = length(dir(fullfile(params.rawDCM,num2str(s)))) - 2;
    for session = 1:num_of_sessions
        EV_dir=fullfile('..',params.expName,num2str(s),'session_1','EVs');
        if ~exist(EV_dir)
            mkdir(EV_dir);
        end
        load(fullfile(params.rawBehavioral, num2str(s) ,['trialOrder_Session',num2str(session)]));
        cond_order = trialOrder(1,:,3);
        for condition = 1: length(params.conditions{session})
            for run =   1:length(cond_order)
                load(fullfile(params.rawBehavioral, num2str(s) ,[num2str(s),'Session_',num2str(session),...
                    'Run',num2str(run) ,'.mat']),'log');
                if cond_order(run) ~= 3
                    rightEV = fopen(fullfile(EV_dir, [num2str(s),params.conditions{session}{cond_order(run)},num2str(params.run_nums(run)),'_RIGHT.txt']),'wt');
                    leftEV = fopen(fullfile(EV_dir, [num2str(s),params.conditions{session}{cond_order(run)},num2str(params.run_nums(run)),'_LEFT.txt']),'wt');
                    disqEV = fopen(fullfile(EV_dir, [num2str(s),params.conditions{session}{cond_order(run)},num2str(params.run_nums(run)),'_DISQ.txt']),'wt');
%                     if session == 2
                        oddEV = fopen(fullfile(EV_dir, [num2str(s),params.conditions{session}{cond_order(run)},num2str(params.run_nums(run)),'_ODD.txt']),'wt');
%                     end
                    
                    block_beg = floor(log.cueTime(:,1));
                    if any(isnan(block_beg))
                        if find(isnan(block_beg)) == 1
                            block_beg(isnan(block_beg)) = 8;
                        else
                            block_beg(isnan(block_beg)) = block_beg(find(isnan(block_beg))-1) + 18;
                        end
                    end
                    block_dur = repmat(10,size(block_beg));
                    factor = ones(size(block_beg));
                    oddball_locations = ceil(find(trialOrder(:,run,1))/5);
                    good = ones(size(block_beg));
                    good(oddball_locations) = 0;
                    R = [block_beg(good & ~trialOrder(1:5:end,run,2) & ~any(isnan(log.RT)')')-1,...
                        block_dur(good & ~trialOrder(1:5:end,run,2) & ~any(isnan(log.RT)')'),...
                        factor(good & ~trialOrder(1:5:end,run,2) & ~any(isnan(log.RT)')')];
                    L = [block_beg(good & trialOrder(1:5:end,run,2) & ~any(isnan(log.RT)')')-1,...
                        block_dur(good & trialOrder(1:5:end,run,2) & ~any(isnan(log.RT)')'),...
                        factor(good & trialOrder(1:5:end,run,2) & ~any(isnan(log.RT)')')];
                    if any(any(isnan(log.RT)'))
                        DISQ = [block_beg(any(isnan(log.RT)')')-1,...
                            block_dur(any(isnan(log.RT)')'),...
                            factor(any(isnan(log.RT)')')];
                        params.disqalified_blocks(run,session,s) = sum(any(isnan(log.RT)'));
                        if any(isnan(DISQ))
                           disp('1'); 
                        end
                    else
                        DISQ = [0,0,0];
                    end
                    
                    for block=1:size(R,1)
                        fprintf(rightEV,'%d\t',R(block,:));
                        fprintf(rightEV,'\n');
                    end
                    fclose(rightEV);
                    for block=1:size(L,1)
                        fprintf(leftEV,'%d\t', L(block,:));
                        fprintf(leftEV,'\n');
                    end
                    fclose(leftEV);
                    for block=1:size(DISQ,1)
                        fprintf(disqEV,'%d\t', DISQ(block,:));
                        fprintf(disqEV,'\n');
                    end
                    fclose(disqEV);
                    
                    if session == 1 && cond_order(run) == 1
                        ODD = [0,0,0];
                    else
                        ODD = [block_beg(~good & ~any(isnan(log.RT)')')-1,block_dur(~good & ~any(isnan(log.RT)')'),factor(~good & ~any(isnan(log.RT)')')];
                    end
                        for block=1:size(ODD,1)
                            fprintf(oddEV,'%d\t', ODD(block,:));
                            fprintf(oddEV,'\n');
                        end
                        fclose(oddEV);
                                            
                else %% visual localizer is a bit different because its only one type of stimulus & odd
                    presentEV = fopen(fullfile(EV_dir, [num2str(s),params.conditions{session}{cond_order(run)},num2str(params.run_nums(run)),'_present.txt']),'wt');
                    oddEV = fopen(fullfile(EV_dir, [num2str(s),params.conditions{session}{cond_order(run)},num2str(params.run_nums(run)),'_ODD.txt']),'wt');
                    pres_timing = [log.stimulusPresentTime(:,1,1),repmat([10,1],size(log.stimulusPresentTime(:,1,1)))];
                    oddball_locations = ceil(find(trialOrder(:,run,1))/5);
                    for block=1:size(pres_timing,1)
                        if any(oddball_locations == block)
                            fprintf(oddEV,'%d\t', pres_timing(block,:));
                            fprintf(oddEV,'\n');
                        else
                            fprintf(presentEV,'%d\t', pres_timing(block,:));
                            fprintf(presentEV,'\n');
                        end
                    end
                    fclose(presentEV);
                end
                
            end
            
            clearvars -except s EV_dir run params session cond_order trialOrder;
        end
    end
end




