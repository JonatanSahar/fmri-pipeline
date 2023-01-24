function createFolders(params)
%% CREATE FOLDERS FOR ANALYSIS
mainFolder=fullfile('..',params.expName);
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
        
%         system(['mkdir ', fullfile(mainFolder,num2str(i),'session2')]);
%         system(['mkdir ', fullfile(mainFolder,num2str(i),'session2','anatomy')]);
% %         system(['mkdir ', fullfile(mainFolder,num2str(i),'session2','anatomy','DTI')]);
%         system(['mkdir ', fullfile(mainFolder,num2str(i),'session2','EVs')]);
%         system(['mkdir ', fullfile(mainFolder,num2str(i),'session2','functional')]);
%         system(['mkdir ', fullfile(mainFolder,num2str(i),'session2','functional',params.conditions{2}{1})]) ;
%         system(['mkdir ', fullfile(mainFolder,num2str(i),'session2','functional',params.conditions{2}{2})]) ;

%         system(['mkdir ', fullfile(mainFolder,num2str(i),'session2','functional','Rest')]) ;

    end
end
