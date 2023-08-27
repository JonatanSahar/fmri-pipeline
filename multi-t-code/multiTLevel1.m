function multiTLevel1(P)

rng('default')
% % set parallel work
% p = gcp('nocreate');
% if numel(p) ==0
%     pool   = parpool('local');
% end
tic
% parfor s=1:length(subIDs)
for subId = P.subjects
    for cond = P.conditions
        P.TmapName=sprintf("%d_%s_%d_shuffels", subId, cond, P.numShuffels);
        singleSubjectMultiT(subId, cond, P);
    end
end
fprintf("elapsed time for %d subjects: %d", length(P.subjects), toc)
end
