function createFolders(params)
%% CREATE FOLDERS FOR ANALYSIS
mainFolder = params.experimentDir;
if ~exist(mainFolder)
    mkdir(mainFolder)
end
for i=params.subjects
    if ~exist(fullfile(mainFolder,num2str(i)))
        subjectDir    = fullfile(mainFolder,"%d")
        sessionDir    = fullfile(subjectDir,'session_1');
        anatomyDir    = fullfile(sessionDir,'anatomy');
        EVDir         = fullfile(sessionDir,'EVs');
        functionalDir = fullfile(sessionDir,'functional');

        params.sessionDir    =  strrep(sessionDir, "\", "\\");
        params.EVDir         =  strrep(EVDir, "\", "\\");
        params.anatomyDir    =  strrep(anatomyDir, "\", "\\");
        params.subjectDir    =  strrep(subjectDir, "\", "\\");
        params.functionalDir =  strrep(functionalDir, "\", "\\");

        system('mkdir ' + sprintf(params.subjectDir, i));
        system('mkdir ' + sprintf(params.sessionDir, i));
        system('mkdir ' + sprintf(params.anatomyDir, i));
        system('mkdir ' + sprintf(params.EVDir, i));
        system('mkdir ' + sprintf(params.functionalDir, i));


        functional = sprintf(params.functionalDir, i)
        system(['mkdir ', fullfile(functional, params.conditions(1))]);
        system(['mkdir ', fullfile(functional, params.conditions(2))]);
        system(['mkdir ', fullfile(functional, params.conditions(3))]);
        
    end
end
