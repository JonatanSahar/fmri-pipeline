function plotTimeCourseMotorOnePlotSubplots()
    params = setAnalysisParams();
    data = load(fullfile(params.experimentDir, "time-course-results", "timeCourseSignificantVoxels", "time_course_motor_mean.mat"));
    auditoryData = load(fullfile(params.timeCourseOutDir,  'time_course_auditory_mean.mat'));
    
    cortices = ["LCortex", "RCortex"];
    
    % Create tiled layout
    tcl = tiledlayout(1, 2);
    
    for i = 1:length(cortices)
        cortex = cortices(i);
        
        % Create the variable names dynamically
        varName_LH = strcat('average', '_LH', '_', cortex);
        varName_RH = strcat('average', '_RH', '_', cortex);
        varName_LE = strcat('average_LE', '_', cortex);
        varName_RE = strcat('average_RE', '_', cortex);

        % Access the data from the structure dynamically
        LH_data = data.(varName_LH);
        RH_data = data.(varName_RH);
        LE_data = auditoryData.(varName_LE);
        RE_data = auditoryData.(varName_RE);

        % Plotting in next tile
        nexttile;
        hold on;
        plot(LH_data, 'LineWidth', 1.5, 'Color', [0.9 0.1 0.1]);
        plot(RH_data, 'LineWidth', 1.5, 'Color', [0.2 0.5 0.9]);
        plot(LE_data, "--", 'LineWidth', 1.9, 'Color', [0.9 0.1 0.1 0.4]);
        plot(RE_data, "--", 'LineWidth', 1.9, 'Color', [0.2 0.5 0.9 0.4]);

        % Adding title and labels
        titleStr = sprintf("Average Activity Over Time: %s", cortex);
        title(titleStr);
        xlabel('Time (sec)');
        ylabel('Activity (% signal change)');
        ylim([-0.3 0.6]);
        legend({'LH', 'RH', 'LE auditory', 'RE auditory'}, 'Location', 'best');
        hold off;
    end
    
    % Adding common title
    title(tcl, 'Motor Activity Over Time');
    
    % Saving the figure to a jpg file
    titleStr = sprintf("Average Activity Over Time Motor Cortex");
    fileName = strcat(strrep(titleStr, " ", "_"),'_subplots', '.jpg'); % Replacing spaces with underscores for the filename
    fileName = fullfile("figures", fileName);
    set(gcf, 'Position', get(0, 'Screensize'));
    saveas(gcf, fileName, 'jpg'); % gcf gets the current figure handle, fileName is the desired file name, 'jpg' specifies the file format
    
    % Copying and updating figure directory in git
    system("rsync -r  /home/user/Code/fMRI-pipeline/figures/ /media/user/Data/fmri-data/analysis-output/figures/");
    system("cd /home/user/Code/fMRI-pipeline/figures");
    system("git add *");
    system('git commit -am "update figures dir (auto)"');
end
