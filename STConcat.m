function [stCatTrain] = STConcat(stTrain1, stTrain2, strLevel)

% FUNCTION STConcat - Concatenate two spike trains
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

% $Id: STConcat.m,v 1.1 2004/06/04 09:35:46 dylan Exp $

% -- Check arguments


if ((nargin > 0) & iscell(stTrain1))
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
   for (nTrainIndex = 2:prod(size(stTrain1)))
      if (exist('strLevel') == 1)
         stCatTrain = STConcat(stCatTrain, stTrain1{nTrainIndex}, strLevel);
      else
         stCatTrain = STConcat(stCatTrain, stTrain1{nTrainIndex});
      end
   end
   return;
end


% -- Non-cell array mode

% -- Should we use mappings or instances?
% -- Which spike train level should we try to concatenate?

if (exist('strLevel') == 1)
   % - The user supplied a spike train level, so verify it
   [strLevel, bNotExisting, bInvalidLevel] = STFindMatchingLevel(stTrain1, stTrain2, strLevel);
   
   if (bNotExisting)
      % - The supplied level doesn't exist in one or both spike trains
      SingleLinePrinf('*** STConcat: To concatenate [%s], [%s] must exist in each spike train.', strLevel, strLevel);
      return;
   end
   
   if (bInvalidLevel | strcmp(strLevel, 'definition'))
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
      stCatTrain.mapping = STConcatNodes(stTrain1.mapping, stTrain2.mapping, true);
      
   case {'instance', 'i'}
      stCatTrain.instance = STConcatNodes(stTrain1.instance, stTrain2.instance, false);
      
   otherwise
      disp('*** STConcat: This error should never occur!');
end



% --- FUNCTION STConcatNodes
function [nodeCat] = STConcatNodes(node1, node2, bFixTempRes)
% Both nodes are either instance nodes or mapping nodes

% - Handle a zero-length spiketrain
if (node1.tDuration == 0)
   disp('--- STConcat: Warning: Zero-length spiketrain');
   nodeCat = node2;
   return;
end

if (node2.tDuration == 0)
   disp('-- STConcat: Warning: Zero-length spiketrain');
   nodeCat = node1;
   return;
end

% - Else create a new spiketrain in which to place the concatenation
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
for (nChunkIndex = 1:length(spikeList2))
   spikeList2{nChunkIndex}(:, 1) = spikeList2{nChunkIndex}(:, 1) + (node1.tDuration / node1.fTemporalResolution);
end

nodeCat.spikeList = {spikeList1{:} spikeList2{:}};
return;

% --- END of STConcat.m ---

% $Log: STConcat.m,v $
% Revision 1.1  2004/06/04 09:35:46  dylan
% Reimported (nonote)
%
% Revision 1.8  2004/05/09 17:55:14  dylan
% * Created STFlatten function to convert a spike train mapping back into an
% instance.
% * Created STExtract function to extract a train(s) from a multiplexed
% mapped spike train
% * Renamed STConstructAddress to STConstructPhysicalAddress
% * Modified the address format for spike train mappings such that the
% integer component of an address specifies the neuron.  This makes raster
% plots much easier to read.  The format is now
% |NEURON_BITS|.|SYNAPSE_BITS|  This is now referred to as a logical
% address.  The format required by the PCIAER board is referred to as a
% physical address.
% * Created STConstructLogicalAddress and STExtractLogicalAddress to
% convert neuron and synapse IDs to and from logical addresses
% * Created STExtractPhysicalAddress to convert a physical address back to
% neuron and synapse IDs
% * Modified STConstructPhysicalAddress so that it accepts vectorised input
% * Modified STConcat so that it accepts cell arrays of spike trains to
% concatenate
% * Modified STExport, STImport so that they handle logical / physical
% addresses
% * Fixed a bug in STMultiplex and STConcat where spike event addresses were
% modified when temporal resolutions were different across spike trains
% * Modified STFormats to reflect addresss format changes
%
% Revision 1.7  2004/05/05 16:15:17  dylan
% Added handling for zero-length spike trains to various toolbox functions
%
% Revision 1.6  2004/05/04 09:40:06  dylan
% Added ID tags and logs to all version managed files
%