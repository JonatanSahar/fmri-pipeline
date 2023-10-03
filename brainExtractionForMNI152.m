function brainExtractionForMNI152()
        anatomy_dir = "/home/user/fsl/data/standard/";
        anatomy_file = "MNI152_T1_2mm.nii.gz"
        anatomy_file_prefix = "MNI152_T1_2mm"
            bet_cell = cell(2,2);
            bet_cell{1,1} = 'anatomy';
            bet_cell{2,1} = 'magnitude';
            bet_cell{1,2} = 'please choose the best extracted brain';
            bet_cell{2,2} = 'please choose the best extracted brain. better to lose brain than to include non-brain tissue here!';
            
            bet_params = {'f_0.4_g_-0.4', 'f_0.3_g_0','f_0.3_g_-0.3','v4'};
            
            cmd = sprintf('bet %s %s  -f 0.4 -g -0.4 -R', ...
                          fullfile(anatomy_dir, anatomy_file), ...
                          fullfile(anatomy_dir, bet_params{1}));
            system(cmd);

            cmd = sprintf( 'bet %s %s  -f 0.3 -g -0 -R', ...
                          fullfile(anatomy_dir, anatomy_file), ...
                           fullfile(anatomy_dir, bet_params{2}));
            system(cmd);

            cmd = sprintf('bet %s %s  -f 0.3 -g -0.3 -R',  ...
                          fullfile(anatomy_dir, anatomy_file), ...
                          fullfile(anatomy_dir, bet_params{3}));
            system(cmd);
            
            cmd = sprintf('fsleyes %s %s  -cm blue -a 80  %s  -cm red -a 80  %s  -cm green -a 80 & ', ...
                          fullfile(anatomy_dir, anatomy_file), ...
                          fullfile(anatomy_dir, bet_params{1}), ...
                          fullfile(anatomy_dir, bet_params{2}), ...
                          fullfile(anatomy_dir, bet_params{3}));

            system(cmd);
            fprintf("%s", cmd)
            input('\n(^^^ press enter after pasting the command above ^^^)\n');
            %ask for user's choice
            choice = menu(  bet_cell{1,2},...
                'the blue one', 'the red one', 'the green one', ...
                'they are all bad. let me choose the parameters myself');
            % unix(sprintf('ps -fade | grep %s | awk ''{print  $2}'' | xargs kill',bet_params{1}));
            
            if choice == 4
                good_or_not = 2;
                while good_or_not == 2
                    answers = inputdlg({'threshold', 'gradient'}, 'choose parameters',1,{'0.5', '0'});
%                     unix(sprintf('ps -fade | grep %s | awk ''{print  $2}'' | xargs kill',bet_params{4}));
                    cmd = ['bet '  fullfile(anatomy_dir, [num2str(s),bet_cell{1,1} '.nii.gz']) ' '...
                       fullfile(anatomy_dir, bet_params{4}) ' -f ' num2str(answers{1}) ' -g ' num2str(answers{2}) ,' -R']
                    system( cmd);
                    cmd =['fsleyes ' ...
                        fullfile(anatomy_dir, [num2str(s),bet_cell{1,1} '.nii.gz']) ' '...
                        fullfile(anatomy_dir, bet_params{4}) ' -cm green -a 80 &']
                    system(cmd);
                    good_or_not = menu('good?', 'yes', 'no');
                    
                end
            end
            
            %change chosen file's name
            movefile(fullfile(anatomy_dir, [bet_params{choice} '.nii.gz']), ...
                fullfile(anatomy_dir, anatomy_file_prefix,'_brain_jonathan.nii.gz'));
            %delete remaining files.
            % files=dir(fullfile(anatomy_dir));
            % files={files.name};
            % files(ismember(files,{'.','..',[num2str(s),'anatomy.nii.gz'],[num2str(s),'anatomy_brain.nii.gz']}))=[];
            % for f=1:length(files)
            %     system(['rm ',fullfile(anatomy_dir,files{f})]);
            % end
end
