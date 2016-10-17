% SCRIPT STAccessDefaults - Make the global options for the spike toolbox available to the user
%
% Usage: STAccessDefaults
%
% STAccessDefaults allows the user to access and modify the global parameters
% of the spike toolbox from the workspace.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% $Id: STAccessDefaults.m,v 1.1 2004/06/04 09:35:46 dylan Exp $

% -- Define the global options

global   INSTANCE_TEMPORAL_RESOLUTION MAPPING_TEMPORAL_RESOLUTION RANDOM_GENERATOR;
global   NEURON_BITS SYNAPSE_BITS SPIKE_CHUNK_LENGTH DEFAULT_CHANNEL_FILTER

% -- Create the options, if they don't already exist
STCreateDefaults;

% --- END of STAccessDefaults ---

% $Log: STAccessDefaults.m,v $
% Revision 1.1  2004/06/04 09:35:46  dylan
% Reimported (nonote)
%
% Revision 1.4  2004/05/19 08:24:11  dylan
% Added the new default DEFAULT_CHANNEL_FILTER to STAccessDefaults.  Fixed bugs (nonote)
%
% Revision 1.3  2004/05/04 09:40:06  dylan
% Added ID tags and logs to all version managed files
%