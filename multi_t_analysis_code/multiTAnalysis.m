function multiTAnalysis()

    rng('default')
    P.numShuffels = 50;
    % P.subjects=[101:116];
    P.subjects=[101];
    P.discardedSubjects=[102, 104, 105, 107, 113];
    P.subjects = setdiff(P.subjects, P.discardedSubjects);
    P.conditions=["LE", "RE"];

    P.regionSize      = 27; % sl size
    P.multiResDirName=fullfile("../multi-t-results");
    P.TmapName=sprintf("%d_%s_%d_shuffels", subject, condition, numShuffels);
    P.dataDir=fullfile("../multi-t-data");
    P.multiDataLoc=p.dataDir;
    P.multiout_dir=P.multiResDirName;
    P.multiTMNIMask = fullfile(P.dataDir,"standard_MNI_mask.nii.gz");
    P.MNIMaskIndex = fullfile(P.dataDir,"standard_MNI_mask_index.mat");

    %% call level one analysis
    % multiTLevel1(P);


    %% call level two analysis
    multiTLevel2(P);

    return

    %% FDR correction
    mapDir=P.multiResDirName;
    cmd= ['fdr -i ' fullfile(mapDir,'half_ans_Pmap_pc_TR1_peakTR5_mcRej_nov20.nii')...
          ' -m ' fullfile(params.dataDir,'standard_MNI_mask.nii.gz') ' -q 0.05'];
    %% create Pmasks
    tresh=0.0001;
    create_Pval_mask(mapDir,tresh,TRafterEV)
    % create_Pval_mask_forBrainView(mapDir,tresh,TRafterEV)
    %% overlap or subtract masks (conditions)
    bin_maps=dir(fullfile(outFolder,['*' 'Pmask_trsh01.nii']));
    bin_maps={bin_maps(:).name};
    map1=bin_maps{2};
    map2=bin_maps{1};
    map_mult_or_subt(outFolder,map1,map2,1)

    %%% visualize maps

    dataDir=fullfile(pwd,'/TR1_data/MultiGroupRes/pc_TR1_peakTR5_mcRej_nov20_31N_13.12.2020');
    maskfn = fullfile(dataDir,'hand_Pmap_pc_TR1_peakTR5_mcRej_nov20_Pmask_trsh0001.nii');

    V = niftiread(maskfn);
    tresh=0.0001;
    TmapName='L_yn_withneighbours_0001';
    create_neighborsP_map(dataDir,maskfn,tresh,TmapName)

end
