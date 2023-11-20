function timeCourseMotor()
    computeTimeCourseMotor()
    computeMeanTimeCourseMotor()
    for cortex = ["LCortex", "RCortex"]
        plotTimeCourseMotor(cortex)
    end
end
