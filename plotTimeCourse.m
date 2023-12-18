function plotTimeCourse(ear, cortex)
%% Input:
% ear = {"LE", "RE"}
% cortex = {"LCortex", "RCortex"}

%% For plotting all combinations:
% for ear = ["LE", "RE"]
% for cortex = ["LCortex", "RCortex"]
% plotTimeCourse(ear, cortex)
% end
% end


    params = setAnalysisParams();;
    data = load(fullfile(params.timeCourseOutDir, "time_course_mean.mat"));

    % Create the variable names dynamically
    varName_LH = strcat('average_', ear, '_', cortex, '_LH');
    varName_RH = strcat('average_', ear, '_', cortex, '_RH');

    % Access the data from the structure dynamically
    LH_data = data.(varName_LH);
    RH_data = data.(varName_RH);

    % Plot the data
    % figure; hold on;
    plot(LH_data, 'LineWidth', 1.5);
    plot(RH_data, 'LineWidth', 1.5);

    % Adding Title, Labels, and Legend
    titleStr = sprintf("Average Activity Over Time: %s, %s", ear, cortex);
    title(titleStr);
    xlabel('Time (sec)');
    ylabel('Activity (% signal change)');
    legend({['LH'], ['RH']}, 'Location', 'best'); % must be in this order - based on order of plotting above
    % hold off;

    % Saving the figure to a jpg file

    titleStr = sprintf("Average Activity Over Time %s %s", ear, cortex);
    fileName = strcat(strrep(titleStr, " ", "_"), '.jpg'); % Replacing spaces with underscores for the filename
    fileName = fullfile(params.experimentDir,  "figures", fileName);
    saveas(gcf, fileName, 'jpg'); % gcf gets the current figure handle, fileName is the desired file name, 'jpg' specifies the file format

    system("rsync -r /media/user/Data/fmri-data/analysis-output/figures/ /home/user/Code/fMRI-pipeline/figures/")
    system("cd /home/user/Code/fMRI-pipeline/figures")
    system("git add *")
    system('git commit -am "update figres dir (auto)"');

end
