function allSubjectsMultiT(subIDs,type,TRafter)

rng('default')
addpath('niiTool')
P.numShuffels = 10;
P.subjects=[101:116];
% P.subjects=[115];
P.discardedSubjects=[102, 104, 105, 107, 113];
P.subjects = setdiff(params.subjects, params.discardedSubjects);
P.conditions=["LE", "RE"];

% performing each step by calling each of the analysis functions

% % set parallel work
% p = gcp('nocreate');
% if numel(p) ==0
%     pool   = parpool('local');
% end

% parfor s=1:length(subIDs)
for s = P.subjects
    for cond = P.conditions
        singleSubjectMultiT(s, cond, P.numShuffels);
    end
end
end
