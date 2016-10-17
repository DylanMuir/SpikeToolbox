function [stMuxTrain] = STMultiplex(varargin)

% STMultiplex - FUNCTION Multiplex spike trains
% $Id: STMultiplex.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stMuxTrain] = STMultiplex(stTrain1, stTrain2, ...)
%        [stMuxTrain] = STMultiplex(strLevel, stTrain1, stTrain2, ...)
%        [stMuxTrain] = STMultiplex(stTrainCell)
%        [stMuxTrain] = STMultiplex(strLevel, stTrainCell)
%
% Where: 'stTrain1', 'stTrain2', etc. are spike strains containing either
% instances or mappings.  STMultiplex will combine the two trains into a
% sinlge train by interleaving or otherwise the individual spikes from the two
% trains.  A specific spike train level to multiplex can be specifed using
% 'strLevel', this argument must be one of {'instance', 'mapping'}.
%
% STMultiuplex can accept a cell array of spike trains for multiplexing.  The
% optional 'strLevel' argument can still be supplied.  In this mode, the spike
% trains in the cell array will be multiplexed together and returned as a
% single train.
%
% NOTE: STMultiplex currently assumes that concatenating two chunks will never
% give a chunk bigger than can fit in a single matrix.  Fixing this makes
% the algorithm more complex, and a pain.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 1st April, 2004 (no, really)

% -- Check arguments

if ((nargin < 1) | (ischar(varargin{1}) & (nargin < 2)))
   disp('*** STMultiplex: Incorrect usage');
   help STMultiplex;
   return;
end


% -- Extract arguments

if (ischar(varargin{1}))
   strLevel = varargin{1};
   varargin = varargin{2:length(varargin)};
end

stTrain = CellFlatten(varargin);

% - Check that we have at least two trains
if (length(stTrain) < 2)
   disp('--- STMultiplex: I need at least two spike trains to multiplex');
   stMuxTrain = stTrain{1};
   return;
end


% -- Which spike train level should we try to multiplex?

if (exist('strLevel') == 1)
   % - The user supplied a spike train level, so verify it
   [strLevel, bNotExisting, bInvalidLevel] = STFindMatchingLevel(strLevel, stTrain);
   
   if (bNotExisting)
      % - The supplied level doesn't exist in one or both spike trains
      SingleLinePrinf('*** STMultiplex: To multiplex [%s], [%s] must exist in each spike train.', strLevel, strLevel);
      return;
   end
   
   if (bInvalidLevel | strcmp(strLevel, 'definition'))
      % - The user supplied an invalid spike train level
      SingleLinePrintf('*** STMultiplex: Invalid spike train level [%s].', strLevel);
      disp('       strLevel must be one of {instance, mapping}');
      return;
   end

else  % - Determine a spike train level we can use
   [strLevel, bNoMatching] = STFindMatchingLevel(stTrain);
   
   if (bNoMatching)
      % - There is no consistent spike train level
      disp('*** STMultiplex: To multiplex trains, either a mapping or an instance must');
      disp('       exist in both spike trains');
      return;
   end
end


% -- Multiplex nodes

% -- Handle zero-duration spike trains
% - Detect zero-duration trains
vbZeroDuration = CellForEach(@STIsZeroDuration, stTrain);

% - Test that we actually have some spike trains remaining to multiplex!
if (all(vbZeroDuration))
   disp('--- STMultiplex: Only zero-length spike trains to multiplex!');
   nodeMux.fTemporalResolution = stTrain{1}.(strLevel).fTemporalResolution;
   nodeMux.tDuration = 0;
   nodeMux.bChunkedMode = false;
   nodeMux.spikeList = [];
   stMuxTrain.(strLevel) = nodeMux;
   return;
   
elseif (any(vbZeroDuration))
   % - Warn the user about zero-length spiketrains
   warning('SpikeToolbox:ZeroDuration', 'STMultiplex: Zero-length spike train.  These trains will be ignored.');
end

% - Do we have more than one non null spike train?
if (sum(~vbZeroDuration) < 2)
   % - There's not even two trains left to multiuplex, so we should
   %   just return the non-null train
   stMuxTrain = stTrain{find(~vbZeroDuration)};
   return;
end

% - Filter out zero-duration spike trains
stTrain = stTrain(find(~vbZeroDuration));

% - Strip all spike train levels except the relevant one
sRef.type = '.';
sRef.subs = strLevel;
stNodes = CellForEachCell(@subsref, stTrain, sRef);

