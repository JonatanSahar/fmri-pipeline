function runPreProcessing(params)

%% RUN FEAT

for subId=params.subjects
    disp(['analysing subject number: ',num2str(subId)]);
    functionalDir = sprintf(params.functionalDir, subId);
    anatomyDir = sprintf(params.anatomyDir, subId);

    base_str = "%d_EV_%s_%d";
    for condId = 1:length(params.conditions)
        cond = params.conditions(condId);
        numRuns = params.numRunsPerCondition(condId);
        featDir = fullfile(functionalDir, cond,'.feat');
        if exist(featDir,'dir') && ~params.override
            continue
        end
        for condRunNum = 1:numRuns
            fprintf('condition: %s, run#: %d\n', cond, condRunNum);
            cond_str = base_str;
            if contains(cond, 'audiomotor')
                cond_str = base_str + "_*E";
            end

            % build the paths and filenames for all EV files
            sides = ["L", "R", "DISQ"];
            for side = sides
                if side == "DISQ"
                    str = cond_str + "_DISQ.txt";
                    EV_filename = sprintf(str,...
                                          subId,...
                                          cond, ...
                                          condRunNum);
                else
                    str = cond_str + "_%s%s.txt";
                    if contains(cond, 'motor')
                        affector_suffix = 'H';
                    elseif contains(cond, 'auditory')
                        affector_suffix = 'E';
                    end
                    EV_filename = sprintf(str,...
                                          subId,...
                                          cond, ...
                                          condRunNum,...
                                          side, ...
                                          affector_suffix);
                end
                EVDir = sprintf(params.EVDir, subId);
                d = dir(fullfile(EVDir,EV_filename));
                EVPath = fullfile(d.folder, d.name)
                EVPaths.(side) = EVPath;
            end % for side



            % distribute fsf files in functional dirs and run first level Feat
            if contains(cond, 'loc')
                fid = fopen(fullfile(params.fsfdir, 'localizer.fsf')) ;
            else
                fid = fopen(fullfile(params.fsfdir, 'MRI_data.fsf')) ;
            end

            X = fread(fid) ;
            fclose(fid) ;
            X = char(X.') ;
            % replace strings for analysis
            %% set file directories % params
            scanBaseName = sprintf("sub_%d_%s_%d", subId, cond, condRunNum);
            scanName = scanBaseName + ".nii.gz";
            scanPath = fullfile(functionalDir, scanName);

            outputDirPath = fullfile(functionalDir, scanBaseName);
            if isequal(cond, 'audiomotor')
                t = strsplit(d.name, '_');
                ear = t{5};
                scanBaseNameWithEar = sprintf("%s_%s", scanBaseName, ear);
                outputDirPath = fullfile(functionalDir, scanBaseNameWithEar);
            end
            anatomyScanPath = fullfile(anatomyDir, 'anatomy_brain.nii.gz');

            Y = strrep(X, 'pp_dir', scanPath);
            Y = strrep(Y, 'out_dir', outputDirPath);
            Y = strrep(Y, 'templates_dir', params.templateDir) ;
            Y = strrep(Y, 'needs_fieldmap', num2str(params.fieldMap)) ;
            Y = strrep(Y, 'smoothing_param', num2str(params.smoothing)) ;
            Y = strrep(Y, 'is_normalized', num2str(params.normalization)) ;
            Y = strrep(Y, 'anatomy_dir', anatomyScanPath);


            %% set EVs
            Y = strrep(Y, 'right_ev', EVPaths.R);
            Y = strrep(Y, 'left_ev', EVPaths.L);
            Y = strrep(Y, 'disq_ev',EVPaths.DISQ);

            fsfFilename = sprintf("fsf_%d_%s_%d", subId, cond, condRunNum);
            fsfPath = fullfile(params.fsfdir, fsfFilename);
            fid = fopen(fsfPath,'wt') ;
            fwrite(fid,Y) ;
            fclose (fid) ;
            cmd = sprintf('feat %s', fsfPath);
            fprintf("%s\n", cmd);
            % unix(cmd);
            % unix(['firefox ', fullfile(featDir, 'report_log.html')]);
            % unix('rm ', fsfPath);
        end % for condRunNum
    end % for condId
    clear EVPaths
    disp(['finished subject number ',num2str(subId)]);
end % for subId
