function [stFlatTrain] = STFlatten(stTrain)

% FUNCTION STFlatten - Convert a mapped spike train back to an instance
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

% $Id: STFlatten.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

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
if (~isfield(stTrain, 'mapping'))
   disp('*** STFlatten: The spike train to flatten must contain a mapping');
   return;
end

% -- Handle a zero-duration spiketrain
if (stTrain.mapping.tDuration == 0)
	disp('--- STFlatten: Warning: zero-duration spiketrain');
	instance.tDuration = 0;
	instance.bChunkedMode = false;
	instance.fTemporalResolution = stTrain.mapping.fTemporalResolution;
	instance.spikeTrain = [];
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
