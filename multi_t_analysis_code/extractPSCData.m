function [combined_LE_LH, combined_LE_RH, combined_RE_LH, combined_RE_RH] = extractPSCData(params, subject, EVDir)

for subject=params.subjects
    disp(['analysing subject number: ',num2str(subject)]);
    functionalDir = sprintf(params.functionalDir+'/audiomotor/', subject);
    EVDir = sprintf(params.EVDir, subject);

    % Initialize matrices for each combination
    combined_LE_LH = [];
    combined_LE_RH = [];
    combined_RE_LH = [];
    combined_RE_RH = [];

    % Trial parameters
    trialLength = 16; % 16 seconds/TRs

    % Get all EV files for the subject
    allRuns = [1:4]
    for runNumber = allRuns
        % Get the corresponding Nii file and extract PSC matrix
        niiFile = dir(fullfile(functionalDir, sprintf('sub%d_audiomotor_%d.nii.gz', subject, runNumber)));
        pscMatrix = niiToPSC(niiFile);

        evFiles = dir(fullfile(EVDir, sprintf('%d_EV_audiomotor_%d*', subject, runNumber)));

        for idx = 1:length(evFiles)
            evFile = fullfile(EVDir, evFiles{idx});
            if exist(evFile, 'file')
                pattern = '(_[A-Z][A-Z]_[A-Z][A-Z])';
                match = regexp(filename, pattern, 'match');
                if ~isempty(match)
                    condition = match{1}(2:end); % Remove the initial underscore
                else
                    condition = '';
                end
                data = tdfread(evFile, '\t');
                startIndices = round(data(:,1)) ;
                % Get the the mean activation level for each trial, append it to the correct output matrix
                for i = 1:length(startIndices)
                    startTime = startIndices(i);
                    endTime = startTime + trialLength;

                    trialData = pscMatrix(:, :, :, startTime:endTime);
                    meanTrialData = mean(trialData, 4);

                    switch condition
                        case 'LE_LH'
                            combined_LE_LH = cat(4, combined_LE_LH, meanTrialData);
                        case 'LE_RH'
                            combined_LE_RH = cat(4, combined_LE_RH, meanTrialData);
                        case 'RE_LH'
                            combined_RE_LH = cat(4, combined_RE_LH, meanTrialData);
                        case 'RE_RH'
                            combined_RE_RH = cat(4, combined_RE_RH, meanTrialData);
                    end
                end
            end
        end
    end
end
