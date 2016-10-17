function STCreateDefaults

% FUNCTION STCreateDefaults - Creates the user-configurable default options for the spike toolbox, if they don't exist
%
% Usage: STCreateDefaults
% NOT for command-line use

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% $Id: STCreateDefaults.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Spike toolbox version string
SetDefault('SPIKE_TOOLBOX_VERSION', '0.01');

% - Set the instance temporal resolution
[null, bCreated] = SetDefault('INSTANCE_TEMPORAL_RESOLUTION', '0.99e-6');   % Default is (almost) microsecond resolution
if (bCreated)
   disp('--- STSetDefaults: The temporal resolution for spike instances created by');
   disp('       the spike toolbox is now set to the default.  To change this resolution,');
   disp('       execute "global INSTANCE_TEMPORAL_RESOLUTION" at the command line.  This');
   disp('       setting can then be modified.');
   disp(' '); 
end

% - Set the mapping temporal resolution
[null, bCreated] = SetDefault('MAPPING_TEMPORAL_RESOLUTION', '1e-6');   % Default is microsecond resolution
if (bCreated)
   disp('--- STSetDefaults: The temporal resolution for mapped spike instances created by');
   disp('       the spike toolbox is now set to the default.  To change this resolution,');
   disp('       execute "global MAPPING_TEMPORAL_RESOLUTION" at the command line.  This');
   disp('       setting can then be modified.');
   disp(' ');
end

% - Set the random number generator
[null, bCreated] = SetDefault('RANDOM_GENERATOR', '@rand');   % Default is the built-in RNG
if (bCreated)
   disp('--- STSetDefaults: The random number generator used by the spike toolbox');
   disp('       is now set to the default.  To change this option, execute');
   disp('       "global RANDOM_GENERATOR" at the command line.  This setting can');
   disp('       then be modified to the handle of another function with the same calling');
   disp('       semantics as "rand".');

   % - Display a reminer about seeding
   disp(' ');
   disp('*******************************************************************');
   disp('*** Spike Toolbox: REMEMBER TO SEED THE RANDOM NUMBER GENERATOR ***');
   disp('*******************************************************************');
   disp(' ');
end

% - Set the number of bits per neuron address
[null, bCreated] = SetDefault('NEURON_BITS', '5');   % Default is five bits
if (bCreated)
   disp('--- STSetDefaults: The neuron addressing scheme for the spike toolbox');
   disp('       is now set to the default.  To change this setting, execute "global"');
   disp('       NEURON_BITS" at the command line.  The setting can then be modified.');
   disp(' ');
end

% - Set the number of bits per synapse address
[null, bCreated] = SetDefault('SYNAPSE_BITS', '4');   % Default is four bits
if (bCreated)
   disp('--- STSetDefaults: The synapse addressing scheme for the spike toolbox');
   disp('       is now set to the default.  To change this setting, execute "global"');
   disp('       SYNAPSE_BITS" at the command line.  The setting can then be modified.');
   disp(' ');
end

% - Set the spike chunk size (maximum length for a spike chunk)
[null, bCreated] = SetDefault('SPIKE_CHUNK_LENGTH', '1024*2048');   % Default is four bits
if (bCreated)
   disp('--- STSetDefaults: The spike chunk size for the spike toolbox is now set to');
   disp('       the default.  To change this setting, execute "global SPIKE_CHUNK_LENGTH"');
   disp('       at the command line.  This setting can then be modified.');
   disp(' ');
end

% - Set the default window size for synchronous pair matching
[null, bCreated] = SetDefault('DEFAULT_WINDOW_SIZE', '1e-3');  % Default is 1 msec
if (bCreated)
   disp('--- STSetDefaults: The default window size for spike pair matching is now set');
   disp('       to the default.  To change this setting, execute "global');
   disp('       DEFAULT_WINDOW_SIZE" at the command line.  This setting can then be');
   disp('       modified.');
   disp(' ');
end

% - Set the default channel filter function
[null, bCreated] = SetDefault('DEFAULT_CHANNEL_FILTER', '@STChannelFilterNeuronSynapse');  % Default is STChannelFilterNeuronSynapse
if (bCreated)
   disp('--- STSetDefaults: The default channel filter for importing from the PCI-AER');
   disp('       system is now set to the default.  To change this setting, execute "global');
   disp('       DEFAULT_CHANNEL_FILTER" at the command line.  This setting can then be');
   disp('       modified.');
   disp(' ');
end


% --- END of STCreateDefaults.m ---

% $Log: STCreateDefaults.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.5  2004/05/19 07:56:50  dylan
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
% Revision 1.4  2004/05/04 09:40:06  dylan
% Added ID tags and logs to all version managed files
%