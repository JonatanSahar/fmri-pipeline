function plotTimeCourseAuditory(cortex)
%% Input:
% ear = {"LE", "RE"}
% cortex = {"LCortex", "RCortex"}

%% For plotting all combinations:
% for cortex = ["LCortex", "RCortex"]
% plotTimeCourseAuditory(cortex)
% end
%

    params = setAnalysisParams();
    data = load(fullfile(params.timeCourseOutDir, "time_course_auditory_mean.mat"));
    % Create the variable names dynamically
    varName_LE = strcat('average_LE', '_', cortex);
    varName_RE = strcat('average_RE', '_', cortex);

    % Access the data from the structure dynamically
    LE_data = data.(varName_LE);
    RE_data = data.(varName_RE);

    % Plot the data
    figure; hold on;
    plot(LE_data, 'LineWidth', 1.5);
    plot(RE_data, 'LineWidth', 1.5);

    % Adding Title, Labels, and Legend
    titleStr = sprintf("(Auditory-only) Average Activity Over Time: %s", cortex);
    title(titleStr);
    xlabel('Time (sec)');
    ylabel('Activity (% signal change)');
    legend({['LE'], ['RE']}, 'Location', 'best'); % must be in this order - based on order of plotting above
    hold off;

    % Saving the figure to a jpg file

    titleStr = sprintf("Average Auditory Activity Over Time %s",cortex);
    fileName = strcat(strrep(titleStr, " ", "_"), '.jpg'); % Replacing spaces with underscores for the filename
    fileName = fullfile(params.experimentDir,  "figures", fileName);
    saveas(gcf, fileName, 'jpg'); % gcf gets the current figure handle, fileName is the desired file name, 'jpg' specifies the file format

    system("rsync -r /media/user/Data/fmri-data/analysis-output/figures/ /home/user/Code/fMRI-pipeline/figures/")
end
