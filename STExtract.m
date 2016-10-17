function [stExtTrain] = STExtract(stTrain, varargin)

% STExtract - FUNCTION Extract a single spike train from a multiplexed mapping
% $Id: STExtract.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stExtTrain] = STExtract(stTrain, nAddr1, nAddr2, ...)
% Usage: [stExtTrain] = STExtract(stTrain, [nAddr1Min  nAddr1Max], [nAddr2Min  nAddr2Max], ...)
%
% 'stTrain' must contain a mapped spike train.  'nAddr...' specify neuron
% and synapse addresses to extract from 'stTrain'.  The spikes from this
% address will be returned in a new mapped spike train 'stExtTrain'.
%
% Under the second usage mode, an address range can be specified.  In this
% case, all spikes with addresses falling within the address range will be
% extracted and returned in 'stExtTrain'.  For each addressing field, a
% minimum and maximum should be supplied.  If these are the same value, only
% one is required.
%
% For example, the command
%    STExtract(stTrain, [0 5], 4)
% will extract spikes from 'stTrain', using {0 4} as the minimum address and
% {5 4} as the maximum address.
%
%    STExtract(stTrain, [0 5], [2 4])
% will extract spikes from 'stTrain', using {0 2} as the minimum address and
% {5 4} as the maximum address.
%
% Note that the addressing range applies to the logical addresses, and the
% range for each field does not apply specifically to that field.  In the
% second example above, the address {7 3} may fall with the addressing range,
% if the second field is major and the first minor.  This becomes clear when
% one considers that the minimum address may translate to '2.0' and the
% maximum to '4.8' in logical addresses.
%
% Note that the addressing specification will be taken from 'stTrain' and can
% not be overridden.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 9th May, 2004

% -- Check arguments

if (nargin < 2)
   disp('*** STExtract: Incorrect usage');
   help STExtract;
end

if (~isfield(stTrain, 'mapping'))
   disp('*** STExtract: The spike train to extract from must contain a mapping');
   return;
end

% - Check for a zero-duration spike train
if (STIsZeroDuration(stTrain))
   disp('--- STExtract: Warning: Zero-duration spike train');
   stExtTrain = stTrain;
   return;
end

% - Check addresses supplied
vAddressLengths = CellForEach(@length, varargin);
vbArrayAddresses = (vAddressLengths > 1);

% - Get addressing specification
stasSpecification = stTrain.mapping.stasSpecification;


% -- Get address range to search for

if (any(vbArrayAddresses))
   % - Use 'min' and 'max' to add a bit of leniency
   cellMinAddresses = CellForEachCell(@min, varargin);
   cellMaxAddresses = CellForEachCell(@max, varargin);
   
   % - Get the address range end points
   addrLogMin = STAddrLogicalConstruct(stasSpecification, cellMinAddresses{:});
   addrLogMax = STAddrLogicalConstruct(stasSpecification, cellMaxAddresses{:});
   
else
   % - We want to extract for a specific synapse
   addrLogMin = STAddrLogicalConstruct(stasSpecification, varargin{:});
   addrLogMax = addrLogMin;
end


% -- Extract address range

% - Copy the mapping
mapping.tDuration = stTrain.mapping.tDuration;
mapping.fTemporalResolution = stTrain.mapping.fTemporalResolution;
mapping.bChunkedMode = stTrain.mapping.bChunkedMode;
if (mapping.bChunkedMode)
   mapping.nNumChunks = stTrain.mapping.nNumChunks;
end

% - Copy the addressing information
mapping.stasSpecification = stasSpecification;

if (~any(vbArrayAddresses))
   % - Assign a specific synapse logical address to the mapping
   mapping.addrFields = varargin;
   mapping.addrSynapse = addrLogMin;
end

% - Extract the spike list
if (mapping.bChunkedMode)
   spikeList = stTrain.mapping.spikeList;
   nNumChunks = mapping.nNumChunks;
else
   spikeList = {stTrain.mapping.spikeList};
   nNumChunks = 1;
end

% - Filter the spike list
for (nChunkIndex = 1:nNumChunks)
   rawSpikeList = spikeList{nChunkIndex};
   matchingSpikes = (rawSpikeList(:, 2) >= addrLogMin) & (rawSpikeList(:, 2) <= addrLogMax);
   spikeList{nChunkIndex} = rawSpikeList(find(matchingSpikes), :);
end

% - Reassign the spike list
if (mapping.bChunkedMode)
   mapping.spikeList = spikeList;
else
   mapping.spikeList = spikeList{1};
end
   
% - Assign the mapping to a new spike train
stExtTrain.mapping = mapping;

% --- END of STExtract.m ---

% $Log: STExtract.m,v $
% Revision 2.6  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.5  2004/09/04 11:33:19  dylan
% Bug in STExtract (nonote)
%
% Revision 2.4  2004/09/04 11:20:48  dylan
% STExtract now checks and handles zero-duration spike trains.
%
% Revision 2.3  2004/09/02 08:23:18  dylan
% * Added a function STIsZeroDuration to test for zero duration spike trains.
%
% * Modified all functions to use this test rather than custom tests.
%
% Revision 2.2  2004/09/01 12:14:01  dylan
% Updated STExtract to use the 0.02 addressing scheme.
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