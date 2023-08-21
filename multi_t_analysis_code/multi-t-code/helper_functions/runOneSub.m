function runOneSub(subNum,runwhat)
dataLocation = fullfile('..','data');
subject = {fullfile(dataLocation,sprintf('sub%s_Ed',subNum))};
script_folder = pwd; 
cd(script_folder);
switch runwhat
    case 1 
        First_level_block_analysis(subject,script_folder)
        moveFilesOutOfRawDataDir(subNum)
    case 2 
        First_level_block_analysis_stats_only_ar3(subject,script_folder)      
end 

end
