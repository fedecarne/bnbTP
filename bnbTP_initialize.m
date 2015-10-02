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

channel  =  sshfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password);

[~,folders] = sshfrommatlabissue(channel,['cd ' code_folder ' && cd data && ls']);

[selection,ok] = listdlg('ListString',folders,'SelectionMode','single','Name','Select data folder');

if ~ok
    return
end

datain_folder = ['data/' folders{selection,1}];

dataout_folder = 'data_out'; % folder to put temporary results
memory = '16'; % required memory for each job (Gb)

prompt = {'Image prefix:','Image sufix:'};
dlg_title = 'Enter image files';
num_lines = 1;
def = {'t1_','.tif'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

im_pre = answer{1,1};
im_post = answer{2,1};

% Get number of images
[~,msg] = sshfrommatlabissue(channel,['cd ' code_folder ' && cd ' datain_folder ' && ls ' im_pre '*' im_post]);
N = size(msg,1); % Number of images to register

disp([num2str(N) ' images in data folder...']);

disp('Done initialization.')