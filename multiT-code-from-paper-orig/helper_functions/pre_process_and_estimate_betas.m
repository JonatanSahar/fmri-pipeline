function pre_process_and_estimate_betas()
% note that this code may take a very long time to run (esp on 150
% subjects). 
fprintf('------------------------------------------------------------\n');
fprintf('Pre-processing:\n');
fprintf('------------------------------------------------------------\n');
fprintf('- This may take a long time to run. \n');
fprintf('- First run preprocess, then re run this code and run model estimation (since AR(3) used may take a very long time). \n');
fprintf('- Then, you can run the stats part. \n');
fprintf('- By default, code is set up to work, so it runs sequntially. This may take a full week. \n');
fprintf('- If you have access to a server (running linux) code can run one matlab process on each core, employing masive parallel processing.  \n');
fprintf('- Using this method, and with 120 cores, running preprocessing and AR(3) model estimation takes ~24 hours. \n');
fprintf('- For details re turning on parallel code open "runPreprocessJob.m" .  \n');
user_response = input('---- Do you want to:\n [1] pre process data, or:\n [2] alredy preprocessed data, just estimate beta values\n');
switch user_response
    case 1 % preprocess data 
        runPreprocessJob(1)
    case 2 % estimate model 
        runPreprocessJob(2)
end
end