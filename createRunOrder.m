function createRunOrder(params)
    trialOrder = [];
    for s=params.subjects
            scans=dir(fullfile(params.rawDCM,num2str(s), '*cmrr*'));
            scans={scans(find([scans.isdir])).name};
            scans(ismember(scans,{'.','..','ignore'}))=[];
            scans = scans(cellfun('isempty', strfind(scans,'SBRef')))
            assert(length(scans) == length(params.conditionsInOrder))
                for i=1:length(scans)
                    scan=strsplit(scans{i}, '_');
                    if strcmp(scan{2},'cmrr') && length(scan) == 6
                        runNum = str2double(scan{1}(end));
                        trialOrder(runNum) = params.conditionsInOrder(i);
                    end
                end % for scans
                dirPath = fullfile(params.rawBehavioral, num2str(s));
                system(sprintf("mkdir %s", dirPath))

                filePath = fullfile(dirPath, "trialOrder.mat");
                save (filePath, "trialOrder");
    end
end
