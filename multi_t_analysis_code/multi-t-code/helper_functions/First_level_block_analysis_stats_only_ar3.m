function 	First_level_block_analysis_stats_only_ar3(subject,script_folder)

% 1st level block design analysis
% takes as input the list of subjects directories (subject as cell)
% and the script folder to load SPM batch files already prepared, from
% which one inputs data, and the gp_folder in which we can already store
% some results
maxNumCompThreads(1);% XXX remove if doing parfor 
spm defaults fmri
spm_jobman('initcfg')
spm_get_defaults('cmdline',true)
spm_get_defaults('defaults.stats.maxmem',2^32)
spm_get_defaults('defaults.stats.resmem',true)

% -------------------------------------------------------------------------
% 1. run preprocess batchs (slice timing, realign, coregister and reslice T1
% to meanEPI, coregister coregT1 to 152MNI and apply to EPI (ie make 0 close to AC)
% segment, normalize, smooth
% 2. run QA tools to generate extraregressor for motion and globals
% 3. stats + contrasts
% 4. threshold voice>non-voice using Gamma-Gaussian Mixture model (move to
% dedicated folder)
% 5. unstandardize residuals for connectivity analyses
% -------------------------------------------------------------------------
% NOTE spm_defaults edited defaults.stats.maxres = Inf; allowing to get all
% residuals, but also influcence the smoothness estimation
% spm_spm edited, commenting lines that delete residuals
% -------------------------------------------------------------------------
[projectdir, ~ ] = fileparts(script_folder);
for s=1: size(subject,2) 
    %% 3.3 stats + contrasts - one beta per condition - normalized data  
    % ---------------------
    searchPattern = {'sub','asub','wasub','swasub'};
    dirNamesToCreate = {'rawData','realigned_data','normalized_data','smoothed_data'};
    
    cd(subject{s});
    cd('func')
    cd('normalized_data')
    I=dir('wasub*.nii');% this is for normalized dtat 
    for i=1:306
        Images{i}= [pwd filesep I(i).name];
    end
    cd(fullfile(projectdir,'data',subject{s},'func'));
    load(fullfile(script_folder,'helper_functions','stats_FIR_AR3.mat'));  % load stats folder 
   
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = Images'; % could optionally add ,1
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {fullfile(script_folder,'helper_functions','onsetsSEP.mat')}; % load regular onsets 
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {[pwd filesep 'multiple_regressors.txt']};
    mkdir('stats_normalized_sep_beta_FIR_ar3'); cd('stats_normalized_sep_beta_FIR_ar3'); % DIR TO SAVE STUFF IN 
    matlabbatch{1}.spm.stats.fmri_spec.dir = {pwd};
    
    % matlabbatch{2}.spm.stats.fmri_est % <-- dependencies
    % matlabbatch{3}.spm.stats.con % <-- dependencies
    
    cd(subject{s}); save stats matlabbatch;
    spm_jobman('run', [pwd filesep 'stats.mat']);
    clear I Images matlabbatch  
end
cd(fullfile(projectdir,'code')); 


