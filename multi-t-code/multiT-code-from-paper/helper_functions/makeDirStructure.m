function makeDirStructure()
%% this functions makes dir structure under "project dir" that code base relies on. 
mkdir(fullfile('..','..','data'));
mkdir(fullfile('..','..','figures'));
mkdir(fullfile('..','..','raw'));
mkdir(fullfile('..','..','results'));
end