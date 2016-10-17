function [stNormTrain] = STNormalise(stTrain)

% FUNCTION STNormalise -- Shift a spike train to time zero and fix its duration
%
% Usage: [stNormTrain] = STNormalise(stTrain)
%

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Date: 14th May, 2004

% $Id: STNormalise.m,v 1.1 2004/06/04 09:35:48 dylan Exp $

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

% $Log: STNormalise.m,v $
% Revision 1.1  2004/06/04 09:35:48  dylan
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