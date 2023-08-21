function moveFilesOutOfRawDataDir(subnum)
searchPattern = {'sub','asub','wasub','swasub'};
dirNamesToCreate = {'rawData','realigned_data','normalized_data','smoothed_data'};

substorun = subnum;
for j = 1:length(searchPattern)
    subfold = sprintf('sub%s_Ed',substorun);
    subFuncDir = fullfile(rootdir,subfold,'func');
    moveToDir = fullfile(subFuncDir,dirNamesToCreate{j});
    mkdir(moveToDir);
    filesToMove= fullfile(subFuncDir,...
        [searchPattern{j} '*.nii']);
    [fn,pn] = fileparts(subFuncDir);
    try
        movefile(filesToMove,moveToDir);
        fprintf('moved files for sub %s dir %s\n',fn,dirNamesToCreate{j})
    catch
        fprintf('did not move files for sub %s dir %s\n',fn,dirNamesToCreate{j})
    end
end

end
