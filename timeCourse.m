function timeCourse()
    computeTimeCourse();
    computeMeanTimeCourse();
    for ear = ["LE", "RE"]
        for cortex = ["LCortex", "RCortex"]
            plotTimeCourse(ear, cortex)
        end
    end
end
