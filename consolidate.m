function r_consolidated = consolidate(sshdata, code_folder, datafolder, results_folder, fileout, continuous_inspection)
%CONSOLIDATE Summary of this function goes here
%   Detailed explanation goes here

userName = sshdata.userName;
hostName = sshdata.hostName;
password = sshdata.password;

% Fill template to consolidate results
fTemplate = fopen('bnb_consolidate_template.sh');
fOutput = fopen('bnb_consolidate.sh', 'w+');

tline = fgetl(fTemplate);
while ischar(tline)
    tline = strrep( tline, '<<<datafolder>>>', datafolder);
    tline = strrep( tline, '<<<fileout>>>', fileout);
    fprintf( fOutput, [tline '\n'] );
    tline = fgetl(fTemplate);
end
fclose(fTemplate);
fclose(fOutput);

% Connect to BnB
channel  =  sshfrommatlab(userName,hostName,password);
done = 0;
while done == 0

    [~, msg]  =  sshfrommatlabissue(channel,'qstat');
    
    if isempty(msg{1,1})
 
        disp( 'Consolidating...');
        
        % Send .sh to consolidate
        sftpfrommatlab(userName,hostName,password,'bnb_consolidate.sh', [code_folder '/bnb_consolidate.sh'])
        
        % Submit consolidation job
        [~, msg]  =  sshfrommatlabissue(channel,['cd ' code_folder ' && qsub bnb_consolidate.sh']);
        
        % Wait and bring the results
        while ~isempty(msg{1,1})
            % Bring the results
            [~, msg]  =  sshfrommatlabissue(channel,'qstat');
        end
        % Remove consolidate sh, e and o files
        sshfrommatlabissue(channel,['cd ' code_folder '&& rm -f bnb_consolidate.sh*']);
        
        % Close connection to BnB
        sshfrommatlabclose(channel);
        
        % Ready to retrieve results from BnB?
        choice = questdlg('Ready to retrieve results from BnB?', 'Yes', 'No');
        % Handle response
        switch choice
            case 'No'
                r_consolidated = 0;
                return
        end
        system(['scp fcarneva@bnbdev1.cshl.edu:~/' code_folder '/' fileout '.mat ' results_folder '/' fileout '.mat']);
        
        r = load([results_folder '/' fileout '.mat']);

        r = cell2mat(r.results);
        
        %reorder according to file index
        [~,sorted_idx] = sort([r.index])
        
        r_consolidated = r(sorted_idx,:);
        done=1;
        
    else
        disp(msg);
        if ~continuous_inspection
            done=1;
        end
    end
end