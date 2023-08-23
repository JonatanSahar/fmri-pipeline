function params=setAnalysisParams_TR1(subject,params)
params.TRafterEV=5;
params.numRuns=4;
params.nCondInRun=4;
params.NtrialsInRun=48;
params.pwd=pwd;

params.fsfiles_dir=fullfile(pwd,'TR1_data','fsf_files');
params.outData_dir=fullfile(pwd,'TR1_data',subject);
params.anatomyFolder=fullfile(params.outData_dir,'anatomy');
params.functionalFolder=fullfile(params.outData_dir,'functional');
params.TaskFolder=fullfile(params.functionalFolder,'allTaskRuns');
params.mapFolder=fullfile(params.outData_dir,'logs');
params.EVdir=fullfile(params.outData_dir,'EVs');

params.sub_GLM_ev_dir=fullfile(params.outData_dir,'derive/GLM_EVs');
params.sub_fsfdir=fullfile(params.outData_dir,'derive/fsfs');
params.sub_GLMfsfdir=fullfile(params.sub_fsfdir,'GLM');

params.sub_MulTfsfdir=fullfile(params.sub_fsfdir,'multi_fsfs');
params.sub_MulT_PC_fsfdir=fullfile(params.sub_fsfdir,'multi_PC_fsfs');
% params.sub_mulToutDir=fullfile(params.outData_dir,num2str(subject),'derive/multiTres');
params.rawDCM=fullfile(params.outData_dir,'DCM');
params.logFile=[pwd,'/logFile.txt'];
params.pcDir=fullfile(params.outData_dir,'derive/pc_data','mcRej_nov20');
params.pc_multi_dataDir=fullfile(params.pcDir,'forMultiT',['pc_TR' num2str(params.TRafterEV) '_fixedMED']);
end
