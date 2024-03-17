function plotTimeCourseOnePlotSubplots()
    params = setAnalysisParams();
    data = load(fullfile(params.experimentDir, "time-course-results", "timeCourseSignificantVoxels", "time_course_mean.mat"));
    auditoryData = load(fullfile(params.timeCourseOutDir,  'time_course_auditory_mean.mat'));
    
    % Create tiled layout
    tcl = tiledlayout(2, 2);
    title(tcl, 'Average Activity Over Time');

    ears = ["LE", "RE"];
    cortices = ["LCortex", "RCortex"];

    for i = 1:length(ears)
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
            nexttile;
            hold on;
            plot(LH_data, 'LineWidth', 1.5);
            plot(RH_data, 'LineWidth', 1.5);
            plot(Cortex_data, "--", 'LineWidth', 1.9, 'Color', [0.2 0.5 0.9 0.4]);

            % Adding title and labels
            titleStr = sprintf("Average Activity Over Time: %s, %s", ear, cortex);
            title(titleStr);
            xlabel('Time (sec)');
            ylabel('Activity (% signal change)');
            ylim([-0.3 0.6]);
            legend({'LH', 'RH', 'Auditory only'}, 'Location', 'best');
            hold off;
        end
    end
    
    % Saving the figures to jpg files
    titleStr = "Average Activity Over Time Joint";
    fileName = strcat(strrep(titleStr, " ", "_"), '_subplots', '.jpg');
    fileName = fullfile("figures", fileName);
    set(gcf, 'Position', get(0, 'Screensize'));
    saveas(gcf, fileName, 'jpg');
    
    % Copying and updating figure directory in git
    system("rsync -r  /home/user/Code/fMRI-pipeline/figures/ /media/user/Data/fmri-data/analysis-output/figures/");
    system("cd /home/user/Code/fMRI-pipeline/figures");
    system("git add *");
    system('git commit -am "update figures dir (auto)"');
end
