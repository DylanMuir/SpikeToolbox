function [nNeuron, nSynapse] = STExtractLogicalAddress(addrLog)

% FUNCTION STExtractLogicalAddress - Extract the neuron and synapse IDs from a logical address
%
% Usage: [nNeuron, nSynapse] = STExtractLogicalAddress(addrLog)
%
% 'addrLog' should be a logical address as constructed by
% STConstructLogicalAddress.  STExtractLogicalAddress will extract the
% neuron and synapse IDs, which will be returned in 'nNeuron' and 'nSynapse'.
% STExtractPhysicalAddress is vectorised.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 9th May, 2004

% $Id: STExtractLogicalAddress.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Declare globals

global   NEURON_BITS SYNAPSE_BITS;


% -- Check arguments

if (nargin > 1)
   disp('--- STExtractLogicalAddress: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STExtractLogicalAddress: Incorrect usage');
   help STExtractLogicalAddress;
   return;
end

% -- Ensure that global options exist
STCreateDefaults;


% -- Extract the IDs

nNeuron = fix(addrLog);
nSynapse = (addrLog - fix(addrLog)) .* 2 ^ SYNAPSE_BITS;


% --- END of STExtractLogicalAddress.m ---

% $Log: STExtractLogicalAddress.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
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