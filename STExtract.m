function [stExtTrain] = STExtract(stTrain, nNeuron, nSynapse)

% FUNCTION STExtract - Extract a single spike train from a multiplexed mapping
%
% Usage: [stExtTrain] = STExtract(stTrain, nNeuron)
%        [stExtTrain] = STExtract(stTrain, nNeuron, nSynapse)
%
% 'stTrain' must contain a mapped spike train.  'nNeuron' (and optionally
% 'nSynapse') specify IDs to filter from the multiplexed train 'stTrain'.
% 'stExtTrain' will contain a mapped spike train extracted from 'stTrain',
% with the IDs specified by 'nNeuon' and 'nSynapse'.  If 'nSynapse' is not
% specified, all trains sent to a particular neuron will be extracted.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 9th May, 2004

% $Id: STExtract.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Check arguments

if (nargin > 3)
   disp('--- STExtract: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STExtract: Incorrect usage');
   help STExtract;
end

if (~isfield(stTrain, 'mapping'))
   disp('*** STExtract: The spike train to extract from must contain a mapping');
   return;
end


% -- Get address range to search for

if (nargin < 3)
   % - We want to extract for all synapses on a given neuron
   addrLogMin = STConstructLogicalAddress(nNeuron, 0);
   addrLogMax = addrLogMin + 1;
else
   % - We want to extract for a specific synapse
   addrLogMin = STConstructLogicalAddress(nNeuron, nSynapse);
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

mapping.nNeuron = nNeuron;

if (nargin > 2)
   % - Assign a specific synapse logical address to the mapping
   mapping.nSynapse = nSynapse;
   mapping.addrSynapse = STConstructLogicalAddress(nNeuron, nSynapse);
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