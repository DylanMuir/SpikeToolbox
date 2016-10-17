function [addrPhys] = STConstructPhysicalAddress(nNeuron, nSynapse)

% FUNCTION STConstructPhysicalAddress - Determine a synapse physical address
%
% Usage: [addrPhys] = STConstructPhysicalAddress(nNeuron, nSynapse)
%        [addrPhys] = STConstructPhysicalAddress([nNeuron nSynapse])
%
% STConstructPhysicalAddress returns the hex address of a particular
% synapse, as determined by the NEURON_BITS and SYNAPSE_BITS global
% parameters.  An address takes the form |NEURON_ADDRESS|SYNAPSE_ADDRESS|.
%
% nNeuron and nSynapse can be provided as the elements in a row of a matrix.
% STConstructPhysicalAddress is also vectorised.
%
% NOTE: STConstructPhysicalAddress uses the floor of nNeuron and nSynapse

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 1st April, 2004 (no, really)

% $Id: STConstructPhysicalAddress.m,v 1.1 2004/06/04 09:35:46 dylan Exp $

% -- Declare globals

global NEURON_BITS SYNAPSE_BITS;


% -- Check arguments

if (nargin > 2)
   disp('--- STConstructPhysicalAddress: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STConstructPhysicalAddress: Incorrect number of arguments');
   help STConstructPhysicalAddress;
   return;
end

if (nargin < 2)
   if (size(nNeuron, 2) < 2)
      disp('*** STConstructPhysicalAddress: At least two columns must be provided when');
      disp('       the argument is a matrix');
      return;
   end
   
   % - Extract arguments
   nSynapse = nNeuron(:, 2);
   nNeuron = nNeuron(:, 1);
end


% -- Check that defaults exist

STCreateDefaults;


% -- Construct the address

addrPhys = bitshift(floor(nNeuron), SYNAPSE_BITS, NEURON_BITS + SYNAPSE_BITS) ...
               + bitshift(floor(nSynapse), 0, SYNAPSE_BITS);
            
            
% --- END of STConstructPhysicalAddress.m ---
 
% $Log: STConstructPhysicalAddress.m,v $
% Revision 1.1  2004/06/04 09:35:46  dylan
% Reimported (nonote)
%
% Revision 1.2  2004/05/25 10:51:05  dylan
% Bug fixes (nonote)
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