switch (strLevel)   
   case {'mapping'}
      % - Extract all addressing specifications
      sRef.subs = 'stasSpecification';
      stasSpecs = CellForEachCell(@subsref, stNodes, sRef);
      
      % - Test to see that all addressing specifications are equal
      if (~STAddrSpecCompare(stasSpecs{:}))
         disp('*** STMultiplex: Can only multiplex spike trains with identical');
         disp('                 addressing specifications');
         return;
      end
      
      stMuxTrain.mapping = STMultiplexNodes(true, stNodes);
      
      % - Add extra fields to the mapping
      stMuxTrain.mapping.stasSpecification = stNodes{1}.stasSpecification;
      
   case {'instance'}
      stMuxTrain.instance = STMultiplexNodes(false, stNodes);
      
   otherwise
      disp('*** STMultiuplex: Only instantiated or mapped spike trains can be');
      disp('                  multiplexed.');
end

% --- END of STMultiplex FUNCTION ---


% --- FUNCTION STMultiplexNodes
function [nodeMux] = STMultiplexNodes(bFixTempRes, nodeCellArray)
% All nodes are either instance nodes or mapping nodes

% -- Get options
stOptions = STOptions;
SpikeChunkLength = stOptions.SpikeChunkLength;

% - Create output node
nodeMux = [];

% - The duration will be that of the longest spiketrain
sRef.type = '.';
sRef.subs = 'tDuration';
vDurations = CellForEach(@subsref, nodeCellArray, sRef);
nodeMux.tDuration = max(vDurations);


% -- Make sure the nodes share a common temporal resolution
nodeMux.fTemporalResolution = nodeCellArray{1}.fTemporalResolution;

sRef.subs = 'fTemporalResolution';
vfTempResolutions = CellForEach(@subsref, nodeCellArray, sRef);

vfTempResFactor = nodeMux.fTemporalResolution ./ vfTempResolutions;

% - Fix the temporal resolution for each spike train node
for (nNodeIndex = 1:prod(size(nodeCellArray)))
   if (nodeCellArray{nNodeIndex}.bChunkedMode)
      % - Fix the temporal resolution for each chunk of a chunked mode
      %   spike list
      for (nChunkIndex = 1:length(nodeCellArray{nNodeIndex}.spikeList))
         nodeCellArray{nNodeIndex}.spikeList{nChunkIndex}(:, 1) = nodeCellArray{nNodeIndex}.spikeList{nChunkIndex}(:, 1) * vfTempResFactor(nNodeIndex);
      end
      
   else
      % - Fix the temporal resolution for a non chunked mode spike list
      nodeCellArray{nNodeIndex}.spikeList(:, 1) = nodeCellArray{nNodeIndex}.spikeList(:, 1) * vfTempResFactor(nNodeIndex);
   end
end


% -- If all the spikes will fit into a single chunk, then we can use a
% simplistic sorting algorithm.  Otherwise things will be more difficult...

% - Extract the spike lists
sRef.subs = 'spikeList';
spikeList = CellFlatten(CellForEachCell(@subsref, nodeCellArray, sRef));

% - How many spikes do we have in total?
nTotalSpikes = 0;
for (nChunkIndex = 1:length(spikeList))
   nTotalSpikes = nTotalSpikes + size(spikeList{nChunkIndex}, 1);
end

if (nTotalSpikes <= SpikeChunkLength)
   % - We can do a simple cat'n'sort
   spikeList = vertcat(spikeList{:});
   spikeList = sortrows(spikeList, 1);
   nodeMux.bChunkedMode = false;
   nodeMux.spikeList = spikeList;
   return;
   
else
   % - We have to do a more complex sort
   nodeMux.bChunkedMode = true;
   
   % spikeList = SortCrossChunk(spikeList)
   
   disp('*** STMultiplex: Cross-chunk sorting is not yet implemented.  Sorry!');
   return;
end

% --- END of STMultiplexNodes FUNCTION ---


% --- FUNCTION SortCrossChunk
function SortCrossChunk(spikeList)

% -- Sort (pick'n'place)
% NOTE: Spike list chunks are assumed to be already sorted
%       Spike list chunks should ALWAYS be maintained in sorted order!

nChunkLength = 0;
nCurrentChunk = 1;
sortedSpikeList = [];
nTotalInputChunks = length(spikeList);

while true
   % - Find the minimum chunk
   for (nChunkIndex = 1:nTotalInputChunks)
   end
   
   
end

% --- OLD sorting code

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


