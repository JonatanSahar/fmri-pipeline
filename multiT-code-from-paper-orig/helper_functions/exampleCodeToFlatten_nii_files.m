function exampleCodeToFlatten_nii_files()
%% how to flattern data, and run searchlight throgh it 

% Input : *.nii file with paramater estimates and mask file (usually brain,
% but can be ROI's as well. 

% Output: .mat files that flattened .nii in a 2D matrix 

% Uses  : Precomputed group mask file. 

% Requires - neuroelf toolbox - http://neuroelf.net/

%% params
params.mskfn           = fullfile(pwd,'example_mask.nii');  % file with a mask 
params.prm_est_nii_fn  = fullfile(pwd,'example_param_estimate.nii'); % file with param estimates 
params.res             = 3; % voxel resolution 
params.searchlightsize = 27;

%% load files 
n = neuroelf;
% load data 
vmp_params = n.importvmpfromspms(params.prm_est_nii_fn,'a',[],params.res); % import at resolution 3mm
dataRaw = vmp_params.Map.VMPData;
% load mask 
vmp_mask = n.importvmpfromspms(params.mskfn,'a',[],params.res); % import at resolution 3mm
dataMask = vmp_mask.Map.VMPData;
locations = getLocations(logical(dataMask));
% get data in 2D 
data = reverseScoringToMatrix1rowAnsMat(dataRaw,locations);

%% create searchlight based on eucledian distinace 
idx = knnsearch(locations, locations, 'K', params.searchlightsize); % neighbours



end
