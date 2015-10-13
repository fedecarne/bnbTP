%% (2) Define ROI's

[FileName,PathName,FilterIndex] = uigetfile('*.mat','Select registration file',[results_folder '/reg_results.mat']);

r_all = load([PathName FileName]);
r_all = r_all.results;

for channel=1:4
    r = r_all(:,channel);
    reg_r = cell2mat(r);
   
    if ~isempty(reg_r)
        
        frameMaster.frameMeanMaster{1,channel} = reshape([reg_r.frameMean],size(reg_r(1,1).frameMean,1),size(reg_r(1,1).frameMean,2),size(reg_r,1));
        frameMaster.frameVarMaster{1,channel} = var(frameMaster.frameMeanMaster{1,channel},1,3);
        frameMaster.frameCorrMaster{1,channel} = reshape([reg_r.ccimage],size(reg_r(1,1).ccimage,1),size(reg_r(1,1).ccimage,2),size(reg_r,1));
    else
        frameMaster.frameMeanMaster{1,channel} = [];
        frameMaster.frameVarMaster{1,channel} = [];
        frameMaster.frameCorrMaster{1,channel} = [];
    end
end
make_rois_edge(frameMaster);