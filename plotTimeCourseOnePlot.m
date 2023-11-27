function plotTimeCourseOnePlot()
    params = setAnalysisParams();
    data = load(fullfile(params.experimentDir, "figures", "timeCourseSignificantVoxels", "time_course_mean.mat"));
    auditoryData = load(fullfile(params.timeCourseOutDir,  'time_course_auditory_mean.mat'));
    for ear = ["LE", "RE"]
        % Create the variable names dynamically
        varName_LCortex_LH = strcat('average_', ear, '_LCortex', '_LH');
        varName_LCortex_RH = strcat('average_', ear, '_LCortex', '_RH');
        varName_RCortex_LH = strcat('average_', ear, '_RCortex', '_LH');
        varName_RCortex_RH = strcat('average_', ear, '_RCortex', '_RH');

        varName_LE_LCortex =  strcat('average_', ear, '_LCortex');
        varName_LE_RCortex =  strcat('average_', ear, '_RCortex');
        varName_RE_LCortex =  strcat('average_', ear, '_LCortex');
        varName_RE_RCortex =  strcat('average_', ear, '_RCortex');

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
        plot(LCortex_LH_data, 'LineWidth', 1.5);
        plot(LCortex_RH_data, 'LineWidth', 1.5);
       switch ear
         case "LE"
        plot(LE_LCortex_data, "--", 'LineWidth', 1.9, 'Color', [0.2 0.5 0.9 0.4]);
         case "RE"
        plot(RE_LCortex_data, "--", 'LineWidth', 1.9, 'Color', [0.2 0.5 0.9 0.4]);
       end

        % Adding Title, Labels, and Legend
        titleStr = sprintf("Average Activity Over Time: %s, LCortex", ear);
        title(titleStr);
        xlabel('Time (sec)');
        ylabel('Activity (% signal change)');
        ylim([-0.3 0.6])
        legend({ ...
                 ['LCortex, LH'], ...
                 ['LCortex, RH'], ...
                 ['LCortex auditory']}, ...
               'Location', 'best'); % must be in this order - based on order of plotting above
       hold off

        % Saving the figure to a jpg file
        titleStr = sprintf("Average Activity Over Time %s LCortex joint", ear);
        fileName = strcat(strrep(titleStr, " ", "_"), '.jpg'); % Replacing spaces with underscores for the filename
        fileName = fullfile(params.experimentDir,  "figures", fileName);
        saveas(gcf, fileName, 'jpg'); % gcf gets the current figure handle, fileName is the desired file name, 'jpg' specifies the file format

       %% Plotting R cortex
        figure
        hold on
        plot(RCortex_LH_data,  'LineWidth', 1.5);
        plot(RCortex_RH_data,  'LineWidth', 1.5);
       switch ear
         case "LE"
        plot(LE_RCortex_data, "--", 'LineWidth', 1.9, 'Color', [0.2 0.5 0.9 0.4]);
         case "RE"
        plot(RE_RCortex_data, "--", 'LineWidth', 1.9, 'Color', [0.2 0.5 0.9 0.4]);
       end

        % Adding Title, Labels, and Legend
        titleStr = sprintf("Average Activity Over Time: %s, RCortex", ear);
        title(titleStr);
        xlabel('Time (sec)');
        ylabel('Activity (% signal change)');
        ylim([-0.3 0.6])
        legend({ ...
                 ['LCortex, LH'], ...
                 ['LCortex, RH'], ...
                 ['LCortex auditory']}, ...
               'Location', 'best'); % must be in this order - based on order of plotting above
       hold off
       

        % Saving the figure to a jpg file
        titleStr = sprintf("Average Activity Over Time %s RCortex joint", ear);
        fileName = strcat(strrep(titleStr, " ", "_"), '.jpg'); % Replacing spaces with underscores for the filename
        fileName = fullfile(params.experimentDir,  "figures", fileName);
        saveas(gcf, fileName, 'jpg'); % gcf gets the current figure handle, fileName is the desired file name, 'jpg' specifies the file format

    end
end
