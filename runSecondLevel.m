function runSecondLevel(params)
% Loop over each subject, condition, and ear
    for s = 1:length(params.subjects)
        subId = params.subjects(s);
        for c = 1:length(params.conditions)
            condition = params.conditions(c);
            numRuns = params.numRunsPerCondition(c);
            if contains(condition, "audiomotor")
                runSecondLevelAudiomotor(params, subId, numRuns);
            else
                runSecondLevelLocalizer(params, subId, condition, numRuns);
            end
        end
    end
end
