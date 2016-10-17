function [stCatTrain] = STConcat(stTrain1, stTrain2, strLevel)

% STConcat - FUNCTION Concatenate two spike trains
% $Id: STConcat.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [stTrain] = STConcat(stTrain1, stTrain2)
%        [stTrain] = STConcat(stTrain1, stTrain2, strLevel)
%        [stTrain] = STConcat(stCellTrain)
%        [stTrain] = STConcat(stCellTrain, strLevel)
%
% STConcat combines two spike trains by joining them end-to-end.  'stTrain1'
% and 'stTrain2' are spike trains containing either mappings or instances.
% 'stTrain2' will be tacked on to the end of 'stTrain1'.  'strLevel' can be
% optionally used to specify what spike train level to concatenate, and must
% be one of {'instance', 'mapping'}.
%
% STConcat can also accept a cell array of spike trains to concatenate.  In
% this mode, the trains will be concatenated from index 1 to the end of the
% array.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd April, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if ((nargin > 0) && iscell(stTrain1))
   % - The first argument is a cell array
   if (nargin > 2)
      disp('--- STConcat: Extra arguments ignored');
   end
   
   if (nargin > 1)
      % - Remap second argument to strLevel
      strLevel = stTrain2;
      clear stTrain2;
   end
   
else
   % - Not using a cell array of spike trains
   if (nargin > 3)
      disp('--- STConcat: Extra arguments ignored');
   end

   if (nargin < 2)
      disp('*** STConcat: Incorrect number of arguments');
   end
end


% -- Handle a cell array of spike trains

if (iscell(stTrain1))
   % - Initialise first train
   stCatTrain = stTrain1{1};
   
   % - This loop won't be executed if there are less than two spike trains
   % in the array
   for (nTrainIndex = 2:numel(stTrain1))
      if (exist('strLevel', 'var') == 1)
         stCatTrain = STConcat(stCatTrain, stTrain1{nTrainIndex}, strLevel);
      else
         stCatTrain = STConcat(stCatTrain, stTrain1{nTrainIndex});
      end
   end
   return;
end


% -- Non-cell array mode

% - Handle zero-duration spike trains
if (STIsZeroDuration(stTrain1))
   disp('--- STConcat: Warning: Zero-duration spike train');
   stCatTrain = stTrain2;
   return;
end

if (STIsZeroDuration(stTrain2))
   disp('--- STConcat: Warning: Zero-duration spike train');
   stCatTrain = stTrain1;
   return;
end

% -- Should we use mappings or instances?
% -- Which spike train level should we try to concatenate?

if (exist('strLevel', 'var') == 1)
   % - The user supplied a spike train level, so verify it
   [strLevel, bNotExisting, bInvalidLevel] = STFindMatchingLevel(stTrain1, stTrain2, strLevel);
   
   if (bNotExisting)
      % - The supplied level doesn't exist in one or both spike trains
      SingleLinePrinf('*** STConcat: To concatenate [%s], [%s] must exist in each spike train.', strLevel, strLevel);
      return;
   end
   
   if (bInvalidLevel || strcmp(strLevel, 'definition'))
      % - The user supplied an invalid spike train level
      SingleLinePrintf('*** STConcat: Invalid spike train level [%s].', strLevel);
      disp('       strLevel must be one of {instance, mapping}');
      return;
   end

else  % - Determine a spike train level we can use
   [strLevel, bNoMatching] = STFindMatchingLevel(stTrain1, stTrain2);
   
   if (bNoMatching)
      % - There is no consistent spike train level
      disp('*** STConcat: To concatenate trains, either a mapping or an instance');
      disp('       must exist in both spike trains');
      return;
   end
end
   
% - Concatenate nodes
switch lower(strLevel)   
   case {'mapping', 'm'}
      % - Do both spike trains share a common addressing specification?
      if (~STAddrSpecCompare(stTrain1.mapping.stasSpecification, stTrain2.mapping.stasSpecification))
         disp('*** STConcat: Only mapped spike trains sharing a common addressing');
         disp('       specification can be concatenated');
         return;
      end
      
      % - Concatenate the nodes
      stCatTrain.mapping = STConcatNodes(stTrain1.mapping, stTrain2.mapping, true);
      
      % - Copy the addressing specification
      stCatTrain.mapping.stasSpecification = stTrain1.mapping.stasSpecification;
      
   case {'instance', 'i'}
      stCatTrain.instance = STConcatNodes(stTrain1.instance, stTrain2.instance, false);
      
   otherwise
      disp('*** STConcat: This error should never occur!');
end

% --- END STConcat FUNCTION ---


% --- STConcatNodes - FUNCTION
function [nodeCat] = STConcatNodes(node1, node2, bFixTempRes)
% Both nodes are either instance nodes or mapping nodes

% - Create a new spike train node in which to place the concatenation
nodeCat.bChunkedMode = true;  % It's easier this way
nodeCat.tDuration = node1.tDuration + node2.tDuration;

% - Make sure the nodes share a common temporal resolution
fTempResFactor = node1.fTemporalResolution / node2.fTemporalResolution;
nodeCat.fTemporalResolution = node1.fTemporalResolution;

% -- Extract spike lists
if (node1.bChunkedMode)
   spikeList1 = node1.spikeList;
else
   spikeList1 = {node1.spikeList};
end

if (node2.bChunkedMode)
   spikeList2 = node2.spikeList;
else
   spikeList2 = {node2.spikeList};
end

% -- Fix the temporal resolution for spike list 2
if (bFixTempRes)
   for (nChunkIndex = 1:length(spikeList2))
      spikeList2{nChunkIndex}(:, 1) = floor(spikeList2{nChunkIndex}(:, 1) .* fTempResFactor);
   end
end
   
% -- Determine new list length
nodeCat.nNumChunks = length(spikeList1) + length(spikeList2);

% -- Offset the second spike list in time
if (bFixTempRes)
   for (nChunkIndex = 1:length(spikeList2))
      % - For mappings, spike time signatures are in temporal resolution
      % counts, therefore we need to adjust for this
      spikeList2{nChunkIndex}(:, 1) = spikeList2{nChunkIndex}(:, 1) + (node1.tDuration / node1.fTemporalResolution);
   end
else
   for (nChunkIndex = 1:length(spikeList2))
      % - For instances, spike time signatures are in seconds
      spikeList2{nChunkIndex}(:, 1) = spikeList2{nChunkIndex}(:, 1) + node1.tDuration;
   end
end   
   
nodeCat.spikeList = {spikeList1{:} spikeList2{:}};
return;

% --- END of STConcat.m ---
