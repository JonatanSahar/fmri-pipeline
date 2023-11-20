function runTimeCourseAnalysis(type)
    switch type
      case 'audiomotor'
        computeTimeCourse();
        computeMeanTimeCourse();
        for ear = ["LE", "RE"]
            for cortex = ["LCortex", "RCortex"]
                plotTimeCourse(ear, cortex)
            end
        end
      case 'audio'
        computeTimeCourseAuditory();
        computeMeanTimeCourseAuditory();
        for cortex = ["LCortex", "RCortex"]
            plotTimeCourseAuditory(cortex)
        end
      case 'motor'
        computeTimeCourseMotor()
        computeMeanTimeCourseMotor()
        for cortex = ["LCortex", "RCortex"]
            plotTimeCourseMotor(cortex)
        end
end
