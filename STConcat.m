function [stCatTrain] = STConcat(stTrain1, stTrain2, strLevel)

% STConcat - FUNCTION Concatenate two spike trains
% $Id: STConcat.m 124 2005-02-22 16:34:38Z dylan $
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

% $Log: STConcat.m,v $
% Revision 2.4  2004/11/11 13:02:55  dylan
% Fixed two bugs in STConcat, where neither instances nor mappings would be
% concatenated correctly (!)  Spike train instances would be incorrectl
% shifted based on their temporal resolutions; spike train mappings would not
% have their addressing specifcations correctly compared.
%
% Revision 2.3  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.2  2004/09/02 08:23:18  dylan
% * Added a function STIsZeroDuration to test for zero duration spike trains.
%
% * Modified all functions to use this test rather than custom tests.
%
% Revision 2.1  2004/07/19 16:21:01  dylan
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
% Revision 2.0  2004/07/13 12:56:31  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
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