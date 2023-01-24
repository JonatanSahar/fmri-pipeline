function params = analyse_second_lvl(params)
params.numPerm=5000;
% maskImg.data=niftiread(fullfile(params.mask.dir,params.mask.name));
% maskImg.info=niftiinfo(fullfile(params.mask.dir,params.mask.name));
% meanImg=zeros(size(maskImg.data));
conditions = {'AO',1;'MO',1;'AC',2;'MC',2};
for c=1:length(conditions)
    resultsFiles=dir(fullfile(params.outDir,'jan2023',[conditions{c},'*.txt']));
    valid = 1;
    for i=1:length([resultsFiles.isdir])
        %% get mask image for each condition
        subject_num = regexp(resultsFiles(i).name,'\d*','Match');
        load(fullfile(params.outDir,[subject_num{1},'_',params.conditions{conditions{c,2}}{floor(conditions{c,2}/2 + 1)},params.saveName]),'maskImg','linearIndex');
        %% concatinate data
        if ~strcmp(resultsFiles(i).name, 'experiment_description.txt')
            sub=load(fullfile(resultsFiles(i).folder,resultsFiles(i).name));
%             if valid==1
%                 ansMatOut=zeros([size(sub),length([resultsFiles.isdir])]);
%             end
            zeroImg = zeros(size(maskImg.data));
            zeroImg(find(maskImg.data))=sub(:,1);
            
%             ansMatOut(:,:,valid)=sub;
            niftiwrite(single(zeroImg),resultsFiles(i).name,maskImg.info);
            valid= valid + 1;
            disp(['finished ',resultsFiles(i).name])
        end
    end
end
    % meanImg=meanImg./length([resultsFiles.isdir]);
    %
    % niftiwrite(single(meanImg),'realDataAveraged_LVF',maskFile.info);
    
    [avgAnsMat,stlzerPermsAnsMat] = createStelzerPermutations(ansMatOut,params.numPerm,'mean');
    clear ansMatOut
    for i = 1:size(avgAnsMat,1)
        Pval(i) = mean(double(avgAnsMat(i,1)<avgAnsMat(i,2:end)));
        if Pval(i) == 0
            Pval(i) = 1/params.numPerm;
        end
    end
    pImage=zeros(size(maskImg.data));
    pImage(find(maskImg.data))=Pval;
    niftiwrite(single(pImage),'acc_r_RVF',maskFile.info);
end