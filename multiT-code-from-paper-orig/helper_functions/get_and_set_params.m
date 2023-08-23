function params = get_and_set_params()
% This code gets and sets number of shuffels / sl size 
params.numShuffels = 400;
params.regionSize  = 27;

fprintf('Params being used are\n:') ;
fprintf('-- number of shuffles = %d\n',params.numShuffels);
fprintf('-- searchlight size   = %d\n',params.regionSize); 
fprintf('-- To change these params chanage this function under ''helper_functions'':\n');
fprintf('--  get_and_set_params.m\n');

end