function [addrLog] = STConstructLogicalAddress(nNeuron, nSynapse)

% FUNCTION STConstructLogicalAddress - Build a logical address from a neuron and synapse ID
%
% Usage: [addrLog] = STConstructLogicalAddress(nNeuron, nSynapse)
%        [addrLog] = STConstructLogicalAddress([nNeuron, nSynapse])
%
% STConstructLogicalAddress will return the logical address corresponding to a
% given neuron and synapse ID provided in 'nNeuron' and 'nSynapse'.  The
% returned address will take the form |NEURON_BITS|.|SYNAPSE_BITS|
%
% STConstructLogicalAddress can accept the neuron and synapse IDs as elements
% of a row in a matrix.  STConstructLogicalAddress is also vectorised.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 9th May, 2004

% $Id: STConstructLogicalAddress.m,v 1.1 2004/06/04 09:35:46 dylan Exp $

% -- Declare globals

global   NEURON_BITS SYNAPSE_BITS;

% -- Check arguments

if (nargin > 2)
   disp('--- STConstructLogicalAddress: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STConstructLogicalAddress: Incorrect number of arguments');
   help STConstructLogicalAddress;
   return;
end

if (nargin < 2)
   if (size(nNeuron, 2) < 2)
      disp('*** STConstructLogicalAddress: At least two columns must be provided when');
      disp('       the argument is a matrix');
      return;
   end
   
   % - Extract arguments
   nSynapse = nNeuron(:, 2);
   nNeuron = nNeuron(:, 1);
end


% -- Ensure that global options exist
STCreateDefaults;


% -- Construct the address

% - Constrain addresses to correct number of bits
nNeuronAddr = bitshift(nNeuron, 0, NEURON_BITS);
nSynapseAddr = bitshift(nSynapse, 0, SYNAPSE_BITS);

% - Shift synapse address left (make fractional) and combine with neuron
% address
addrLog = nNeuronAddr + (nSynapseAddr .* 2^(-SYNAPSE_BITS));

% --- END of STConstructLogicalAddress.m ---

% $Log: STConstructLogicalAddress.m,v $
% Revision 1.1  2004/06/04 09:35:46  dylan
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