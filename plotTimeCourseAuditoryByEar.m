function plotTimeCourseAuditoryByEar(ear)
%% Input:
% ear = {"LE", "RE"}
% cortex = {"LCortex", "RCortex"}

%% For plotting all combinations:
% for cortex = ["LCortex", "RCortex"]
% plotTimeCourseAuditory(cortex)
% end
%

    params = setAnalysisParams();;
    data = load(fullfile(params.timeCourseOutDir, "time_course_auditory_mean.mat"));
    % Create the variable names dynamically
    varName_LCortex = strcat('average_', ear, '_LCortex');
    varName_RCortex = strcat('average_', ear, '_RCortex');

    % Access the data from the structure dynamically
    LCortex_data = data.(varName_LCortex);
    RCortex_data = data.(varName_RCortex);

    % Plot the data
    figure; hold on;
    plot(LCortex_data, 'LineWidth', 1.5);
    plot(RCortex_data, 'LineWidth', 1.5);

    % Adding Title, Labels, and Legend
    titleStr = sprintf("(Auditory-only) Average Activity Over Time: %s", ear);
    title(titleStr);
    xlabel('Time (sec)');
    ylabel('Activity (% signal change)');
    legend({['LCortex'], ['RCortex']}, 'Location', 'best'); % must be in this order - based on order of plotting above
    hold off;

    % Saving the figure to a jpg file

    titleStr = sprintf("Average Auditory Activity Over Time %s",ear);
    fileName = strcat(strrep(titleStr, " ", "_"), '.jpg'); % Replacing spaces with underscores for the filename
    fileName = fullfile(params.experimentDir,  "figures", fileName);
    saveas(gcf, fileName, 'jpg'); % gcf gets the current figure handle, fileName is the desired file name, 'jpg' specifies the file format

end
