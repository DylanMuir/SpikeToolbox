function [stCroppedTrain] = STCrop(stMappedTrain, tMinTime, tMaxTime)

% FUNCTION STCrop - Crop a spike train to a specified time extent
%
% Usage: [stCroppedTrain] = STCrop(stMappedTrain, tMinTime, tMaxTime)
%
% Note: STCrop will not shift the cropped spike train to zero, or fix the
% duration of the train -- see the STNormalise function for help with this.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Date: 14th May, 2004

% $Id: STCrop.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Check arguments

if (nargin > 3)
   disp('--- STCrop: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STCrop: Incorrect usage');
   help STCrop;
   return;
end

if (~isfield(stMappedTrain, 'mapping'))
   disp('*** STCrop: The supplied spike train must contain a mapping');
   return;
end


% - Fix time extents and convert to integer time step format
tSortedTimes = sort([tMinTime tMaxTime]);
tMinTime = floor(tSortedTimes(1) / stMappedTrain.mapping.fTemporalResolution);
tMaxTime = ceil(tSortedTimes(2) / stMappedTrain.mapping.fTemporalResolution);

% - Create new mapping
mapping = [];
mapping.tDuration = stMappedTrain.mapping.tDuration;
mapping.bChunkedMode = stMappedTrain.mapping.bChunkedMode;
mapping.fTemporalResolution = stMappedTrain.mapping.fTemporalResolution;

% - Extract spike train
if (stMappedTrain.mapping.bChunkedMode)
   spikeList = stMappedTrain.mapping.spikeList;
   nNumChunks = stMappedTrain.mapping.nNumChunks;
else
   spikeList = {stMappedTrain.mapping.spikeList};
   nNumChunks = 1;
end

% - Crop spikes in chunks
for (nChunkIndex = 1:nNumChunks)
   matchingSpikes = (spikeList{nChunkIndex}(:, 1) >= tMinTime) & (spikeList{nChunkIndex}(:, 1) <= tMaxTime);
   spikeList{nChunkIndex} = spikeList{nChunkIndex}(find(matchingSpikes), :);
end

% - Remove empty chunks
emptyChunks = CellForEach('isempty', spikeList);
spikeList = spikeList(find(~emptyChunks));

% - Assign spike list
if (mapping.bChunkedMode)
   mapping.spikeList = spikeList;
   mapping.nNumChunks = length(spikeList);
else
   mapping.spikeList = spikeList{1};
end

% - Assign mapping
stCroppedTrain.mapping = mapping;

% --- END of STCrop.m ---

% $Log: STCrop.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.1  2004/05/14 15:37:19  dylan
% * Created utilities/CellFlatten.m -- CellFlatten coverts a list of items
% into a cell array containing a single cell for each item.  CellFlatten will
% also flatten the heirarchy of a nested cell array, returning all cell
% elements on a single dimension
% * Created utiltites/CellForEach.m -- CellForEach executes a specified
% function for each top-level element of a cell array, and returns a matrix of
% the results.
% * Converted spike_tb/STFindMatchingLevel to natively process cell arrays of trains
% * Converted spike_tb/STMultiplex to natively process cell arrays of trains
% * Created spike_tb/STCrop.m -- STCrop will crop a spike train to a specified
% time extent
% * Created spike_tb/STNormalise.m -- STNormalise will shift a spike train to
% begin at zero (first spike is at zero) and correct the duration
%