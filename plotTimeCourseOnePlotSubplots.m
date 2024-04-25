function plotTimeCourseOnePlotSubplots()
    params = setAnalysisParams();
    data = load(fullfile(params.experimentDir, "time-course-results", "timeCourseSignificantVoxels", "time_course_mean.mat"));
    auditoryData = load(fullfile(params.timeCourseOutDir,  'time_course_auditory_mean.mat'));
    
    % Create tiled layout
    ears = ["LE", "RE"];
    cortices = ["LCortex", "RCortex"];

    for i = 1:length(ears)
      figure('Position', [100, 100, 2000,1000]);
      tcl = tiledlayout(1, 2);
      fontsize = 32; % Set your desired font
      subTitleFontsize = 20; % Set your desired font
      tickLabelFontSize = 24; % Font size for tick labels

      title(tcl, 'Average Activity Over Time', 'FontSize', fontsize);

        ear = ears(i);
        
        for j = 1:length(cortices)
            cortex = cortices(j);

            % Create the variable names dynamically
            varName_LH = strcat('average_', ear, '_', cortex, '_LH');
            varName_RH = strcat('average_', ear, '_', cortex, '_RH');
            varName_Cortex = strcat('average_', ear, '_', cortex);

            % Access the data from the structure dynamically
            LH_data = data.(varName_LH);
            RH_data = data.(varName_RH);
            Cortex_data = auditoryData.(varName_Cortex);

            % Plotting in next tile
            ax = nexttile;
            set([ax], 'FontSize', fontsize-10);
            set([ax], 'XTickLabel', num2cell(get(ax, 'XTick')), 'XTickLabelMode', 'manual', 'YTickLabel', num2cell(get(ax, 'YTick')), 'YTickLabelMode', 'manual');
            set([ax], {'FontSize'}, {tickLabelFontSize}); % Specific font size for tick labels

            hold on;
            lineWidth = 3.5;
            plot(LH_data, 'LineWidth', lineWidth);
            plot(RH_data, 'LineWidth', lineWidth);
            plot(Cortex_data, "--", 'LineWidth', lineWidth, 'Color', [0.2 0.5 0.9 0.4]);

            % Adding title and labels
            titleStr = sprintf("%s, %s", ear, cortex);
            title(titleStr, 'FontSize', subTitleFontsize);
            xlabel('Time (sec)');
            if cortex == "LCortex" 
                hLabel = ylabel('Activity (% signal change)');

                % Get current position of the ylabel
                currentPosition = get(hLabel, 'Position');

                % Increase the y-value to shift it upwards
                newPosition = currentPosition + [0 0 0]; % Adjust the 0.1 as needed

                % Set the new position of the ylabel
                set(hLabel, 'Position', newPosition);
            end
            ylim([-0.3 0.6]);
            legend({'LH', 'RH', 'Auditory only'}, 'Location', 'best');
            hold off;
        end
        % Saving the figures to jpg files
        titleStr = sprintf("Average Activity Over Time Joint %s %s", ear, cortex);
        fileName = strcat(strrep(titleStr, " ", "_"), '_subplots', '.jpg');
        fileName = fullfile("figures", fileName);

        %     set(gcf, 'Position', get(0, 'Screensize'));
        saveas(gcf, fileName, 'jpg');
    end
    

    % Copying and updating figure directory in git
    system("rsync -r  /home/user/Code/fMRI-pipeline/figures/ /media/user/Data/fmri-data/analysis-output/figures/");
    system("cd /home/user/Code/fMRI-pipeline/figures");
    system("git add *");
    system('git commit -am "update figures dir (auto)"');
end
