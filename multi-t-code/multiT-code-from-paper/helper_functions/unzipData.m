function unzipData()
filesToUnzip = findFilesBVQX(fullfile('..','raw'),'*.tar'); 
if isempty(filesToUnzip)
    error('Raw data files not downloaded, see downloadData.m for details'); 
else
end
% extract data to data dir: 
fprintf('note that this may take a few hours since data set is very large!'); 
datadir = fullfile('..','data'); 
for i = 1:length(filesToUnzip)
    untar(filesToUnzip{i},datadir);
end
extractedDataPath = datadir; 
foldersOfData = findFilesBVQX(extractedDataPath,'sub*.zip');
for i = 1:length(foldersOfData)
    %% unzip the data folders 
    zipFile = foldersOfData{i};
    [fn,pn] = fileparts(zipFile); 
    outdir = fullfile(fn,pn);
    mkdir(outdir);
    fprintf('started unzipping file %s at time %s\t\t\n',pn,datestr(clock,0))
    unzip(zipFile,extractedDataPath);
    delete(zipFile); % delete the zipped file 
    fprintf('finished unzipping file %s at time %s\t\t\n',pn,datestr(clock,0))
    %% gunzip the functional .nii to a format that spm expects
    niiFile = findFilesBVQX(fullfile(outdir,'func'),'*.gz');
    if ~isempty(niiFile) % the data went stragith to .nii
        [~,fn] = fileparts(niiFile{1});
        niiFile = findFilesBVQX(fullfile(outdir,'func'),'*.gz');
        gunzip(niiFile{1});  % unzip functional data
        delete(niiFile{1});     % delete the zipped data
    end
    niiFile = findFilesBVQX(fullfile(outdir,'func'),'*.nii');
    fprintf('started unpacking nii from 4d to 3d %s at time %s\t\t\n',fn,datestr(clock,0))
    spm_file_split(niiFile{1}); % expand to 3D
    delete(niiFile{1});  % delete 4D
    fprintf('finished  unpacking nii  %s at time %s\t\t\n',fn,datestr(clock,0))
end
