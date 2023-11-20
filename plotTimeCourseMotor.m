function plotTimeCourseMotor(cortex)
%% Input:
% ear = {"LH", "RH"}
% cortex = {"LCortex", "RCortex"}

%% For plotting all combinations:
% for cortex = ["LCortex", "RCortex"]
% plotTimeCourseMotor(cortex)
% end
%

    params = setAnalysisParams();;
    data = load(fullfile(params.timeCourseOutDir, "time_course_motor_mean.mat"));
    % Create the variable names dynamically
    varName_LH = strcat('average_LH', '_', cortex);
    varName_RH = strcat('average_RH', '_', cortex);

    % Access the data from the structure dynamically
    LH_data = data.(varName_LH);
    RH_data = data.(varName_RH);

    % Plot the data
    figure; hold on;
    plot(LH_data, 'LineWidth', 1.5);
    plot(RH_data, 'LineWidth', 1.5);

    % Adding Title, Labels, and Legend
    titleStr = sprintf("(Motor-only) Average Activity Over Time: %s", cortex);
    title(titleStr);
    xlabel('Time (sec)');
    ylabel('Activity (% signal change)');
    legend({['LH'], ['RH']}, 'Location', 'best'); % must be in this order - based on order of plotting above
    hold off;

    % Saving the figure to a jpg file

    titleStr = sprintf("Average Motor Activity Over Time %s",cortex);
    fileName = strcat(strrep(titleStr, " ", "_"), '.jpg'); % Replacing spaces with underscores for the filename
    fileName = fullfile(params.experimentDir,  "figures", fileName);
    saveas(gcf, fileName, 'jpg'); % gcf gets the current figure handle, fileName is the desired file name, 'jpg' specifies the file format

end