% -- Determine the total number of chunks
if (nodeMux.bChunkedMode)
   nodeMux.nNumChunks = max([length(spikeList1) length(spikeList2)]);
   nNumChunks = nodeMux.nNumChunks;
else
   nNumChunks = 1;
end


% -- Fix the temporal resolution for spike list 2
if (bFixTempRes)
   for (nChunkIndex = 1:length(spikeList2))
      spikeList2{nChunkIndex}(:, 1) = floor(spikeList2{nChunkIndex}(:, 1) .* fTempResFactor);
   end
end


% -- Iterate through the spike lists and make sure each chunk is the same
% duration (but only if we're using chunked mode)

if (nodeMux.bChunkedMode)
   % - Arbitrarily assign the shorter and longer spike lists
   shortList = spikeList1;
   longList = spikeList2;

   for (nChunkIndex = 1:min([length(spikeList1) length(spikeList2)]))   % Iterate to the end of the shorter list
      % - Find which spike list chunk finishes later
    bMismatchedChunks = false;
      if (max(longList{nChunkIndex}(:, 1)) > max(shortList{nChunkIndex}(:, 1)))
         bMismatchedChunks = true;
      
      elseif (max(shortList{nChunkIndex}(:, 1)) > max(longList{nChunkIndex}(:, 1)))
         % - The end of spike list 2 is after the end of spike list 1
         %   We need to make sure that we only take up to the same time for both
         %   chunks
         tempList = longList;
         longList = shortList;
         shortList = tempList;
         bMismatchedChunks = true;
      end
      
      if (bMismatchedChunks)
         % - Find the point in the longer chunk that we should shift to the next
         % chunk
         [null, nIndices] = find(longList{nChunkIndex}(:, 1) > max(shortList{nChunkIndex}(:, 1)));
      
         if (length(longList) == nChunkIndex)   % Does the next chunk exist?
            % - No, so make a new chunk
            longList{nChunkIndex+1} = [];
         end
      
         % - Concatenate the longer portion of the longer list with the next chunk 
         % of the longer list
         longList{nChunkIndex+1} = cat(1, longList{nChunkIndex}(nIndices(1), :), longList{nChunkIndex+1});
         
         if (nChunkIndex == nNumChunks)      % Did we go beyond the end of the chunks we had allowed for?
            % - Yes, so update the total number of chunks required
            nNumChunks = nNumChunks + 1;
            nodeMux.nNumChunks = nNumChunks;
         end
      end
   end

   % - Arbitrarily reassign the spike lists
   spikeList1 = shortList;
   spikeList2 = longList;
end
   
% -- Now iterate through the spike lists and multiplex them      
for (nChunkIndex = 1:nNumChunks)
   % - Have we gone beyond the end of the shorter list?
   if (length(spikeList1) < nChunkIndex)
      % - Just assign the rest of spikeList2
      spikeListMux{nChunkIndex:nNumChunks} = spikeList2{nChunkIndex:nNumChunks};
      break;
      
   elseif (length(spikeList2) < nChunkIndex)
      % - Just assign the rest of spike list 1
      spikeListMux{nChunkIndex:nNumChunks} = spikeList1{nChunkIndex:nNumChunks};
      break;
      
   else
      % - We need to multiplex
      spikeListMux{nChunkIndex} = sortrows(cat(1, spikeList1{nChunkIndex}, spikeList2{nChunkIndex}));
   end
end


% -- Assign the spike list
if (nodeMux.bChunkedMode)
   nodeMux.spikeList = spikeListMux;
else
   nodeMux.spikeList = spikeListMux{1};
end

return;

% --- END of SortCrossChunk FUNCTION ---

% --- END of STMultiplex.m ---

% $Log: STMultiplex.m,v $
% Revision 2.11  2005/02/20 13:15:09  dylan
% Modified STMap, STMultiplex, STProfileFrequency and STProfileCount to use the
% MATLAB warning system when warning about zero-duration spike trains.  These
% warnings can now be turned off using the built-in WARNING function.  The message
% ID for these warnings (and for the rest of the toolbox as well) will be
% 'SpikeToolbox:ZeroDuration'.
%
% Revision 2.10  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.9  2004/09/03 12:41:43  dylan
% Typo in STMultiplex (nonote)
%
% Revision 2.8  2004/09/03 09:40:48  dylan
% Fixed a bug in STMultiplex when only a single non-zero-duration train was
% supplied.  STMultiplex now returns this train.
%
% Revision 2.7  2004/09/02 08:57:07  dylan
% Bug in STMultiplex (nonote)
%
% Revision 2.6  2004/09/02 08:54:30  dylan
% Bug in STMultiplex (nonote)
%
% Revision 2.5  2004/09/02 08:51:05  dylan
% Bug in STMultiplex (nonote)
%
% Revision 2.4  2004/09/02 08:23:18  dylan
% * Added a function STIsZeroDuration to test for zero duration spike trains.
%
% * Modified all functions to use this test rather than custom tests.
%
% Revision 2.3  2004/09/01 08:30:15  dylan
% Fixed a bug in STMultiplex when only zero-length spike trains are supplied
% to multiplex.  STMultiplex now handles this condition, and returns a zero-
% length spike train.
%
% Revision 2.2  2004/08/25 12:49:22  dylan
% * Fixed a bug in STMultiplex, where spike trains with different levels
% could not be multiplexed, even if they shared a common level.
% STMultiplex now requires CellForEachCell, in the utilities repository.
%
% * Added a feature request to Todo.txt
%
% Revision 2.1  2004/07/19 16:21:02  dylan
% * Major update of the spike toolbox (moving to v0.02)
%
% * Modified the procedure for retrieving and setting toolbox options.  The new
% suite of functions comprises of STOptions, STOptionsLoad, STOptionsSave,
% STOptionsDescribe, STCreateGlobals and STIsValidOptionsStruct.  Spike Toolbox
% 'factory default' options are defined in STToolboxDefaults.  Options can be
% saved as user defaults using STOptionsSave, and will be loaded automatically
% for each session.
%
% * Removed STAccessDefaults and STCreateDefaults.
%
% * Renamed STLogicalAddressConstruct, STLogicalAddressExtract,
% STPhysicalAddressContstruct and STPhysicalAddressExtract to
% STAddr<type><verb>
%
% * Drastically modified the way synapse addresses are specified for the
% toolbox.  A more generic approach is now taken, where addressing modes are
% defined by structures that outline the meaning of each bit-field in a
% physical address.  Fields can have their bits reversed, can be ignored, can
% have a description attached, and can be marked as major or minor fields.
% Any type of neuron/synapse topology can be addressed in this way, including
% 2D neuron arrays and chips with no separate synapse addresses.
%
% The following functions were created to handle this new addressing mode:
% STAddrDescribe, STAddrFilterArgs, STAddrSpecChannel, STAddrSpecCompare,
% STAddrSpecDescribe, STAddrSpecFill, STAddrSpecIgnoreSynapseNeuron,
% STAddrSpecInfo, STAddrSpecSynapse2DNeuron, STIsValidAddress, STIsValidAddrSpec,
% STIsValidChannelAddrSpec and STIsValidMonitorChannelsSpecification.
%
% This modification required changes to STAddrLogicalConstruct and Extract,
% STAddrPhysicalConstruct and Extract, STCreate, STExport, STImport,
% STStimulate, STMap, STCrop, STConcat and STMultiplex.
%
% * Removed the channel filter functions.
%
% * Modified STDescribe to handle the majority of toolbox variable types.
% This function will now describe spike trains, addressing specifications and
% spike toolbox options.  Added STAddrDescribe, STOptionsDescribe and
% STTrainDescribe.
%
% * Added an STIsValidSpikeTrain function to test the validity of a spike
% train structure.  Modified many spike train manipulation functions to use
% this feature.
%
% * Added features to Todo.txt, updated Readme.txt
%
% * Added an info.xml file, added a welcome HTML file (spike_tb_welcome.html)
% and associated images (an_spike-big.jpg, an_spike.gif)
%
% Revision 2.0  2004/07/13 12:56:32  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.3  2004/07/13 12:55:19  dylan
% (nonote)
%
% Revision 1.2  2004/06/04 10:12:05  dylan
% Modified STMultiplex to handle single spike train inputs nicely by printing an error and then returning the supplied train. (nonote)
%
% Revision 1.1  2004/06/04 09:35:48  dylan
% Reimported (nonote)
%
% Revision 1.16  2004/05/25 10:51:05  dylan
% Bug fixes (nonote)
%
% Revision 1.15  2004/05/14 16:21:19  dylan
% Bug fix (nonote)
%
% Revision 1.14  2004/05/14 16:17:50  dylan
% Bug fix (nonote)
%
% Revision 1.13  2004/05/14 15:37:19  dylan
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
% Revision 1.12  2004/05/09 17:55:15  dylan
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
% Revision 1.11  2004/05/05 16:15:17  dylan
% Added handling for zero-length spike trains to various toolbox functions
%
% Revision 1.10  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%
