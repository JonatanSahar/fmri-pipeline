function errors = count_errors()
    % Define the range of subject numbers
    subject_nums = [103:106 108:114];
    errorField = "TOO_MANY_EVENTS";
    errorField = "had_error";
    % Define the range of runs
    runs = 1:2;

    % Preallocate arrays to store error counts for each hand
    errors_L = zeros(length(subject_nums), 1);
    errors_R = zeros(length(subject_nums), 1);

    % Loop over the subjects
    for i = 1:length(subject_nums)
        % Define the directory path
        directory_path = ['/media/user/Data/fmri-data/raw-data/behavioral/' num2str(subject_nums(i)) '/'];

        % Initialize counters for errors for each hand
        error_count_L = 0;
        error_count_R = 0;

        % Loop over the runs
        for j = 1:length(runs)
            % Generate the filename with full directory path
            filename = [directory_path num2str(subject_nums(i)) '_motorLoc_' num2str(runs(j)) '.mat'];

            % Load the data from the .mat file
            loaded_data = load(filename);

            % Check if the loaded data has eventTable
            if isfield(loaded_data, 'eventTable')
                % Count 'TOO_MANY_EVENTS' errors for each hand
                error_count_L = error_count_L + sum((loaded_data.eventTable.TOO_MANY_EVENTS > 0) & (loaded_data.eventTable.hand == 'L'));
                error_count_R = error_count_R + sum((loaded_data.eventTable.TOO_MANY_EVENTS > 0) & (loaded_data.eventTable.hand == 'R'));
            else
                disp(['No eventTable in file: ' filename])
            end
        end

        % Store the error counts for this subject for each hand
        errors_L(i) = error_count_L;
        errors_R(i) = error_count_R;
    end
    % Create a table with the error counts for each subject and each hand
    errorTable = table(subject_nums', errors_L, errors_R, 'VariableNames', {'Subject', 'Errors_Left_Hand', 'Errors_Right_Hand'});
    disp(errorTable);
end
