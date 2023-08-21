function [ sucess_message ] = downloadData()
%% this function downloads the data needed to run the analysis from open fMRI 

fprintf('- Downloading data from open fMRI:\n')
fprintf('--- Note that this will require 15GB of hard drive space at least!\n')
user_response = input('---- Do you want to proceed (y/n)?\n ','s');
if strcmp(user_response,'y')
else 
    error('user does not want to download files');
end
fprintf('--- Further note that this may take a long time to excecut - downloading 15GB!\n')

path_to_data = fullfile('..','raw');
filenamewrite = fullfile(path_to_data,'Part1-Subjects1-99.tar');
urlwrite ('http://datashare.is.ed.ac.uk/bitstream/handle/10283/818/Part1-Subjects1-99.tar?sequence=2&isAllowed=y',filenamewrite)
filenamewrite = fullfile(path_to_data,'Part2-Subjects100-218.tar');
urlwrite ('http://datashare.is.ed.ac.uk/bitstream/handle/10283/818/Part2-Subjects100-218.tar?sequence=3&isAllowed=y',filenamewrite)

end

