function [all_data,all_labels]=create_multi_condLists(subj_data_names,subj_Data,params)

% listsDir=fullfile(peDir,'../','lists');

%cheack equal amount of trials

R_Y_F=find(contains(subj_data_names,'R_Y_F'));
R_Y_V=find(contains(subj_data_names,'R_Y_V'));
R_N_F=find(contains(subj_data_names,'R_N_F'));
R_N_V=find(contains(subj_data_names,'R_N_V'));
L_Y_F=find(contains(subj_data_names,'L_Y_F'));
L_Y_V=find(contains(subj_data_names,'L_Y_V'));
L_N_F=find(contains(subj_data_names,'L_N_F'));
L_N_V=find(contains(subj_data_names,'L_N_V'));

minNinCond=min([length(R_Y_F),length(R_Y_V),length(R_N_F),length(R_N_V),...
    length(L_Y_F),length(L_Y_V),length(L_N_F),length(L_N_V)]);

R_Y_F=R_Y_F(1:minNinCond);
R_Y_V=R_Y_V(1:minNinCond);
R_N_F=R_N_F(1:minNinCond);
R_N_V=R_N_V(1:minNinCond);
L_Y_F=L_Y_F(1:minNinCond);
L_Y_V=L_Y_V(1:minNinCond);
L_N_F=L_N_F(1:minNinCond);
L_N_V=L_N_V(1:minNinCond);

inds=sort([R_Y_F;R_Y_V;R_N_F;R_N_V;L_Y_F;L_Y_V;L_N_F;L_N_V]);

subj_data_names=subj_data_names(inds);
subj_Data=subj_Data(:,:,:,inds);

all_data.hand=subj_Data;
all_data.percept=subj_Data;
all_data.ans=subj_Data;
all_data.speeds=subj_Data;
all_data.mapping=subj_Data;
all_labels.hand=zeros(1,length(subj_data_names));
all_labels.hand(contains(subj_data_names,'R'))=1;
all_labels.percept=zeros(1,length(subj_data_names));
all_labels.percept(contains(subj_data_names,'F'))=1;
all_labels.ans=zeros(1,length(subj_data_names));
all_labels.ans(contains(subj_data_names,'Y'))=1;
all_labels.speeds=zeros(1,length(subj_data_names));
all_labels.speeds(contains(subj_data_names,'fast'))=1;
all_labels.mapping=zeros(1,length(subj_data_names));
all_labels.mapping(contains(subj_data_names,'map1'))=1;

R_inds=find(contains(subj_data_names,'R'));
L_inds=find(contains(subj_data_names,'L'));
R_F_inds=sort([R_Y_F;R_N_F]);
R_V_inds=sort([R_Y_V;R_N_V]);
L_F_inds=sort([L_Y_F;L_N_F]);
L_V_inds=sort([L_Y_V;L_N_V]);
all_data.R_yn=subj_Data(:,:,:,R_inds);
all_data.L_yn=subj_Data(:,:,:,L_inds);
all_data.R_fv=subj_Data(:,:,:,R_inds);
all_data.L_fv=subj_Data(:,:,:,L_inds);
all_data.R_rt=subj_Data(:,:,:,R_inds);
all_data.L_rt=subj_Data(:,:,:,L_inds);
all_data.R_F=subj_Data(:,:,:,R_F_inds);
all_data.R_V=subj_Data(:,:,:,R_V_inds);
all_data.L_F=subj_Data(:,:,:,L_F_inds);
all_data.L_V=subj_Data(:,:,:,L_V_inds);



R_names=subj_data_names(R_inds);
L_names=subj_data_names(L_inds);
R_F_names=subj_data_names(R_F_inds);
R_V_names=subj_data_names(R_V_inds);
L_F_names=subj_data_names(L_F_inds);
L_V_names=subj_data_names(L_V_inds);


all_labels.R_yn=zeros(1,length(R_names));
all_labels.R_yn(contains(R_names,'Y'))=1;

all_labels.R_fv=zeros(1,length(R_names));
all_labels.R_fv(contains(R_names,'F'))=1;

all_labels.R_rt=zeros(1,length(R_names));
all_labels.R_rt(contains(R_names,'fast'))=1;

all_labels.L_yn=zeros(1,length(L_names));
all_labels.L_yn(contains(L_names,'Y'))=1;

all_labels.L_fv=zeros(1,length(L_names));
all_labels.L_fv(contains(L_names,'F'))=1;

all_labels.L_rt=zeros(1,length(L_names));
all_labels.L_rt(contains(L_names,'fast'))=1;

all_labels.R_F=zeros(1,length(R_F_names));
all_labels.R_F(contains(R_F_names,'Y'))=1;

all_labels.R_V=zeros(1,length(R_V_names));
all_labels.R_V(contains(R_V_names,'Y'))=1;

all_labels.L_F=zeros(1,length(L_F_names));
all_labels.L_F(contains(L_F_names,'Y'))=1;

all_labels.L_V=zeros(1,length(L_V_names));
all_labels.L_V(contains(L_V_names,'Y'))=1;



save(fullfile(params.pc_multi_dataDir,'all_labels.mat'),'all_labels');
save(fullfile(params.pc_multi_dataDir,'all_data.mat'),'all_data','-v7.3');


end

