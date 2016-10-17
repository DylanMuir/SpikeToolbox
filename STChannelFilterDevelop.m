% HELP STChannelFilterDevelop - Help on developing a spike channel filter function
%
% Channel filters are used by the STImport function to filter spike train
% channels read from the PCI-AER monitor.  This help text will assist you in
% developing your own filter functions.
%
% A channel filter function must have the folowing calling semantics:
% [spikeList] = STChannelFilter(nChannel, spikeList)
%
% A channel filter recieves a multiplexed spike list containing one or more
% input channels from the PCI-AER board monitor.  This list is in [timestamp
% address] format.  The top two bits of the 16-bit 'address' field specifies
% which channel the associated spike originates from.  The first task of the
% channel filter is to only retain spikes originating from the channel
% specified in 'nChannel'.  The commands below provide a simple method to
% accomplish this.
%
% >> maskChannel = bin2dec('1100000000000000');
% >> channel = bitshift(bitand(spikeList(:, 2), maskChannel), 14);
% >> spikeList = spikeList(find(channel == nChannel), :);
%
% The second task of the filter function is to convert the remaining address
% data into logical address format.  Different chips produce addresses with
% differing formats.  The two provided functions, STChannelFilterNeuron and
% STChannelFilterNeuronSynapse, mask the address data and interpret it
% differently.  STChannelFilterNeuron assumes the lowest n bits of the address
% contain the neuron ID, and that no synapse ID information is present.
% STChannelFilterNeuronSynapse assumes both neuron and synapse ID information
% is present.  The masking code from STChannelFilterNeuronSynapse is shown
% below.
%
% >> maskNeuronAddr = bitshift(bin2dec(sprintf('%d', ones(1, NEURON_BITS))), -SYNAPSE_BITS);
% >> maskSynapseAddr = bin2dec(sprintf('%d', ones(1, SYNAPSE_BITS)));
% >> addrNeuron = bitshift(bitand(spikeList(:, 2), maskNeuronAddr), SYNAPSE_BITS);
% >> addrSynapse = bitand(spikeList(:, 2), maskSynapseAddr);
% >> spikeList(:, 2) = STConstructLogicalAddress(addrNeuron, addrSynapse);
%
% These functions use the global settings NEURON_BITS and SYNAPSE_BITS to
% parameterise the ID fields within the address data.  These global settings
% are available for use in your custom filter functions.
%
% >> global   NEURON_BITS SYNAPSE_BITS;
% >> STCreateDefaults;
%
% Examine the code from the supplied filter functions to be sure you
% understand their function.  Also see STFormats and STConstructLogicalAddress
% to understand the required output address format.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 17th May, 2004

% $Id: STChannelFilterDevelop.m,v 1.1 2004/06/04 09:35:46 dylan Exp $

% --- END of STChannelFilterDevelop.m ---

% $Log: STChannelFilterDevelop.m,v $
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