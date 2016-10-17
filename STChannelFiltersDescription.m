% HELP STChannelFiltersDescription - Internal Spike Toolbox help file
% These functions are not designed to be called from the command line.  They
% are called by STImport to filter a spike channel read from teh PCI-AER
% monitor.  See STImport for usage syntax for these functions.
%
% For hints on developing your own filter function, type
% 'help STChannelFilterDevelop' at the matlab command line.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Date: 17th May, 2004

% $Id: STChannelFiltersDescription.m,v 1.1 2004/06/04 09:35:46 dylan Exp $

% --- END of STChannelFiltersDescription ---

% $Log: STChannelFiltersDescription.m,v $
% Revision 1.1  2004/06/04 09:35:46  dylan
% Reimported (nonote)
%
% Revision 1.1  2004/05/19 07:57:13  dylan
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