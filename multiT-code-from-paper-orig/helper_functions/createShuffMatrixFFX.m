function shufMatrix = createShuffMatrixFFX(data,params) 
%% FFX shuffling 
%  The main idea behind FFX shuffle is that there is no effect 
%  within each subject. Therefore, this shuffle randomizes 
%  labels by just randomizing the rows of the data.
%  output: 
%    this code retursn the shuffeled idxs of the labels  
shufMatrix = zeros(size(data,1),params.numShuffels);
for i = 1:size(shufMatrix,2)
    shufMatrix(:,i) = randperm(size(data,1));
end
end