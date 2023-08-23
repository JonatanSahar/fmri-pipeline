function multiTLevel2(P)
results_dir_1lvl = P.multiResDirName;
outFolder=fullfile(P.dataDir,['MultiGroupRes/pc_TR1_peakTR' num2str(TRafterEV) '_' type '_31N_20.06.2021']);
results_dir_2lvl = P.multiResDirName;

% Compute avgAnsMat across subjects, per condition
for cond = P.conditions
    MAIN_compute_non_directional_second_level(cond, results_dir_1lvl, results_dir_2lvl, P.numShuffels)
end

% tDir=dir(fullfile(results_dir_1lvl,['101' '*' num2str(numShuffels) '*' 'shuffels' '.mat'])); %just for the spatial features of the map
% tVar=load(fullfile(df.folder,df.name));
% linearIndex = tVar.linearIndex;

t = load(P.MNIMaskIndex);
linearIndex=t.linearIndex

%calc P_value
for cond = P.conditions
    mat=dir(fullfile(results_dir_2lvl, ['*' '10000' '*2013_' cond '.mat']));
    load(fullfile(results_dir_2lvl,mat.name))
    Pval = calcPvalVoxelWise_semotor(avgAnsMat, cond,outFolder, linearIndex);
end

end
