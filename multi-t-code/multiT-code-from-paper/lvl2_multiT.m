function lvl2_multiT(P,type,TRafterEV,numShuffels)
addpath(genpath('../multit'));
conditions={"RE", "LE"};
results_dir_1lvl = fullfile('..',['multit/results/pc_TR1_peakTR' num2str(TRafterEV) '_' type]);
outFolder=fullfile(P.dataDir,['MultiGroupRes/pc_TR1_peakTR' num2str(TRafterEV) '_' type '_31N_20.06.2021']);
results_dir_2lvl=fullfile(results_dir_1lvl,'2nd_level');
%compute avgAnsMat
for cond=1:length(condToAnalyze)
    %     calc averaged mat
    MAIN_compute_non_directional_second_level(conditions{condToAnalyze(cond)},results_dir_1lvl,results_dir_2lvl)
end

condToAnalyze=[12];
df=dir(fullfile(results_dir_1lvl,['sub01hand' '*' num2str(numShuffels) '.mat'])); %just for the spatial features of the map
lixFile=fullfile(df.folder,df.name);

%calc P_value
for cond=1:length(conditions(condToAnalyze))
    mat=dir(fullfile(results_dir_2lvl, ['*' '10000' '*2013_' conditions{condToAnalyze(cond)} '.mat']));
    load(fullfile(results_dir_2lvl,mat.name))
    Pval = calcPvalVoxelWise_semotor(avgAnsMat,conditions{condToAnalyze(cond)},outFolder,lixFile,TRafterEV,type);
end

end
