clear all
close all

rng('default')
addpath('niiTool')
dataDir=fullfile(pwd,'TR1_data');
d=dir(fullfile(dataDir,'sub*'));
params.subjIDs={d.name};
params.numOfRuns=4;


%% Preprocessing
% params.subjects={params.subjects{:}}; %for pc prep
% for s=3:length(params.subjects)
%
%     params=setAnalysisParams_TR1(params.subjects{s},params);%load parameters
%     % %
%     %% DCM2NII
%     niiFilesCreate_TR1(params.subjects{s},params)
%
%
%     %% BET
%     if ~exist(fullfile(params.anatomyFolder,[params.subjects{s},'_anatomy_brain.nii.gz']))
%         brainExtraction_TR1(params.subjects{s},params)%remove skull and save brain only
%     end
%
%     %% Preprocessing & subject level FSL
%     % 1st level multiT
%     %  analysis='multiT';
%     analysis='1stlvl_pc';
%     prepFirstlvl_TR1(params,params.subjects{s},analysis)
%
% end


%% bhv analysis-exclud erros and equalize trials
params.subjects={params.subjIDs{[1:3 5:21 23:end]}};
[all_subj_med,RTs,subjTtoExld,subj_crate]=BHV_analysis_TR1_fixed(params);

% %GET BHV DATA AND EQUALIZE TRIALS IN RUN
% for s=1:length(params.subjects)
%     params=setAnalysisParams_TR1(params.subjects{s},params);%load parameters
%     [correct_rate,runsInds,map1Runs,map2Runs,incorrRunInds]=bhv_1stLvl_TR1(params.subjects{s},params);
%     subjTtoExld.(params.subjects{s})=incorrRunInds;
% end
% 
% %get RTs
% RTs=getSemotorRTs(params);
%%Calcuate RT median and save trial data with condition names
% [all_subj_med,S_rt,m_rt,m_fast,m_slow]=calcRT_subj_med_TR1(params,subjTtoExld);




%% pc analysis
params.subjects={params.subjIDs{[1:3 5:21 23:end]}};
for s=1:length(params.subjects)
    params=setAnalysisParams_TR1(params.subjects{s},params);%load parameters
    subj_data_names=[];
    for r=1:params.numOfRuns
        params.pcRunDir=fullfile(params.pcDir,['pc_run' num2str(r)]);
        if ~exist(params.pcRunDir)
            mkdir(params.pcRunDir)
        end
        params.runDir=fullfile(params.sub_MulT_PC_fsfdir,['run' num2str(r) '.feat']);
        params.fName='filtered_func_data';
        %         if ~exist(fullfile(params.pcRunDir,[params.fName '.nii.gz']))
        %             cmd=['cp -r ',fullfile(params.runDir,'filtered_func_data.nii.gz'),' ', fullfile(params.pcRunDir,[params.fName '.nii.gz'])];% coppy func_data
        %             unix(cmd)
        %         end
        
        % register func to MNI
        if ~exist(fullfile(params.pcRunDir,[params.fName '_run' num2str(r) '_MNI.nii.gz']))
            params.fName=reg_MNI_TR1(params,r);
        else
            params.fName=[params.fName '_run' num2str(r) '_MNI'];
        end
        
        
        %% create pc functional data
        if ~exist(fullfile(params.pcRunDir,['pc_' params.fName '.nii.gz']))
            params.pc_funcData=percentChange_correct(params.pcRunDir,params.fName);
        end
        params.fName=['pc_' params.fName];
        %% extract signal (#th TR after cue's TR) for each event & organize  data of interest with informative names for multiT
        params.TRafterEV=5;
        [run_trialsData,run_data_names]=prepPCdata_TR1_fixed(params);
        if r==1
            subj_Data=run_trialsData;
        else
            subj_Data=cat(4,subj_Data,run_trialsData);
        end
        subj_data_names=[subj_data_names;run_data_names];
    end
  
    
    % save in a general multiT data folder
    if ~exist(params.pc_multi_dataDir)
        mkdir(params.pc_multi_dataDir)
    end
    save(fullfile(params.pc_multi_dataDir,['subj_multi_data_pc_TR' num2str(params.TRafterEV) '_fixed2']),'subj_Data','subj_data_names','-v7.3')
    
    
    %     create list and labels for multiT
    %     if ~exist(fullfile(params.pc_multi_dataDir,'all_data.mat'))
    [all_data,all_labels]=create_multi_condLists(subj_data_names,subj_Data,params);
    %     end
end


%% multiT analysis

multiTanalysis();
