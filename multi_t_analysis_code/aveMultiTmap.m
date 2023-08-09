function aveMultiTmap(data_dir,subjects,conditions,shuff)
tool='fslmaths ';
for cond=1:length(conditions)
    count=0;
    for s=1:length(subjects)
        count=count+1;
        tmap=fullfile(data_dir,subjects{s},'derive/Tmaps','pc_TR1_peakTR5_mcRej_nov20',...
            [char(conditions(cond)) '_' subjects{s} 'TR1_peakTR5_mcRej_nov20_400shuffels.nii']);
        if count==1
            cmd=[tool, tmap];
        else
            cmd=[cmd,' -add ',tmap];
        end
    end
    
    outDir=fullfile(data_dir,'MultiGroupRes','pc_TR5_fixedMED');
    if ~exist(outDir)
    mkdir(outDir);
    end
    
    outSum=fullfile(outDir,['sumTmap_' char(conditions(cond)) '_temp.nii.gz']);
    cmd=[cmd,' ',outSum];
    unix(cmd)
    outMean=fullfile(outDir,['meanTmap_pc_TR5_fixed_' char(conditions(cond)) '_' shuff 'shuffels.nii.gz']);
    group_cmd=[tool, [outSum ' -div ' num2str(count) ' '  outMean]];
    unix(group_cmd)
    delete(outSum)
end
end