%iterate on all subs...

subjects=[301,303:305,308:315,317:324,326,328,330:333];
condition={'RVF','LVF'};
p = gcp('nocreate');
if numel(p) ==0
    pool   = parpool('local'); %activate parallel mode
end
for c=1:2
parfor s=1:length(subjects)
    disp(['working on ',condition{c},', subject ',num2str(subjects(s))]);
     testMultiTanalysis1(s,condition{c}); 
       %% to run in parllel comment section above and uncomment section below:
%         startmatlab = 'matlabr2015a -nodisplay -r ';
%         runprogram  = ['"testMultiTanalysis1(',num2str(s),',',condition{c},').m; exit;"'];
%         unix([startmatlab  runprogram ' &'])
end
end

    
