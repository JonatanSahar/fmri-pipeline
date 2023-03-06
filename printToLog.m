function printToLog(params, subId, S)
    fid = fopen(fullfile(params.experimentDir, ...
                         num2str(subId),'log.txt'), 'a');
    fprintf(fid, S);
    fclose(fid);
end
