function createEVs(params)
%create EVs based on the randomized block order, and save in the results directory
% returns number of disqualified blcoks in each condition in params

%% MAIN LOOP
    for s = params.subjects
        num_of_sessions = length(dir(fullfile(params.rawDCM,num2str(s)))) - 2;
        for session = 1:num_of_sessions
            EV_dir=fullfile(params.experimentDir,num2str(s),'session_1','EVs');
            if ~exist(EV_dir)
                mkdir(EV_dir);
            end
            load(fullfile(params.rawBehavioral, num2str(s) ,['trialOrder_session_',num2str(session), '.mat']));
            order = trialOrder;

            for condId = 1:length(params.conditions{1})
                cond = params.conditions{1}{condId};
                for condRunNum = 1:params.conditions{2}(condId)
                    tableFileName = sprintf("%d_%s_%d.mat", ...
                                            s, ...
                                            cond, ...
                                            condRunNum);
                    tableFileName = fullfile(params.rawBehavioral, ...
                                             num2str(s), ...
                                             tableFileName);
                    t = load(tableFileName);
                    table = t.table;
                    if contains(cond, 'motor')
                        affector = 'hand'
                    else
                        affector = 'ear'
                    end

                    events_str = sprintf("%d_EV_%s_%d",...
                                         s,...
                                         cond, ...
                                         condRunNum);
                    splitEventTable(table, affector, events_str, EV_dir);
                    % fprintf("%s_%d %s %s\n", cond, condRunNum, hand, ear)
                end
            end
        end
    end
end
