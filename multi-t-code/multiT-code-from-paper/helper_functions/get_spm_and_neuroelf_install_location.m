function get_spm_and_neuroelf_install_location() 
% you can get SPM here if you do not already have it: 
% http://www.fil.ion.ucl.ac.uk/spm/software/spm12/
spmdir = uigetdir(pwd,'please select the directory with SPM12 install\n');
p  = genpath(spmdir);
addpath(p); 
neuroelfdir = uigetdir(pwd,'please select the directory with neuroelf install\n');
p  = genpath(neuroelfdir);
addpath(p); 
end