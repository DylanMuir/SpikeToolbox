function [stFlatTrain] = STFlatten(stTrain)

% STFlatten - FUNCTION Convert a mapped spike train back to an instance
% $Id: STFlatten.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [stFlatTrain] = STFlatten(stTrain)
%
% 'stTrain' must contain a mapping.  STFlatten will remove addressing
% information from the mapping, and convert it to a spike train instance.  If
% the mapping contains trains mapped to more than one address, these will be
% merged together in the spike train instance.  'stFlatTrain' will be a new
% spike train structure comprising of a field 'instance', which contains the
% flattened train.

% Author: Dylan Muir <sylan@ini.phys.ethz.ch>
% Created: 9th May, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STFlatten: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STFlatten: Incorrect usage');
   help STFlatten;
   return;
end

% - Check that a mapping exists
if (~FieldExists(stTrain, 'mapping'))
   disp('*** STFlatten: The spike train to flatten must contain a mapping');
   return;
end

% -- Handle a zero-duration spike train
if (STIsZeroDuration(stTrain))
	disp('--- STFlatten: Warning: zero-duration spiketrain');
	instance.tDuration = 0;
	instance.bChunkedMode = false;
	instance.fTemporalResolution = stTrain.mapping.fTemporalResolution;
	instance.spikeList = [];
   stFlatTrain.instance = instance;
	return;
end


% -- Flatten the spike train

% - Extract the spike list
if (stTrain.mapping.bChunkedMode)
   spikeList = stTrain.mapping.spikeList;
   nNumChunks = stTrain.mapping.nNumChunks;
else
   spikeList = {stTrain.mapping.spikeList};
   nNumChunks = 1;
end

% - Flatten the train
for (nChunkIndex = 1:nNumChunks)
   spikeList{nChunkIndex} = spikeList{nChunkIndex}(:, 1) .* stTrain.mapping.fTemporalResolution;
end

% - Make a new instance
instance.tDuration = stTrain.mapping.tDuration;
instance.bChunkedMode = stTrain.mapping.bChunkedMode;
instance.fTemporalResolution = stTrain.mapping.fTemporalResolution;

% - Assign the flattened spike train
if (instance.bChunkedMode)
   instance.spikeList = spikeList;
else
   instance.spikeList = spikeList{1};
end

% - Return the flattened train
stFlatTrain.instance = instance;


% --- END of STFlatten.m ---
