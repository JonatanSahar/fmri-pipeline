function createFolders(params)
%% CREATE FOLDERS FOR ANALYSIS
mainFolder = params.experimentDir;
if ~exist(mainFolder)
    mkdir(mainFolder)
end
for i=params.subjects
    if ~exist(fullfile(mainFolder,num2str(i)))
        params.subjectDir    = fullfile(mainFolder,"%d")
        params.sessionDir    = fullfile(params.subjectDir,'session_1');
        params.anatomyDir    = fullfile(params.sessionDir,'anatomy');
        params.EVDir         = fullfile(params.sessionDir,'EVs');
        params.functionalDir = fullfile(params.sessionDir,'functional');

        system(['mkdir ', sprintrf(params.subjectDir, num2str(i))];
        system(['mkdir ', sprintrf(params.sessionDir, num2str(i))];
        system(['mkdir ', sprintrf(params.anatomyDir, num2str(i))];
        system(['mkdir ', sprintrf(params.EVDir, num2str(i))];
        system(['mkdir ', sprintrf(params.functionalDir, num2str(i))];


        functional = sprintrf(params.functionalDir, num2str(i))
        system(['mkdir ', fullfile(functional, params.conditions{1}{1})]);
        system(['mkdir ', fullfile(functional, params.conditions{1}{2})]);
        system(['mkdir ', fullfile(functional, params.conditions{1}{3})]);
        
    end
end
