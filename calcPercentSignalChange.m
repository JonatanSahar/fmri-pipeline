function percentChangeData = calcPercentSignalChange(functionalData)
    if any(any(any(any(functionalData==0))))
        zeroLocs=find(functionalData==0);
        disp(['this scan has ', num2str(length(zeroLocs)),' zero voxels']);
        functionalData(zeroLocs)=0.00001;
    end
    functionalData = double(functionalData);
    meanFuncData = mean(functionalData,4);
    percentChangeData = functionalData./meanFuncData*100 - 100;
end
