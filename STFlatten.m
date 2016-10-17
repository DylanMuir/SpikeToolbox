function [stFlatTrain] = STFlatten(stTrain)

% STFlatten - FUNCTION Convert a mapped spike train back to an instance
% $Id: STFlatten.m 124 2005-02-22 16:34:38Z dylan $
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

% $Log: STFlatten.m,v $
% Revision 2.4  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.3  2004/09/02 08:40:44  dylan
% Fixed a bug in STFlatten.  Invalid Zero-duration spike trains would be created.
%
% Revision 2.2  2004/09/02 08:23:18  dylan
% * Added a function STIsZeroDuration to test for zero duration spike trains.
%
% * Modified all functions to use this test rather than custom tests.
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
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/10 08:37:17  dylan
% Bug fixes
%
% Revision 1.2  2004/05/10 08:26:44  dylan
% Bug fixes
%
% Revision 1.1  2004/05/09 17:55:15  dylan
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
