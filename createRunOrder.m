function createRunOrder(params)
    for s=params.subjects
        num_of_sessions = length(dir(fullfile(params.rawDCM,num2str(s)))) - 2;
        for session = 1:num_of_sessions
            scans=dir(fullfile(params.rawDCM,num2str(s),['session_',num2str(session)]));
            scans={scans(find([scans.isdir])).name};
            scans(ismember(scans,{'.','..','ignore'}))=[];
            length(scans)
            length(params.conditionsInOrder)
            % assert(length(scans) == length(params.conditionsInOrder))
            try
                for i=1:length(scans)
                    scan=strsplit(scans{i}, '_');
                    if strcmp(scan{2},'cmrr') && length(scan)==5
                        runNum = str2double(scan{end}(end));
                        trialOrder(runNum) = params.conditionsInOrder(i);
                    end
                end % for scans
                save (fullfile(params.rawBehavioral,...
                                num2str(s),...
                                ['trialOrder_session_',...
                                 num2str(session),...
                                 '.mat']),...
                       "trialOrder");
            end
        end
    end
end
