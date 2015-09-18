function mask=findCellInFrame(varargin)

I=varargin{1};
fudgeFactor=varargin{2};

if numel(varargin{3})>0
    doAlso=varargin{3};
else
    doAlso{1}='none';
end

% % % get edges
edgeMethod='Sobel';
[~, threshold] = edge(I,edgeMethod);
BWs = edge(I,edgeMethod, threshold * fudgeFactor);
% figure, imagesc(BWs), title('binary gradient mask');

% % % dialate
se90 = strel('line',3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(BWs, [se90 se0]);
% figure, imagesc(BWsdil), title('dilated gradient mask');


% % % fill holes
BWdfill = imfill(BWsdil, 'holes');
% figure, imagesc(BWdfill);

% % % erode twice with diamond shaped mask
seD = strel('diamond',1);
BWdisk1 = imerode(BWdfill,seD);
seD = strel('diamond',1);
BWdisk2 = imerode(BWdisk1,seD);
% figure, imagesc(BWdisk1);
% figure, imagesc(BWdisk2);

% % % put holes bac in place
BWfinal=BWdisk2 & BWsdil;
% figure, imagesc(BWfinal);
% title('final')

for ll=1:length(doAlso)
    doNow=doAlso{ll};
    switch doNow%%% options
        case 'fillCell'
            BWfinal = imfill(BWfinal, 'holes');
        case 'dilateCell'
            BWfinal = imdilate(BWfinal, [se90 se0]);            
    end
end


% % % segment to get the largent mask only
[B,L,N,~]=bwboundaries(BWfinal,4);
[~,largestObject]=max(cellfun(@length,B(1:N)));
mask=zeros(size(L));
mask(L==largestObject)=1;


% IMasked=I;
% IMasked(mask==1)=IMasked(mask==1)*1.5;
% alpha=mask*.5;
% IRgb=repmat(I,[1,1,3])-min(I(:));
% IRgb=IRgb./max(IRgb(:));
% IRgb=repmat(IRgb,[1,1,3]);
% figure, image(IRgb), title('cleared border image');
% hold on
% maksRgb=cat(3,mask,zeros([size(mask),2]));
% h=image(maksRgb);
% h.AlphaData=alpha;


% BWfinal = imerode(BWfinal,seD);
% figure, imagesc(BWfinal), title('segmented image');
