function multiTAnalysis()

    rng('default')
    addpath("./multiT-code-from-paper")
    addpath("./multiT-code-from-paper/helper_functions")
    P.numShuffels = 100;
    P.subjects=[101:116];
    % P.subjects=[101];
    P.discardedSubjects=[102, 104, 105, 107, 113];
    P.subjects = setdiff(P.subjects, P.discardedSubjects);

    P.earConditions=["LE", "RE"];
    P.handConditions=["LH", "RH"];
    P.conditions=P.handConditions;

    P.regionSize      = 27; % sl size

    P.audiomotorResultsDir=fullfile("../multi-t-results/audiomotor");
    P.motorResultsDir=fullfile("../multi-t-results/motor-only");
    P.resultsDir=P.motorResultsDir;

    P.audiomotor=fullfile(pwd,"../multi-t-data/audiomotor");
    P.motor=fullfile(pwd,"../multi-t-data/motor-only");
    P.dataDir=P.motor;

    P.MNIMask = fullfile(P.dataDir,"standard_MNI_mask.nii.gz");
    P.MNIMaskIndex = fullfile(P.dataDir,"standard_MNI_mask_index.mat");

    P.multiDataLoc=P.dataDir;
    P.multiout_dir=P.resultsDir;


    %% call level one analysis
    multiTLevel1(P);

    %% call level two analysis
    multiTLevel2(P);

    return

    %% FDR correction
    for  cond = P.conditions
        cmd= sprintf("fdr -i %s -m %s -q 0.05", fullfile(P.resultsDir, sprintf('%d_pMap.nii.gz', cond)),  fullfile(params.dataDir,"standard_MNI_mask.nii.gz"));
        cmd
        system(cmd);
    end

end
