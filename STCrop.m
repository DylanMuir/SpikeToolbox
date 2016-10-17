function [stCroppedTrain] = STCrop(stTrain, tMinTime, tMaxTime)

% STCrop - FUNCTION Crop a spike train to a specified time extent
% $Id: STCrop.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [stCroppedTrain] = STCrop(stTrain, tMinTime, tMaxTime)
%
% STCrop will crop a spike train to the extents specified in 'tMinTime' and
% 'tMaxTime' (in seconds).  Any spikes outside these times will be removed.
% 'stCroppedTrain' will be a new spike train containing spikes only in the
% time range specified.
%
% Note: STCrop will not shift the cropped spike train to zero -- see the
% STNormalise function for help with this.  However, STCrop will correct the
% duration of the spike train to end at tMaxTime.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Date: 14th May, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 3)
   disp('--- STCrop: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STCrop: Incorrect usage');
   help STCrop;
   return;
end

if (~STIsValidSpikeTrain(stTrain))
   disp('*** STCrop: Invalid spike train supplied');
   return;
end

% - What spike train levels exist in 'stTrain'?
if (isfield(stTrain, 'instance'))
   bUseInstance = true;
else
   bUseInstance = false;
end

if (isfield(stTrain, 'mapping'))
   bUseMapping = true;
else
   bUseMapping = false;
end

% - Check that some croppable spike train level exists
if (~(bUseInstance || bUseMapping))
   disp('*** STCrop: ''stTrain'' must be either an instantiated or mapped spike train');
   return;
end


% -- Fix time extents and convert to integer time step format

tSortedTimes = sort([tMinTime tMaxTime]);

if (bUseMapping)
   nodeOld = stTrain.mapping;
   
   tMinTime = floor(tSortedTimes(1) / nodeOld.fTemporalResolution);
   tMaxTime = ceil(tSortedTimes(2) / nodeOld.fTemporalResolution);
else
   nodeOld = stTrain.instance;
   
   tMinTime = tSortedTimes(1);
   tMaxTime = tSortedTimes(2);
end


% -- Create new node

nodeNew = [];
nodeNew.fTemporalResolution = nodeOld.fTemporalResolution;
nodeNew.tDuration = tMaxTime;       % nodeOld.tDuration;

if (bUseMapping)
   nodeNew.stasSpecification = nodeOld.stasSpecification;
   nodeNew.tDuration = tMaxTime .* nodeNew.fTemporalResolution;
end

% - Extract spike train
if (nodeOld.bChunkedMode)
   spikeList = nodeOld.spikeList;
   nNumChunks = nodeOld.nNumChunks;
else
   spikeList = {nodeOld.spikeList};
   nNumChunks = 1;
end

% - Crop spikes in chunks
for (nChunkIndex = 1:nNumChunks)
   vbMatchingSpikes = (spikeList{nChunkIndex}(:, 1) >= tMinTime) & (spikeList{nChunkIndex}(:, 1) <= tMaxTime);
   spikeList{nChunkIndex} = spikeList{nChunkIndex}(vbMatchingSpikes, :);
end

% - Remove empty chunks
vbEmptyChunk = CellForEach('isempty', spikeList);
spikeList = spikeList(~vbEmptyChunk);

% - Handle the case where there are no spikes left
if (isempty(spikeList))
   % - This will result in a null spike train
   spikeList = {[]};
end

% - Assign spike list
if (length(spikeList) > 1)
   nodeNew.spikeList = spikeList;
   nodeNew.bChunkedMode = true;
   nodeNew.nNumChunks = length(spikeList);
else
   nodeNew.bChunkedMode = false;
   nodeNew.spikeList = spikeList{1};
end

% - Assign node
if (bUseMapping)
   stCroppedTrain.mapping = nodeNew;
else
   stCroppedTrain.instance = nodeNew;
end

% --- END of STCrop.m ---
