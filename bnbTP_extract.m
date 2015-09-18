%% (3) Extract fluorescence from ROI's

[FileName,PathName,FilterIndex] = uigetfile('*.mat','Select ROIs file',[results_folder '/rois.mat']);

% send rois
sftpfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password,[PathName FileName], [code_folder '/rois.mat'])

% Fill template for extraction
fTemplate = fopen('bnb_extractROI_template.sh');
fOutput = fopen('bnb_extractROI.sh', 'w+');

tline = fgetl(fTemplate);
while ischar(tline)
    tline = strrep( tline, '<<<N>>>', num2str(N));
    tline = strrep( tline, '<<<datain>>>', datain_folder);
    tline = strrep( tline, '<<<dataout>>>', dataout_folder);
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

[~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && ls']);

if  ~(sum(strcmp(msg,'roi'))==0)
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
[~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && mkdir roi && qsub bnb_extractROI.sh']);
disp(msg)

%something went wrong here
sshfrommatlabissue(channel,['cd ' code_folder '&& rm -f bnb_extractROI.sh*']);

% Close connection to BnB
sshfrommatlabclose(channel);

traces = consolidate(sshdata, code_folder, 'roi', results_folder, 'traces',1);