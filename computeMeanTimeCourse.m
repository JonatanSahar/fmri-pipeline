function computeMeanTimeCourse()
    params = setAnalysisParams();
    if ~exist(params.timeCourseOutDir)
        mkdir(params.timeCourseOutDir)
    end
    rng(params.seed);

% Get file names
filePattern = fullfile(params.timeCourseOutDir, '*_time_course.mat');
theFiles = dir(filePattern);

% Initialize 3D arrays
all_LE_LCortex_LH = [];
all_LE_LCortex_RH = [];
all_LE_RCortex_LH = [];
all_LE_RCortex_RH = [];
all_RE_LCortex_LH = [];
all_RE_LCortex_RH = [];
all_RE_RCortex_LH = [];
all_RE_RCortex_RH = [];

% Iterate over files and store data
for k = 1:length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);

    % Load the data from .m files
    load(fullFileName);

    % Store data in 3D arrays
    all_LE_LCortex_LH(:,:,k) = LE_LCortex_LH;
    all_LE_LCortex_RH(:,:,k) = LE_LCortex_RH;
    all_LE_RCortex_LH(:,:,k) = LE_RCortex_LH;
    all_LE_RCortex_RH(:,:,k) = LE_RCortex_RH;
    all_RE_LCortex_LH(:,:,k) = RE_LCortex_LH;
    all_RE_LCortex_RH(:,:,k) = RE_LCortex_RH;
    all_RE_RCortex_LH(:,:,k) = RE_RCortex_LH;
    all_RE_RCortex_RH(:,:,k) = RE_RCortex_RH;
end

% Compute mean across the third dimension (subjects)
average_LE_LCortex_LH = mean(all_LE_LCortex_LH, 3);
average_LE_LCortex_RH = mean(all_LE_LCortex_RH, 3);
average_LE_RCortex_LH = mean(all_LE_RCortex_LH, 3);
average_LE_RCortex_RH = mean(all_LE_RCortex_RH, 3);
average_RE_LCortex_LH = mean(all_RE_LCortex_LH, 3);
average_RE_LCortex_RH = mean(all_RE_LCortex_RH, 3);
average_RE_RCortex_LH = mean(all_RE_RCortex_LH, 3);
average_RE_RCortex_RH = mean(all_RE_RCortex_RH, 3);

% Save averaged data to a new .mat file
save(fullfile(params.timeCourseOutDir,  'time_course_mean.mat'), 'average_LE_LCortex_LH', 'average_LE_LCortex_RH', 'average_LE_RCortex_LH', 'average_LE_RCortex_RH', 'average_RE_LCortex_LH', 'average_RE_LCortex_RH', 'average_RE_RCortex_LH', 'average_RE_RCortex_RH', '-v7.3');
end
