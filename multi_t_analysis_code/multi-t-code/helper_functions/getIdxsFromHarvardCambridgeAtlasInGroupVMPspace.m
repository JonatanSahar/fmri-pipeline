function getIdxsFromHarvardCambridgeAtlasInGroupVMPspace()
%% This function creates idxs in group space from harvard cambridge atlas. 
idxs = {}; 
idxlabels = {}; 
load groupMaskFromRFXvocalDataSet.mat
locations = getLocations(mask);
%% load MNI anatomical labels cortical
vmplabels = 'HarvardCambrdgeCoritcalAtlas'; % just GM has 1
vmpatlas = BVQXfile(fullfile(pwd,[vmplabels  '.vmp']));
[idxs, idxslabels, sizes] = getIdxs(vmpatlas,locations); 
%% load MNI anatomical labels sub-cortical
vmplabels = 'HarvardCambrdgeCoritcalAtlas_sub_cortical'; % just GM has 1
vmpatlassuybcor = BVQXfile(fullfile(pwd,[vmplabels  '.vmp']));
[idxs_sub, idxslabels_sub, sizes_sub] = getIdxs(vmpatlassuybcor,locations); 
%% join both maps 
subcorticalmapskeep = [3:11,14:21]; 
idxsout = [idxs; idxs_sub(subcorticalmapskeep)]; % exclude maps for white matter, the whole cerebrum... 
idxslabelsout = [idxslabels; idxslabels_sub(subcorticalmapskeep)];
sizesout = [sizes'; sizes_sub(subcorticalmapskeep)'];

% print voxel sizes and areas 
[sortsizes,ic] = sort(sizesout);
for i = 1:length(ic); 
    fprintf('size = %d \t region = %s\n',sizesout(ic(i)),idxslabelsout{ic(i),1});
end

save('idxs_from_havard_cambridge_atlas.mat',...
    'idxsout','idxslabelsout','sizesout'); 
end

function [idxs, idxslabels, sizes] = getIdxs(vmp,locations)
idxs = {} ; idxslabels = {};
for i = 1:vmp.NrOfMaps
    vmpdata = vmp.Map(i).VMPData;
    idxslabels{i,1} = vmp.Map(i).Name;
    idxsraw = find(vmpdata==1); 
    [loc(:,1),loc(:,2),loc(:,3)] = ind2sub(size(vmpdata),idxsraw);
    idxs{i,1} = find(ismember(locations,loc,'rows')==1);
    sizes(i) = length(idxs{i,1});
    loc = [] ; idxsraw = []; 
end
end