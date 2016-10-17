function [stCroppedTrain] = STCrop(stMappedTrain, tMinTime, tMaxTime)

% STCrop - FUNCTION Crop a spike train to a specified time extent
% $Id: STCrop.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stCroppedTrain] = STCrop(stMappedTrain, tMinTime, tMaxTime)
%
% Note: STCrop will not shift the cropped spike train to zero, or fix the
% duration of the train -- see the STNormalise function for help with this.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Date: 14th May, 2004

% -- Check arguments

if (nargin > 3)
   disp('--- STCrop: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STCrop: Incorrect usage');
   help STCrop;
   return;
end

if (~STIsValidSpikeTrain(stMappedTrain))
   disp('*** STCrop: This is not a valid spike train');
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
mapping.stasSpecification = stMappedTrain.mapping.stasSpecification;

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
vbEmptyChunk = CellForEach('isempty', spikeList);
spikeList = spikeList(find(~vbEmptyChunk));

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
% Revision 2.2  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
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
% Revision 2.0  2004/07/13 12:56:31  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
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