function plotHist()
    params = setAnalysisParams();
    % Plot the data
    subId = 101;
    D = load(fullfile(params.timeCourseOutDir,  sprintf("%d_time_course_hist_data", subId)));
    for ear = ["LE", "RE"]
        for  auditoryCortex = ["leftC", "rightC"]
            LH_data = [];
            RH_data = [];
            switch ear
              case "LE"
                LH_data = D.data_LE{1}.auditoryCortexMean.(auditoryCortex).LH ;
                RH_data = D.data_LE{1}.auditoryCortexMean.(auditoryCortex).RH ;
              case "RE"
                LH_data = D.data_RE{1}.auditoryCortexMean.(auditoryCortex).LH ;
                RH_data = D.data_RE{1}.auditoryCortexMean.(auditoryCortex).RH ;
            end %switch

            figure; hold on;
            plot(LH_data, 'LineWidth', 1.5);
            plot(RH_data, 'LineWidth', 1.5);

            % Adding Title, Labels, and Legend
            titleStr = sprintf("Histogram of values at t=10s, %s, %s", ear, auditoryCortex);
            title(titleStr);
            xlabel('Time (sec)');
            ylabel('Activity (% signal change)');
            legend({['LH'], ['RH']}, 'Location', 'best'); % must be in this order - based on order of plotting above
            hold off;

            % Saving the figure to a jpg file

            titleStr = sprintf("Histogram of values %s, %s", ear, auditoryCortex);
            fileName = strcat(strrep(titleStr, " ", "_"), '.jpg'); % Replacing spaces with underscores for the filename
            fileName = fullfile(params.experimentDir,  "figures", fileName);
            saveas(gcf, fileName, 'jpg'); % gcf gets the current figure handle, fileName is the desired file name, 'jpg' specifies the file format
        end % for ear
    end   % for cortex
end
