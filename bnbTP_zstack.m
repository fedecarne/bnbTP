% Connect to BnB
channel  =  sshfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password);

[~,folders] = sshfrommatlabissue(channel,['cd ' code_folder ' && cd data && ls']);

[selection,ok] = listdlg('ListString',folders,'SelectionMode','single','Name','Select z stack folder');

if ~ok
    return
end

zstack_folder = ['data/' folders{selection,1}];

[~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && if test -d data_out; then echo "1"; fi']);

if ~isempty(msg{1,1})
    % There is already a folder in BnB
    choice = questdlg('There are registered files in BnB. Would you like to clean and run?', ...
        'Yes', 'No');
    % Handle response
    switch choice
        case 'Yes'
            [~, ~]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && rm -r data_out']);
        case 'No' | 'Cancel'
            disp('Registration cancelled.')
            return
    end
end

prompt = {'Image prefix:','Image sufix:'};
dlg_title = 'Enter image files';
num_lines = 1;
def = {'z2_830farrred_','.tif'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

zstack_im_pre = answer{1,1};
zstack_im_post = answer{2,1};

% Get number of images
[~,msg] = sshfrommatlabissue(channel,['cd ' code_folder ' && cd ' zstack_folder ' && ls ' zstack_im_pre '*' zstack_im_post]);
zstack_N = size(msg,1); % Number of images to register

disp([num2str(zstack_N) ' files in data folder...']);

% Registration method
reg_method = 'run_recursive_register';

if zstack_N<50
    shortJob = '-l shortjob';
else
    shortJob = '';
end

chan = 1;

% Fill template to run jobs
fTemplate = fopen('bnb_register_template.sh');
fOutput = fopen('bnb_register.sh', 'w+');

tline = fgetl(fTemplate);
while ischar(tline)
    tline = strrep( tline, '<<<reg_method>>>', reg_method);
    tline = strrep( tline, '<<<N>>>', ['"' num2str(zstack_N) '"']);
    tline = strrep( tline, '<<<datain>>>', ['"' zstack_folder '"']);
    tline = strrep( tline, '<<<dataout>>>', ['"' dataout_folder '/out$SGE_TASK_ID"']);
    tline = strrep( tline, '<<<memory>>>', ['"' memory '"']);
    tline = strrep( tline, '<<<ref_image>>>', '');
    tline = strrep( tline, '<<<chan>>>', ['"' num2str(chan) '"']);
    tline = strrep( tline, '<<<im_pre>>>', ['"' zstack_im_pre '"']);
    tline = strrep( tline, '<<<im_post>>>', ['"' zstack_im_post '"']);
    fprintf( fOutput, [tline '\n'] );
    tline = fgetl(fTemplate);
end
fclose(fTemplate);
fclose(fOutput);

disp( 'Uploading registration code to blacknblue...');

% Send .sh to submit
sftpfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password,'bnb_register.sh',[code_folder '/bnb_register.sh']);

% Submit job array

[~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && mkdir ' dataout_folder ' && qsub ' shortJob ' bnb_register.sh']);
disp(msg)

sshfrommatlabissue(channel,['cd ' code_folder '&& rm -f bnb_register.sh*']);

% Close connection to BnB
sshfrommatlabclose(channel);
    
reg_r = consolidate(sshdata, code_folder, dataout_folder, results_folder, 'reg_results',1);
