function [stNormTrain] = STNormalise(stTrain)

% STNormalise - FUNCTION Shift a spike train to time zero and fix its duration
% $Id: STNormalise.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [stNormTrain] = STNormalise(stTrain)
%
% This function will shift the first spike in a spike train to time zero, and
% correct the duration fields of the spike train object to reflect the true
% duration of the train.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Date: 14th May, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STNormalise: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STNormalise: Incorrect usage');
   help STNormalise;
   return;
end


% -- Normalise spike levels

if (isfield(stTrain, 'mapping'))
   stNormTrain.mapping = STNormaliseNode(stTrain.mapping);
   stNormTrain.mapping.tDuration = stNormTrain.mapping.tDuration * stNormTrain.mapping.fTemporalResolution;
end

if (isfield(stTrain, 'instance'))
   stNormTrain.mapping = STNormaliseNode(stTrain.instance);
end

if (isfield(stTrain, 'definition'))
   disp('--- STNormalise: Warning: Spike train definitions are stripped from normalised spike trains');
end


% --- FUNCTION STNormaliseNode

function [nodeNorm] = STNormaliseNode(node)

nodeNorm = node;

% - Extract spike list
if (nodeNorm.bChunkedMode)
   spikeList = node.spikeList;
   nNumChunks = node.nNumChunks;
else
   spikeList = {node.spikeList};
   nNumChunks = 1;
end

tOldFirstSpikeTime = spikeList{1}(1, 1);

% - Normalise chunks
for (nChunkIndex = 1:length(spikeList))
   spikeList{nChunkIndex}(:, 1) = spikeList{nChunkIndex}(:, 1) - tOldFirstSpikeTime;
end

% - Correct duration
nodeNorm.tDuration = max(spikeList{nNumChunks}(:, 1));

% - Reassign spike list
if (nodeNorm.bChunkedMode)
   nodeNorm.spikeList = spikeList;
else
   nodeNorm.spikeList = spikeList{1};
end

% --- END of STNormalise.m ---
