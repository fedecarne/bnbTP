%% (2) Define ROI's

[FileName,PathName,FilterIndex] = uigetfile('*.mat','Select registration file',[results_folder '/reg_results.mat']);

r = load([PathName FileName]);
reg_r = cell2mat(r.results);

%frameMeanMaster = reshape([reg_r.frameMean],size(reg_r(1,1).frameMean,1),size(reg_r(1,1).frameMean,2),size(reg_r,1));
%make_rois_edge1(frameMeanMaster);

frameMaster.frameMeanMaster = reshape([reg_r.frameMean],size(reg_r(1,1).frameMean,1),size(reg_r(1,1).frameMean,2),size(reg_r,1));
frameMaster.frameCorrMaster = reshape([reg_r.ccimage],size(reg_r(1,1).ccimage,1),size(reg_r(1,1).ccimage,2),size(reg_r,1));

make_rois_edge2(frameMaster);