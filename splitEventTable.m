function splitEventTable(T, condition, output_name_prefix, output_dir)

    fields_to_keep = ["start_time",...
                    "play_duration",...
                    "weight"];

    ear = T.ear(1); % each audiomotor run has feedback to a single ear.
                    % % add a constant weight column
                    % T.weight = ones(length(T.ear), 1);

    idx.DISQ = T.had_error > 0;
    idx.LE = T.ear == 'L' & ~idx.DISQ;
    idx.RE = T.ear == 'R' & ~idx.DISQ;
    idx.LH = T.hand == 'L' & ~idx.DISQ;
    idx.RH = T.hand == 'R' & ~idx.DISQ;



    if contains(condition, 'motor')
        conditionNames = ['DISQ', "LH", 'RH'];
    else
        conditionNames = ['DISQ', "LE", 'RE'];
    end


    for condName = conditionNames
        newT = array2table(T{idx.(condName), :},'VariableNames', T.Properties.VariableNames);
        newT = newT(:, fields_to_keep);


        if isequal(condition, 'audiomotor')
            % add which ear it was
            file_name = sprintf("%s_%sE_%s", output_name_prefix, ear, condName);
        else
            % here we get the ear/hand from the caller
            file_name = sprintf("%s_%s", output_name_prefix, condName);
        end

        if size(newT, 1) < 1
            for field = fields_to_keep
                newT.(field)(1) = 0;
            end
        end
        save(fullfile(output_dir, file_name), "newT");
        writetable(newT, ...
                   fullfile(output_dir, file_name), ...
                   'Delimiter', ...
                   'tab', ...
                   'WriteVariableNames', ...
                   false);

    end

end
