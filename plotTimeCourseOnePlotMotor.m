function plotTimeCourseOnePlot()
    params = setAnalysisParams();
    data = load(fullfile(params.experimentDir, "time-course-results", "timeCourseSignificantVoxels", "time_course_motor_mean.mat"));
    auditoryData = load(fullfile(params.timeCourseOutDir,  'time_course_auditory_mean.mat'));
        % Create the variable names dynamically
        varName_LCortex_LH = strcat('average', '_LH', '_LCortex');
        varName_LCortex_RH = strcat('average', '_RH', '_LCortex');
        varName_RCortex_LH = strcat('average', '_LH', '_RCortex');
        varName_RCortex_RH = strcat('average', '_RH', '_RCortex');

        varName_LE_LCortex =  'average_LE_LCortex';
        varName_LE_RCortex =  'average_LE_RCortex';
        varName_RE_LCortex =  'average_RE_LCortex';
        varName_RE_RCortex =  'average_RE_RCortex';

        % Access the data from the structure dynamically
        LCortex_LH_data = data.(varName_LCortex_LH);
        LCortex_RH_data = data.(varName_LCortex_RH);
        RCortex_LH_data = data.(varName_RCortex_LH);
        RCortex_RH_data = data.(varName_RCortex_RH);

        LE_LCortex_data = (auditoryData.(varName_LE_LCortex));
        LE_RCortex_data = (auditoryData.(varName_LE_RCortex));
        RE_LCortex_data = (auditoryData.(varName_RE_LCortex));
        RE_RCortex_data = (auditoryData.(varName_RE_RCortex));


       %% Plotting L cortex
        figure
        hold on
        plot(LCortex_LH_data, 'LineWidth', 1.5, 'Color', [0.9 0.1 0.1]);
        plot(LCortex_RH_data, 'LineWidth', 1.5, 'Color', [0.2 0.5 0.9]);
        plot(LE_LCortex_data, "--", 'LineWidth', 1.9, 'Color', [0.9 0.1 0.1 0.4]);
        plot(RE_LCortex_data, "--", 'LineWidth', 1.9, 'Color', [0.2 0.5 0.9 0.4]);

        % Adding Title, Labels, and Legend
        titleStr = sprintf("Average Activity Over Time: LCortex");
        title(titleStr);
        xlabel('Time (sec)');
        ylabel('Activity (% signal change)');
        ylim([-0.3 0.6])
        legend({ ...
                 ['LCortex, LH'], ...
                 ['LCortex, RH'], ...
                 ['LCortex, LE auditory'], ...
                 ['LCortex, RE auditory']}, ...
               'Location', 'best'); % must be in this order - based on order of plotting above
       hold off

        % Saving the figure to a jpg file
        titleStr = sprintf("Average Activity Over Motor Time LCortex joint");
        fileName = strcat(strrep(titleStr, " ", "_"), '.jpg'); % Replacing spaces with underscores for the filename
        fileName = fullfile(params.experimentDir,  "figures", fileName);
        saveas(gcf, fileName, 'jpg'); % gcf gets the current figure handle, fileName is the desired file name, 'jpg' specifies the file format

       %% Plotting R cortex
        figure
        hold on
        plot(RCortex_LH_data,  'LineWidth', 1.5, 'Color', [0.9 0.1 0.1]);
        plot(RCortex_RH_data,  'LineWidth', 1.5, 'Color', [0.2 0.5 0.9]);
        plot(LE_RCortex_data, "--", 'LineWidth', 1.9, 'Color', [0.9 0.1 0.1 0.4]);
        plot(RE_RCortex_data, "--", 'LineWidth', 1.9, 'Color', [0.2 0.5 0.9 0.4]);

        % Adding Title, Labels, and Legend
        titleStr = sprintf("Average Activity Over Time: RCortex");
        title(titleStr);
        xlabel('Time (sec)');
        ylabel('Activity (% signal change)');
        ylim([-0.3 0.6])
        legend({ ...
                 ['RCortex, LH'], ...
                 ['RCortex, RH'], ...
                 ['RCortex, LE auditory'], ...
                 ['RCortex, RE auditory']}, ...
               'Location', 'best'); % must be in this order - based on order of plotting above
       hold off
       

        % Saving the figure to a jpg file
        titleStr = sprintf("Average Activity Over Time Motor RCortex joint");
        fileName = strcat(strrep(titleStr, " ", "_"), '.jpg'); % Replacing spaces with underscores for the filename
        fileName = fullfile(params.experimentDir,  "figures", fileName);
        saveas(gcf, fileName, 'jpg'); % gcf gets the current figure handle, fileName is the desired file name, 'jpg' specifies the file format

    system("rsync -r /media/user/Data/fmri-data/analysis-output/figures/ /home/user/Code/fMRI-pipeline/figures/")
    system("cd /home/user/Code/fMRI-pipeline/figures")
    system("git add *")
    system('git commit -am "update figres dir (auto)"');
end
