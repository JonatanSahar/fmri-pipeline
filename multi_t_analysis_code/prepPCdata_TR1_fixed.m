function [run_trialsData,run_data_names]=prepPCdata_TR1_fixed(params)

load(fullfile(params.mapFolder,[params.subjects{s} '_run' num2str(r) '.mat']))

load(fullfile(params.pcRunDir,'names_N_presOnsets_fixed.mat'))


%calc volume evs for pc analysis
evOns=[data_names_N_onsets{:,2}];
TR=1;
evols=evOns/TR;
load(fullfile(params.pcRunDir,[params.fName '.mat']))
vxl=[24 55 68];
% inspect_data(vxl,pc_funcData,evols,TR)



%exctract relevant (peak of HRF) volumes from func data and save for multiT analysis
peakVols=evols+params.TRafterEV;
run_trialsData=pc_funcData(:,:,:,peakVols);
run_data_names={data_names_N_onsets{:,1}}';
end