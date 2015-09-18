% Connect to BnB
channel  =  sshfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password);

[~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && if test -d data_out; then echo "1"; fi']);

if ~isempty(msg{1,1})
    % There is already a folder in BnB
    choice = questdlg('There are registered files in BnB. Would you like to clean and run?', ...
        'Yes', 'No');
    % Handle response
    switch choice
        case 'Yes'
            [~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && rm -r data_out']);
        case 'No' | 'Cancel'
            disp('Registration cancelled.')
            return
    end
end

this_folder = pwd;

if N<50
    shortJob = '-l shortjob';
else
    shortJob = '';
end

% Fill template to run jobs
fTemplate = fopen('bnb_pbs_template.sh');
fOutput = fopen('bnb_pbs.sh', 'w+');

tline = fgetl(fTemplate);
while ischar(tline)
    tline = strrep( tline, '<<<N>>>', num2str(N));
    tline = strrep( tline, '<<<datain>>>', datain_folder);
    tline = strrep( tline, '<<<dataout>>>', dataout_folder);
    tline = strrep( tline, '<<<memory>>>', memory);
    tline = strrep( tline, '<<<ref_image>>>', ref_image);
    tline = strrep( tline, '<<<im_pre>>>', im_pre);
    tline = strrep( tline, '<<<im_post>>>', im_post);
    fprintf( fOutput, [tline '\n'] );
    tline = fgetl(fTemplate);
end
fclose(fTemplate);
fclose(fOutput);

disp( 'Uploading registration code to blacknblue...');

% Send .sh to submit
sftpfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password,'bnb_pbs.sh',[code_folder '/bnb_pbs.sh']);

% Submit job array

[~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && mkdir ' dataout_folder ' && qsub ' shortJob ' bnb_pbs.sh']);
disp(msg)

sshfrommatlabissue(channel,['cd ' code_folder '&& rm -f bnb_pbs.sh*']);

% Close connection to BnB
sshfrommatlabclose(channel);
    
reg_r = consolidate(sshdata, code_folder, dataout_folder, results_folder, 'reg_results',1);
