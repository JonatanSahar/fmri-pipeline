function params=createEVs(params)
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
        load(fullfile(params.rawBehavioral, num2str(s) ,['trialOrder_Session',num2str(session)]));
        cond_order = trialOrder(1,:,3);

        for condId = 1:length(params.conditions{1})
            cond = params.conditions{1}{condId};
            for condRunNum = 1:params.conditions{2}{condId}
                tableFileName = sprintf("%s_%s_%d", ...
                                        subId, ...
                                        cond, ...
                                        condRunNum);
                tableFileName = fullfile(params.rawBehavioral, ...
                                         num2str(s), ...
                                         tableFileName);
                t = load(tableFileName);
                table = t.table;
                for handId = 1:length(params.conditions{3}{condId})
                    hand = params.conditions{3}{condId}{handId};
                    for earId = 1:length(params.conditions{4}{condId})
                        ear = params.conditions{4}{condId}{earId};
                        if hand == 'none'
                            affector = 'ear'
                        else
                            affector = 'hand'
                        end

                        splitEventTable(table, affector, prefix, output_dir, fields_to_keep);
                        fprintf("%s_%d %s %s\n", cond, condRunNum, hand, ear)
                    end
                end
            end
        end
    end
end
end
