function MAIN_compute_non_directional_second_level_svm(condName,testDir)
% This function computes second levele results 



ffldrs = findFilesBVQX(testDir,['s' '*' '.txt']);
% fprintf('The following results folders were found:\n'); 
% for i = 1:length(ffldrs)
%     [pn,fn] = fileparts(ffldrs{i})
%     fprintf('[%d]\t%s\n',i,fn);
% end
% fprintf('enter number of results folder to compute second level on\n'); 
% foldernum = input('what num? ');
% analysisfolder = ffldrs{foldernum}; 
secondlevelresultsfolder = fullfile(pwd,'SVM_res/2nd_level/',condName);
mkdir(secondlevelresultsfolder); 

% subsToExtract = subsUsedGet(20); % 150 / 20 for vocal data set 
fold = 1; 
numMaps = 5000;
 computeFFXresults_svm(ffldrs,fold,secondlevelresultsfolder,numMaps,condName)
end
