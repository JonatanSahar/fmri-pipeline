function plotTimeCourseMotorSubplots()
params = setAnalysisParams();
data = load(fullfile(params.experimentDir, "time-course-results", "timeCourseSignificantVoxels", "time_course_motor_mean.mat"));
auditoryData = load(fullfile(params.timeCourseOutDir,  'time_course_auditory_mean.mat'));

cortices = ["LCortex", "RCortex"];

% Create tiled layout
monitorPos = get(0, 'MonitorPositions'); % Get positions and sizes of all monitors
secondaryMonitor = monitorPos(1, :); % Assuming the primary monitor is the first one

% figure('Position', secondaryMonitor); % Set figure position to primary monitor size
figure('Position', [100, 100, 2000,1000]);
tcl = tiledlayout(1, 2);
fontsize = 32; % Set your desired font
subtitleFontsize = 24; % Set your desired font
tickLabelFontSize = 24; % Font size for tick labels

%     ax1 = nexttile;
%     ax2 = nexttile;

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
    ax = nexttile;
    set([ax], 'FontSize', fontsize);
    set([ax], 'XTickLabel', num2cell(get(ax, 'XTick')), 'XTickLabelMode', 'manual', 'YTickLabel', num2cell(get(ax, 'YTick')), 'YTickLabelMode', 'manual');
    set([ax], {'FontSize'}, {tickLabelFontSize}); % Specific font size for tick labels

    hold on;
    lineWidth = 3.5;

    plot(LH_data, 'LineWidth', lineWidth,'Color', [0.9 0.1 0.1]);
    plot(RH_data, 'LineWidth', lineWidth, 'Color', [0.2 0.5 0.9]);
    plot(LE_data, "--", 'LineWidth', lineWidth, 'Color', [0.9 0.1 0.1 0.4]);
    plot(RE_data, "--", 'LineWidth', lineWidth, 'Color', [0.2 0.5 0.9 0.4]);

    % Adding title and labels
        titleStr = sprintf("%s",cortex);
        title(titleStr, 'FontSize', subtitleFontsize);
        xlabel('Time (sec)', 'FontSize', fontsize);
        ylabel('Activity (% signal change)', 'FontSize', fontsize);
        ylim([-0.3 0.6]);
        if cortex == "RCortex"
            legend({'LH', 'RH', 'LE auditory', 'RE auditory'}, 'Location', 'best');
        end
        hold off;
    end

    % Adding common title
    title(tcl, 'Average Motor Activity Over Time', 'FontSize', fontsize);

    % Saving the figure to a jpg file
    titleStr = sprintf("Average Activity Over Time Motor Cortex");
    fileName = strcat(strrep(titleStr, " ", "_"),'_subplots', '.jpg'); % Replacing spaces with underscores for the filename
    fileName = fullfile("figures", fileName);



    saveas(gcf, fileName, 'jpg'); % gcf gets the current figure handle, fileName is the desired file name, 'jpg' specifies the file format

    % Copying and updating figure directory in git
    system("rsync -r  /home/user/Code/fMRI-pipeline/figures/ /media/user/Data/fmri-data/analysis-output/figures/");
    system("cd /home/user/Code/fMRI-pipeline/figures");
    system("git add *");
    system('git commit -am "update figures dir (auto)"');
end
