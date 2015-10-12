[FileName,PathName,FilterIndex] = uigetfile('*.mat','Select registration file',[results_folder '/reg_results.mat']);

r = load([PathName FileName]);

channel = 1;

r = r.results;
r = r(:,channel);
reg_r = cell2mat(r);

frameMaster.frameMeanMaster = reshape([reg_r.frameMean],size(reg_r(1,1).frameMean,1),size(reg_r(1,1).frameMean,2),size(reg_r,1));
frameMaster.frameCorrMaster = reshape([reg_r.ccimage],size(reg_r(1,1).ccimage,1),size(reg_r(1,1).ccimage,2),size(reg_r,1));

make_zstackView(frameMaster);