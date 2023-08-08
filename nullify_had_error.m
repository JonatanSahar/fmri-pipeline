function nullify_had_error()
% Define the range of subject numbers
subject_nums = [108 112];

% Define the range of runs
runs = 1:4;

% Loop over the subjects
for i = 1:length(subject_nums)
    directory_path = ['/media/user/Data/fmri-data/raw-data/behavioral/' num2str(subject_nums(i)) '/'];

    % Loop over the runs
    for j = 1:length(runs)
        % Generate the filename
        filename = [directory_path num2str(subject_nums(i)) '_audiomotor_' num2str(runs(j)) '.mat'];

        % Load the data from the .mat file
        loaded_data = load(filename);

        % Check if the loaded data has eventTable
        if isfield(loaded_data, 'eventTable')
            % Update 'had_error' column as logical OR between 'INCOMPLETE' and 'WRONG_RESPONSE'
            loaded_data.eventTable.had_error = loaded_data.eventTable.INCOMPLETE | loaded_data.eventTable.WRONG_RESPONSE;
        else
            disp(['No eventTable in file: ' filename])
        end

    % Save the updated table back to the .mat file
    save(filename, '-struct', 'loaded_data');

    % Display a success message
    disp(['Updated file: ' filename])
    end
end
