function computeMeanTimeCourseMotor()
    params = setAnalysisParams();
    if ~exist(params.timeCourseOutDir)
        mkdir(params.timeCourseOutDir)
    end
    rng(params.seed);

    % Get file names
    filePattern = fullfile(params.timeCourseOutDir, '*_time_course_motor.mat');
    theFiles = dir(filePattern);

    % Initialize 3D arrays
    all_LH_LCortex = [];
    all_LH_RCortex = [];
    all_RH_LCortex = [];
    all_RH_RCortex = [];

    % Iterate over files(=subjects) and store data
    for k = 1:length(theFiles)
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(theFiles(k).folder, baseFileName);

        % Load the data from .m files
        load(fullFileName);

        % Store data in 3D arrays
        all_LH_LCortex (:,:,k) = LH_LCortex;
        all_LH_RCortex (:,:,k) = LH_RCortex;
        all_RH_LCortex (:,:,k) = RH_LCortex;
        all_RH_RCortex (:,:,k) = RH_RCortex;
    end

    % Initialize the figure
    figure;
    hold on;
    lineWidth = 1.5; % Adjust the line width as necessary
    boldLineWidth = 3.5; % Line width for the average timecourse
    timePoints = size(all_LH_LCortex, 2); % Number of time points

    % Iterate over the third dimension (subjects) and plot each timecourse
    for k = 1:size(all_LH_LCortex, 3)
        plot(1:timePoints, all_LH_LCortex(:, :, k), 'LineWidth', lineWidth);
    end

    % Calculate and plot the average timecourse
    average_timecourse = mean(all_LH_LCortex, 3);
    plot(1:timePoints, average_timecourse, 'k', 'LineWidth', boldLineWidth); % 'k' sets the color to black

    % Customize the plot
    title('Timecourses from all subjects (all LH LCortex)');
    xlabel('Time Points');
    ylabel('Amplitude');
    set(gca, 'FontSize', 12); % Set the font size for axes
    legendEntries = [arrayfun(@(x) sprintf('Subject %d', x), 1:size(all_LH_LCortex, 3), 'UniformOutput', false), {'Average'}];
    legend(legendEntries, 'Location', 'best');
    hold off;



    % Compute mean across the third dimension (subjects)
    average_LH_LCortex = mean(all_LH_LCortex, 3);
    average_LH_RCortex = mean(all_LH_RCortex, 3);
    average_RH_LCortex = mean(all_RH_LCortex, 3);
    average_RH_RCortex = mean(all_RH_RCortex, 3);


    range = [6:10]; % Time in seconds to average across - peak activation time
    % Compute per-subjct mean across the scond dimension (time)
    subject_mean_LH_LCortex = squeeze(mean(all_LH_LCortex(1,range, :), 2))';
    subject_mean_LH_RCortex = squeeze(mean(all_LH_RCortex(1,range, :), 2))';
    subject_mean_RH_LCortex = squeeze(mean(all_RH_LCortex(1,range, :), 2))';
    subject_mean_RH_RCortex = squeeze(mean(all_RH_RCortex(1,range, :), 2))';
    [bIsSignificant_LCortex, p_LCortex] = ttest(subject_mean_LH_LCortex, subject_mean_RH_LCortex);
    [bIsSignificant_RCortex, p_RCortex] = ttest(subject_mean_LH_RCortex, subject_mean_RH_RCortex);

    % Save averaged data to a new .mat file
    fprintf("saving to %s\n", fullfile(params.timeCourseOutDir,  'time_course_motor_mean.mat'))
    save(fullfile(params.timeCourseOutDir,  'time_course_motor_mean.mat'), ...
         'average_LH_LCortex', ...
         'average_LH_RCortex', ...
         'average_RH_LCortex', ...
         'average_RH_RCortex', ...
         'subject_mean_LH_LCortex', ...
         'subject_mean_LH_RCortex', ...
         'subject_mean_RH_LCortex', ...
         'subject_mean_RH_RCortex', ...
         'bIsSignificant_LCortex', ...
         'p_LCortex', ...
         'bIsSignificant_RCortex', ...
         'p_RCortex', ...
         '-v7.3');

    end
