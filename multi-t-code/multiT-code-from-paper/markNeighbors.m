%% load data
dataLoc=fullfile('..','LVFinLocCorbin.nii.gz');
niidata=load_untouch_nii(dataLoc);
data=niidata.img;
%%load mask to get original lications
maskfn = fullfile('..','data','raw_data',['commonAllSubsLVF.nii.gz']);
niifile = load_untouch_nii(maskfn);
niidata =  niifile.img;
[lidx, locations ] = getLocationsFromMaskNii(niidata);

idx = knnsearch(locations, locations, 'K', 27); % define neighbours

%% find significant voxels locations
dataflat=data(lidx);
sigVoxels=dataflat==1;
disp(['you have ' num2str(sum(sigVoxels)) ' signigicant voxels in your data']);
sigLocs=find(sigVoxels==1);

%% mark neighbors
zeroimag = zeros([91,109,91]);
for i=1:length(sigLocs)
    locs=idx(idx(:,1)==sigLocs(i),:);
    zeroimag(lidx(locs))=0.5;
end
zeroimag(lidx(sigLocs))=1;

%% save image
niifile.img = zeroimag;
save_untouch_nii(niifile,['LVFneighbors.nii.gz']);