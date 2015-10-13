% Connect to BnB
channel  =  sshfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password);

%% (1) ask for data folder
[~,folders] = sshfrommatlabissue(channel,['cd ' code_folder ' && cd data && ls']);

[selection,ok] = listdlg('ListString',folders,'SelectionMode','single','Name','Select data folder');

if ~ok
    return
end
datain_folder = ['data/' folders{selection,1}];

dataout_folder = 'data_out'; % folder to put temporary results
memory = '16'; % required memory for each job (Gb)

%% (2) ask for file names
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

%% (3) Extract fluorescence from ROI's

[FileName,PathName] = uigetfile('*.mat','Select ROIs file',[results_folder '/rois.mat']);

% send rois
disp('Uploading rois...')
sftpfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password,[PathName FileName], [code_folder '/rois.mat'])

[~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && ./run_check_mat.sh /opt/hpc/pkg/MATLAB/R2013a "rois.mat"']);
[~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && cat check_mat_result']);

trying=0;
while strcmp(msg,'1')
    
    trying = trying+1;
    if trying>5
        disp('Stopped trying...')
        return
    end
        
    disp('Uploading rois...')
    sftpfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password,[PathName FileName], [code_folder '/rois.mat'])
    
    [~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && ./run_check_rois.sh /opt/hpc/pkg/MATLAB/R2013a "rois.mat"']);
    [~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && cat check_rois_result']);

end

choice = questdlg('Do you want to upload a local reg_result or use the one currently in BnB?','Select reg_results',...
        'Upload a local reg_results', 'Use the one in BnB','Upload a local reg_results');
% Handle response
switch choice
    case 'Upload a local reg_results'
        [FileName,PathName] = uigetfile('*.mat','Select Registration file',[results_folder '/reg_results.mat']);
        disp('Uploading reg_results...')
        % send reg_results
        sftpfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password,[PathName FileName], [code_folder '/reg_results.mat'])
        
        [~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && ./run_check_mat.sh /opt/hpc/pkg/MATLAB/R2013a "reg_results.mat"']);
        [~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && cat check_mat_result']);
        
        if strcmp(msg,'1')
            disp('Uploading failes. Try manually:')
            system(['scp ' PathName FileName ' fcarneva@bnbdev2.cshl.edu:~/bnbTP'])
        end
        
    case 'Use the one in BnB'
        disp('Will use the reg_result currently in BnB.')
end

%if N<50
%    shortJob = '-l shortjob';
%else
    shortJob = '';
%end

fTemplate = fopen('bnb_extractROI_template.sh');
fOutput = fopen('bnb_extractROI.sh', 'w+');

tline = fgetl(fTemplate);
while ischar(tline)
    tline = strrep( tline, '<<<N>>>', num2str(N));
    tline = strrep( tline, '<<<datain>>>', datain_folder);
    tline = strrep( tline, '<<<memory>>>', memory);
    tline = strrep( tline, '<<<im_pre>>>', im_pre);
    tline = strrep( tline, '<<<im_post>>>', im_post);
    fprintf( fOutput, [tline '\n'] );
    tline = fgetl(fTemplate);
end
fclose(fTemplate);
fclose(fOutput);

disp( 'Uploading extractROI to blacknblue');

channel  =  sshfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password);

sshfrommatlabissue(channel,['cd ' code_folder '&& rm -f bnb_extractROI.sh']);

% Send .sh to submit
sftpfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password,'bnb_extractROI.sh',[code_folder '/bnb_extractROI.sh']);

[~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && if test -d roi; then echo "1"; fi']);

if  ~isempty(msg{1,1})
    % There is already a folder roi in BnB
    choice = questdlg('There are extracted rois in BnB. Would you like to clean and run?', ...
        'Yes', 'No');
    % Handle response
    switch choice
        case 'Yes'
            [~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && rm -r roi']);
        case 'No'
            disp('Extraction cancelled.')
            return
    end
end

% Submit job array
[~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && mkdir roi && qsub ' shortJob 'bnb_extractROI.sh']);
disp(msg)

%something went wrong here
sshfrommatlabissue(channel,['cd ' code_folder '&& rm -f bnb_extractROI.sh*']);

% Close connection to BnB
sshfrommatlabclose(channel);

traces = consolidate(sshdata, code_folder, 'roi', results_folder, 'traces',1);