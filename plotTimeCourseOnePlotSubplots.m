function plotTimeCourseOnePlotSubplots()
params = setAnalysisParams();
data = load(fullfile(params.experimentDir, "time-course-results", "timeCourseSignificantVoxels", "time_course_mean.mat"));
auditoryData = load(fullfile(params.timeCourseOutDir,  'time_course_auditory_mean.mat'));

% Create tiled layout
ears = ["LE", "RE"];
earNames = ["Left ear", "Right ear"]
cortices = ["LCortex", "RCortex"];
cortexNames = ["Left auditory cortex", "Right auditory cortex"]

for i = 1:length(ears)
    figure('Position', [100, 100, 2000,1000]);
    tcl = tiledlayout(1, 2);
    fontsize = 32; % Set your desired font
    subTitleFontsize = 24; % Set your desired font
    tickLabelFontSize = 24; % Font size for tick labels

    title(tcl, 'Average Activity Over Time', 'FontSize', fontsize);

    ear = ears(i);
    earName = earNames(i)
    for j = 1:length(cortices)
        cortex = cortices(j);
        cortexName = cortexNames(j())
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
%         set([ax], 'XTickLabel', num2cell(get(ax, 'XTick')), 'XTickLabelMode', 'manual', 'YTickLabel', num2cell(get(ax, 'YTick')), 'YTickLabelMode', 'manual');
%         set([ax], {'FontSize'}, {tickLabelFontSize}); % Specific font size for tick labels

        % Ensure tick labels are set to indices
        x_indices = 1:length(LH_data); % Assuming all data have the same length

        hold on;
        lineWidth = 3.5;
        plot(x_indices, LH_data, 'LineWidth', lineWidth);
        plot(x_indices, RH_data, 'LineWidth', lineWidth);
        plot(x_indices, Cortex_data, "--", 'LineWidth', lineWidth, 'Color', [0.2 0.5 0.9 0.4]);


        % Setting the x-axis and y-axis tick labels
        set(ax, 'XTick', x_indices, 'XTickLabel', x_indices);
        set(ax, 'YTickLabel', num2cell(get(ax, 'YTick')), 'YTickLabelMode', 'manual');
        set([ax], {'FontSize'}, {tickLabelFontSize}); % Specific font size for tick labels

        % Adding title and labels
        titleStr = sprintf("%s, %s", earName, cortexName);
        title(titleStr, 'FontSize', subTitleFontsize);
        xlabel('Time (sec)');
        if cortex == "LCortex"
            hLabel = ylabel('Activity (% signal change)');

            % Get current position of the ylabel
            currentPosition = get(hLabel, 'Position');

            % Increase the y-value to shift it upwards
            newPosition = currentPosition + [-0.5 0 0]; % Adjust the 0.1 as needed

            % Set the new position of the ylabel
            set(hLabel, 'Position', newPosition);
        end
        ylim([-0.3 0.6]);
        if cortex == "RCortex"
            legend({'LH', 'RH', 'Auditory only'}, 'Location', 'best');
        end
        hold off;
    end
    % Saving the figures to jpg files
    titleStr = sprintf("Average Activity Over Time Joint %s", ear);
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
