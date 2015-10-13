% try 
%     sshfrommatlabinstall(1)
% catch ME
%     disp(['Could not find sshfrommatlab package. Make sure it is in your path.'])
%     return
% end

sshdata.userName = 'fcarneva';
sshdata.hostName = 'bnbdev1.cshl.edu';
sshdata.password = 'Malasagna1';

code_folder = 'bnbTP'; %working folder

results_folder = uigetdir('','Enter folder to save results.');

%channel  =  sshfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password);

disp('Done initialization.')