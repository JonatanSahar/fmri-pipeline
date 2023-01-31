function createFolders(params)
%% CREATE FOLDERS FOR ANALYSIS
mainFolder = params.experimentDir;
if ~exist(mainFolder)
    mkdir(mainFolder)
end
for i=params.subjects
    if ~exist(fullfile(mainFolder,num2str(i)))
        system(['mkdir ', fullfile(mainFolder,num2str(i))]);
        system(['mkdir ', fullfile(mainFolder,num2str(i),'session_1')]);
        system(['mkdir ', fullfile(mainFolder,num2str(i),'session_1','anatomy')]);
        system(['mkdir ', fullfile(mainFolder,num2str(i),'session_1','EVs')]);
        system(['mkdir ', fullfile(mainFolder,num2str(i),'session_1','functional')]);
        system(['mkdir ', fullfile(mainFolder,num2str(i),'session_1','functional',params.conditions{1}{1})]) ;
        system(['mkdir ', fullfile(mainFolder,num2str(i),'session_1','functional',params.conditions{1}{2})]) ;
        system(['mkdir ', fullfile(mainFolder,num2str(i),'session_1','functional',params.conditions{1}{3})]) ;
        
    end
end
