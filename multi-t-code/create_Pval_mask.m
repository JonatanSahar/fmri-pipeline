function create_Pval_mask(mapDir,tresh)
addpath(genpath('../multit'));

maps=dir(fullfile(mapDir,['*' '_Pmap_pc_TR1_peakTR' num2str(TRafterEV) '_mcRej_nov20.nii']));
maps={maps(:).name};
for m=1:length(maps)
    %load P map
    map_file=fullfile(mapDir,maps{m});
    nii_P_data = niftiread(map_file);
    niiInfo=niftiinfo(fullfile(map_file));
    
    %create a binari mat with voxels' value<=tresh equal to 1 while the
    %rest are zeros
    cnt=0;
    mask=zeros(size(nii_P_data));
    for vx=1:size(nii_P_data,1)
        for vy=1:size(nii_P_data,2)
            for vz=1:size(nii_P_data,3)
                if nii_P_data(vx,vy,vz)<=tresh && nii_P_data(vx,vy,vz)>0
                    mask(vx,vy,vz)=1;
                    cnt=cnt+1;
                end
            end
        end
    end
    
    %% move p mask back to 3d:
    mapName=maps{m};
    mapName=mapName(1:end-4);
    
    trsh=num2str(tresh);
    trsh=trsh(3:end);
    maskName=[mapName '_Pmask_trsh' trsh];
    outfile=fullfile(mapDir,maskName);
    if ~exist([outfile '.nii'])
        niftiwrite(single(mask),outfile,niiInfo)
    end
    
end

end
% mapDir=fullfile('pilot_data','MultiGroupRes_pc_TR4_notremRT_med_16.4.20')
% tresh=0.01
