function [spikeList] = STChannelFilterNeuronSynapse(nChannel, spikeList)

% FUNCTION STChannelFilterNeuronSynapse - Internal channel filter function
%
% Usage: [spikeList] = STChannelFilterNeuronSynapse(nChannel, spikeList)
%
% This function is used with STImport to filter a spike train channel imported
% from the PCI-AER monitor.  It will create a mask using the address format
% |NEURON_BITS|SYNAPSE_BITS|, and will use the Spike Toolbox global defaults
% for these values.  See STAccessDefaults for information on how to change
% these values.  See STImport for usage syntax for this function.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 17th May, 2004

% $Id: STChannelFilterNeuronSynapse.m,v 1.1 2004/06/04 09:35:46 dylan Exp $

% -- Declare globals
global   NEURON_BITS SYNAPSE_BITS;
STCreateDefaults;


% -- Check arguments

if (nargin > 2)
   disp('--- STChannelFilterNeuronSynapse: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STChannelFilterNeuronSynapse: Incorrect usage');
   help STChannelFiltersDescription;
   return;
end


% -- Create masks

maskChannel = bin2dec('1100000000000000');
maskNeuronAddr = bitshift(bin2dec(sprintf('%d', ones(1, NEURON_BITS))), SYNAPSE_BITS);
maskSynapseAddr = bin2dec(sprintf('%d', ones(1, SYNAPSE_BITS)));


% -- Filter the channel

channel = bitshift(bitand(spikeList(:, 2), maskChannel), -14);
spikeList = spikeList(find(channel == nChannel), :);

addrNeuron = bitshift(bitand(spikeList(:, 2), maskNeuronAddr), -SYNAPSE_BITS);
addrSynapse = bitand(spikeList(:, 2), maskSynapseAddr);

spikeList(:, 2) = STConstructLogicalAddress(addrNeuron, addrSynapse);

% --- END of STChannelFilterNeuronSynapse ---

% $Log: STChannelFilterNeuronSynapse.m,v $
% Revision 1.1  2004/06/04 09:35:46  dylan
% Reimported (nonote)
%
% Revision 1.1  2004/05/19 07:57:12  dylan
% * Modified the syntax of STImport -- STImport now uses an updated version
% of stimmon, which acquires data from all four PCI-AER channels.  STImport
% now imports to a cell array of spike trains, one per channel imported.
% Which channels to import can be specified through the calling syntax.
% * STImport uses channel filter functions to handle different addressing
% formats on the AER bus.  Added two standard filter functions:
% STChannelFilterNeuron and STChannelFilterNeuronSynapse.  Added help files
% for this functionality: STChannelFiltersDescription,
% STChannelFilterDevelop
%