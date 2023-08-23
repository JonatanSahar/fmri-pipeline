function MAIN_compute_non_directional_second_level(condName,results_dir_1lvl,results_dir_2lvl, numShuffels)
% This function computes second levele results 


ffldrs = findFilesBVQX(results_dir_1lvl,['*' condName '*' numShuffels '*' 'shuffels.mat']);
% fprintf('The following results folders were found:\n'); 
% for i = 1:length(ffldrs)
%     [pn,fn] = fileparts(ffldrs{i})
%     fprintf('[%d]\t%s\n',i,fn);
% end
% fprintf('enter number of results folder to compute second level on\n'); 
% foldernum = input('what num? ');
% analysisfolder = ffldrs{foldernum}; 
mkdir(results_dir_2lvl); 

fold = 1; 
numMaps = 10000;
 computeFFXresults(ffldrs,fold,results_dir_2lvl,numMaps,condName)
end
