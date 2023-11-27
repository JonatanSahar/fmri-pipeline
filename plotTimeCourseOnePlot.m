function plotTimeCourseOnePlot()
    params = setAnalysisParams();;
    data = load(fullfile(params.timeCourseOutDir, "time_course_mean.mat"));
    for ear = ["LE", "RE"]
        figure; hold on;
            % Create the variable names dynamically
            varName_LCortex_LH = strcat('average_', ear, '_LCortex', '_LH');
            varName_LCortex_RH = strcat('average_', ear, '_LCortex', '_RH');
            varName_RCortex_LH = strcat('average_', ear, '_RCortex', '_LH');
            varName_RCortex_RH = strcat('average_', ear, '_RCortex', '_RH');

            % Access the data from the structure dynamically
            LCortex_LH_data = data.(varName_LCortex_LH);
            LCortex_RH_data = data.(varName_LCortex_RH);
            RCortex_LH_data = data.(varName_RCortex_LH);
            RCortex_RH_data = data.(varName_RCortex_RH);

 % Plot the data
            hold on;
            plot(LCortex_LH_data, 'LineWidth', 1.5);
            plot(LCortex_RH_data, 'LineWidth', 1.5);
            plot(RCortex_LH_data, "--", 'LineWidth', 1.5);
            plot(RCortex_RH_data, "--", 'LineWidth', 1.5);

            % Adding Title, Labels, and Legend
            titleStr = sprintf("Average Activity Over Time: %s", ear);
            title(titleStr);
            xlabel('Time (sec)');
            ylabel('Activity (% signal change)');
            legend({ ...
                     ['LCortex_LH'], ...
                     ['LCortex_RH'], ...
                     ['RCortex_LH'], ...
                     ['RCortex_RH']}, ...
                    'Location', 'best'); % must be in this order - based on order of plotting above
            hold off;

            % Saving the figure to a jpg file
            titleStr = sprintf("Average Activity Over Time %s (joint plot)", ear);
            fileName = strcat(strrep(titleStr, " ", "_"), '.jpg'); % Replacing spaces with underscores for the filename
            fileName = fullfile(params.experimentDir,  "figures", fileName);
            saveas(gcf, fileName, 'jpg'); % gcf gets the current figure handle, fileName is the desired file name, 'jpg' specifies the file format

    end
end
