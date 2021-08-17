%% main file
low_frequency=8;
high_frequency=49;
split=5;
csp_pairs=3; 
features=pd_eeg_O(split,low_frequency,high_frequency,csp_pairs);
