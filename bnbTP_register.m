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

%%% Registratio method
[choice,ok] = listdlg('PromptString','Select registration method:','SelectionMode','single','ListString',{'ReferenceImage','Recursive'});

if ~ok, disp('Registration cancelled.');return, end;
   
switch choice
    case 1
        reg_method = 'run_si_register';
                
        prompt = {'Reference image file:'};
        dlg_title = 'Enter image files';
        num_lines = 1;
        def = {'reg_med.tif'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        ref_image = answer{1,1};

    case 2
        reg_method = 'run_recursive_register';
end

this_folder = pwd;

if N<50
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
    tline = strrep( tline, '<<<N>>>', ['"' num2str(N) '"']);
    tline = strrep( tline, '<<<datain>>>', ['"' datain_folder '"']);
    tline = strrep( tline, '<<<dataout>>>', ['"' dataout_folder '/out$SGE_TASK_ID"']);
    tline = strrep( tline, '<<<memory>>>', ['"' memory '"']);
    
    if strcmp(reg_method,'run_si_register')
        tline = strrep( tline, '<<<ref_image>>>', ['"' datain_folder '/' ref_image '"']);
    end
    
    if strcmp(reg_method,'run_recursive_register')
        tline = strrep( tline, '<<<ref_image>>>', '');
    end
    
    tline = strrep( tline, '<<<chan>>>', ['"' num2str(chan) '"']);
    tline = strrep( tline, '<<<im_pre>>>', ['"' im_pre '"']);
    tline = strrep( tline, '<<<im_post>>>', ['"' im_post '"']);
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
    
results = consolidate(sshdata, code_folder, dataout_folder, results_folder, 'reg_results',1);



save([results_folder '/reg_results'],'results');
