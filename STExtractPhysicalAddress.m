function [nNeuron, nSynapse] = STExtractPhysicalAddress(addr)

% FUNCTION STExtractPhysicalAddress - Extract the neuron and synapse IDs from a physical address
%
% Usage: [nNeuron, nSynapse] = STExtractPhysicalAddress(addrPhys)
%
% 'addrPhys' should be a physcial address as constructed by
% STConstructPhysicalAddress.  STExtractPhyscialAddress will extract the
% neuron and synapse IDs, which will be returned in 'nNeuron' and 'nSynapse'.
% STExtractPhysicalAddress is vectorised.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 9th May, 2004

% $Id: STExtractPhysicalAddress.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Declare globals

global   NEURON_BITS SYNAPSE_BITS;

% -- Check arguments

if (nargin > 1)
   disp('--- STExtractPhysicalAddress: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STExtractPhysicalAddress: Incorrect usage');
   help STExtractPhysicalAddress;
   return;
end

% -- Ensure that global options exist
STCreateDefaults;

% -- Create masks

maskNeuronAddr = bitshift(bin2dec(sprintf('%d', ones(1, NEURON_BITS))), SYNAPSE_BITS);
maskSynapseAddr = bin2dec(sprintf('%d', ones(1, SYNAPSE_BITS)));


% -- Extract addresses

nNeuron = bitshift(bitand(addr, maskNeuronAddr), -SYNAPSE_BITS);
nSynapse = bitand(addr, maskSynapseAddr);


% --- END of STExtractPhysicalAddress.m ---

% $Log: STExtractPhysicalAddress.m,v $
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