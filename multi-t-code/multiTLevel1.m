function multiTLevel1(P)

rng('default')
% % set parallel work
p = gcp('nocreate');
if numel(p) ==0
    pool   = parpool('local');
end
tic
parfor s = 1:length(P.subjects)
    subId = P.subjects(s)
    for cond = P.conditions
        tMapName=sprintf("%d_%s_%d_shuffels", subId, cond, P.numShuffels);
        singleSubjectMultiT(subId, cond, tMapName, P);
    end
end
fprintf("elapsed time for %d subjects: %d", length(P.subjects), toc)
end
