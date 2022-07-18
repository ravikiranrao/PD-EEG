function features=pd_eeg(split,fl,fh,pairs)
%% PD data analysis

%dirnc=uigetdir(matlabroot,'Input Emotion location for Normal');
%dirpd=uigetdir(matlabroot,'Input Emotion location for PD');
%disp(dirnc)
split = 5;
csp_pairs = 3;
low_frequency=8;
high_frequency=49;
dirnc = "PD_NC_DATABASE_FINAL/NC/E6";
dirpd = "PD_NC_DATABASE_FINAL/PD/E6";
data_nc = spreadsheetDatastore(dirnc,'FileExtensions',{'.xls','.xlsx'},'IncludeSubfolders', true);
data_pd = spreadsheetDatastore(dirpd,'FileExtensions',{'.xls','.xlsx'},'IncludeSubfolders', true);
%disp(data_nc)
%disp(data_pd)
[b,a]= butter(8,[1/64,49/64],'bandpass');
%% Bandpass filter IIR
bpFilt = designfilt('bandpassiir','FilterOrder',8, ...
         'HalfPowerFrequency1',fl,'HalfPowerFrequency2',fh, ...
         'SampleRate',128);
%fvtool(bpFilt)

for class=1:1:2
 if class==1
    data_in=data_nc;
 else
    data_in=data_pd;
 end

%% Filtering
fls=120;
bpdata_nc_e1 = cell(fls,1);
%
%%
data_in.ReadSize = 'file';
for i=1:1:fls
dataIn = read(data_in); % reads first file
dataIn1=dataIn{:,:};  
dataIn1(dataIn1>=85)=0;
dataIn1(dataIn1<=-85)=0;
dataOut=zeros(size(dataIn1));%what it mean 

for j=1:1:14
    try 
dataIn1(:,j) = filtfilt(b,a,dataIn1(:,j));         
dataOut(:,j) = filter(bpFilt,dataIn1(:,j));
    catch ME
            fprintf('Different size, File: %d\n', i);
continue;
    end
bpdata_nc_e1{i,1}=dataOut;
end
end
%% BP data store for a class
bp_fil=bpdata_nc_e1(~cellfun('isempty',bpdata_nc_e1));

%% data splits
fs=128;
data_spl1={};
for i=1:1:fls
sz1=size(bp_fil{i,1},1);
part=floor(sz1/(split*128));
xx=bp_fil{i,1};
start=1;
sp=1;
for j=1:1:part
 if (sp<=part)
 data_spl1{i,j}=xx((start:(fs*sp*split)),:);
 start=(fs*sp*split)+1;
 end
 sp=sp+1;
 end
end
%% Data partition creation
split_data=data_spl1(~cellfun('isempty',data_spl1));
datasplit_bp={};
datasplit_bp=split_data;
clear split_data
% nc={};
% pd={};
if class==1
    nc=datasplit_bp;
else
    pd=datasplit_bp;
end

end
nc_files=size(nc,1);
pd_files=size(pd,1);

%% 

% Compute the covariance matrix of each class
S1=cell(nc_files,1);S2=cell(pd_files,1);
for i=1:1:nc_files
    X1=nc{i,1};
    S1{i,1} = cov(X1);   % S1~[C x C]
  
end
for i=1:1:pd_files
    X2=pd{i,1};
    S2{i,1} = cov(X2);   % S2~[C x C]
end
%% Mean cov values of NC and PD
cov_nc=zeros(14,14);
cov_pd=zeros(14,14);

for i=1:1:nc_files
    cov_nc=cov_nc+S1{i,1};
end

for i=1:1:pd_files
    cov_pd=cov_pd+S2{i,1};
end

COV_NC=cov_nc/nc_files;
COV_PD=cov_pd/pd_files;
    
%% Spatial Filters coefficients
[B,D] = eig(COV_NC, COV_NC + COV_PD);
[D,Idxs] = sort(diag(D),'descend'); 
B = B(:,Idxs);
%Equation (12) in the CONFERENCE paper
%Equation (8) in the JOURNAL paper
W=B; 
%Normalize the projrection matrix
%for i=1:length(Idxs), W(i,:)=W(i,:)./norm(W(i,:)); end
%Sort columns, take first and last columns first, etc
W0=W;
W=zeros(size(W));
i=0;
numCh=14;
for d=1:numCh
    if (mod(d,2)==0)
        W(:,d)=W0(:,numCh-i);
        i=i+1;
    else
       W(:,d)=W0(:,1+i);
    end
end


%% 
selCh=2*pairs;
prjW=W(:,1:selCh);%Select columns 

%[W,L] = eig(COV_NC, COV_NC + COV_PD);   % Mixing matrix W (spatial filters are columns)

%% CSP filtered signal
nc_csp=cell(nc_files,1);
pd_csp=cell(pd_files,1);
for i=1:1:nc_files
nc_csp{i,1} = prjW'*nc{i,1}';
end
for i=1:1:pd_files
pd_csp{i,1} = prjW'*pd{i,1}';
end

%% CSP Features
f_nc=cell(nc_files,1);
f_pd=cell(pd_files,1);

for i=1:1:nc_files
    f_nc{i,1}=(log(var(nc_csp{i,1},0,2)))';
end
for i=1:1:pd_files
    f_pd{i,1}=(log(var(pd_csp{i,1},0,2)))';
end

%% PD ML -LDA, SVM
%load('Train_e1.mat');
% Cross varidation (train: 70%, test: 30%)
% Cross varidation (train: 70%, test: 30%)
%{
f_nc = cell(nc_files, 1);
f_pd = cell(pd_files, 1);

for z = 1:1:nc_files
    a = nc{z}';
    f_nc{z,1}=(a(:)');
end
for z = 1:1:pd_files
    a = pd{z}';
    f_pd{z,1}=(a(:)');
end

%Create a tensor
features_nc = [];
for i=1:nc_files
    file = cell2mat(nc(i));
    features_nc(i,:,:) = cat(3,file);
end

features_pd = [];
for i=1:pd_files
    file = cell2mat(pd(i));
    features_pd(i,:,:) = cat(3,file);
end

features = [features_nc;features_pd];
%}
%Create the labels
ytnc=zeros(nc_files,1);
ytpd=ones(pd_files,1);

XTrain=vertcat(f_nc,f_pd);
features=cell2mat(XTrain);
%yt=[ytnc;ytpd];
E6_feat = features;
E6_pdnc_labels=[ytnc;ytpd];
%features=[xtrain,yt];
%E2_hvlv_labels = -ones(size(features,1),1);
%E2_hala_labels = 0*ones(size(features,1),1);
%E2_multi_labels = ones(size(features,1),1);
%csvwrite('csp_pdnc_sec5_o8_pairs7_low8high49_e3.csv',data_features);
%xlswrite('data_features.xls',data_features);

save('csp_feat_matrix_full_with_full_labels_3.mat', 'E6_feat', 'E6_pdnc_labels', '-append');
end
