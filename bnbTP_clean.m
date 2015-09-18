%% Clean temporary directories?
done = 0;
while ~done
    prompt = 'Should I clean temporal files in BnB? Y/N [Y]: ';
    str = input(prompt,'s');
    switch true
        case strcmp(str,'Y') || strcmp(str,'y') || isempty(str)
            disp('Cleaning...')
            channel  =  sshfrommatlab(sshdata.userName,sshdata.hostName,sshdata.password);
            sshfrommatlabissue(channel,['cd ' code_folder ...
                ' && rm -rf ' dataout_folder ...
                ' && rm -rf roi' ...
                ' && rm -rf data_out' ...
                ' && rm -f rois.mat' ...
                ' && rm -f traces.mat' ...
                ' && rm -f *.sh.e*' ...
                ' && rm -f *.sh.o*' ...
                ' && rm -f reg_results.mat']);
            sshfrommatlabissue(channel,['cd ' code_folder ' && rm -rf ' dataout_folder ' && rm -rf roi']);
            sshfrommatlabclose(channel);
            done = 1;
        case strcmp(str,'N') || strcmp(str,'n')
            disp('Temporal files are stil in BnB.')
            done = 1;
        otherwise
            disp('What?')
    end
end