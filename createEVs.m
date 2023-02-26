function createEVs(params)
%create EVs based on the randomized block order, and save in the results directory
% returns number of disqualified blcoks in each condition in params
T = table()
%% MAIN LOOP
    for subId = params.subjects
        EV_dir=fullfile(params.experimentDir,num2str(subId),'session_1','EVs');
        if ~exist(EV_dir)
            mkdir(EV_dir);
        end

        for condId = 1:length(params.conditions);
            cond = params.conditions(condId);
            for condRunNum = 1:params.numRunsPerCondition(condId)
                tableFileName = sprintf("%d_%s_%d.mat", ...
                                        s, ...
                                        cond, ...
                                        condRunNum);
                tableFileName = fullfile(params.rawBehavioral, ...
                                         num2str(subId), ...
                                         tableFileName);
                t = load(tableFileName);
                table = t.eventTable;

                events_str = sprintf("%d_EV_%s_%d",...
                                     s,...
                                     cond, ...
                                     condRunNum);

                splitEventTable(table, cond, events_str, EV_dir);
                % fprintf("%s_%d %s %s\n", cond, condRunNum, hand, ear)
            end
        end
    end
end
