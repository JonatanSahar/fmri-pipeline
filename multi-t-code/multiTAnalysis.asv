function multiTAnalysis()

    rng('default')
    addpath('../niiTool')
    addpath("./multiT-code-from-paper")
    addpath("./multiT-code-from-paper/helper_functions")
    P.numShuffels = 50;
    % P.subjects=[101:116];
    P.subjects=[101];
    P.discardedSubjects=[102, 104, 105, 107, 113];
    P.subjects = setdiff(P.subjects, P.discardedSubjects);
    P.conditions=["LE", "RE"];

    P.regionSize      = 27; % sl size
    P.multiResDirName=fullfile("../multi-t-results");
    P.dataDir=fullfile(pwd,"../multi-t-data");
    P.multiTMNIMask = fullfile(P.dataDir,"standard_MNI_mask.nii.gz");
    P.MNIMaskIndex = fullfile(P.dataDir,"standard_MNI_mask_index.mat");
    P.multiDataLoc=P.dataDir;
    P.multiout_dir=P.multiResDirName;


    %% call level one analysis
    multiTLevel1(P);

    %% call level two analysis
    multiTLevel2(P);

    return

    %% FDR correction
    for  cond = P.conditions
        cmd= sprintf("fdr -i %s -m %s -q 0.05", fullfile(P.multiResDirName, sprintf('%d_pMap.nii.gz', cond)),  fullfile(params.dataDir,"standard_MNI_mask.nii.gz"));
        cmd
        system(cmd);
    end

    %% create Pmasks
    thresh=0.0001;
    create_Pval_mask(P.multiResDirName, thresh,TRafterEV)
    % create_Pval_mask_forBrainView(mapDir,thresh,TRafterEV)

    %% overlap or subtract masks (conditions)
    bin_maps=dir(fullfile(outFolder,('*' 'Pmask_trsh01.nii')));
    bin_maps={bin_maps(:).name};
    map1=bin_maps{2};
    map2=bin_maps{1};
    map_mult_or_subt(outFolder,map1,map2,1)

    %%% visualize maps
    dataDir=P.multiResDirName;
    maskfn = fullfile(dataDir,'hand_Pmap_pc_TR1_peakTR5_mcRej_nov20_Pmask_trsh0001.nii');

    V = niftiread(maskfn);
    thresh=0.0001;
    tMapName='L_yn_withneighbours_0001';
    create_neighborsP_map(dataDir,maskfn,thresh,tMapName)

end
