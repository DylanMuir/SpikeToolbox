% HELP STSpikeCreationTestDescription - Internal Spike Toolbox help file
% These functions should not be called from the command line.  They are
% designed to be called from within STInstantiate to determine when to create
% a spike.  See STInstantiate for calling syntax.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created:

% $Id: STSpikeCreationTestDescription.m,v 1.1 2004/06/04 09:35:49 dylan Exp $

% --- END of STSpikeCreationTestDescription ---

% $Log: STSpikeCreationTestDescription.m,v $
% Revision 1.1  2004/06/04 09:35:49  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/19 07:56:50  dylan
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