function [stOptions] = STToolboxDefaults

% STToolboxDefaults - FUNCTION Creates the user-configurable default options for the spike toolbox
% $Id: STToolboxDefaults.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stOptions] = STToolboxDefaults
% Returns a Spike Toolbox options structure containing the default options for
% the toolbox.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

global ST_TOOLBOX_VERSION ST_OPTIONS_STRUCTURE_SIGNATURE;
STCreateGlobals;

% -- Spike toolbox options signature
stOptions.Signature = ST_OPTIONS_STRUCTURE_SIGNATURE;

% -- Spike toolbox version string
stOptions.ToolboxVersion = ST_TOOLBOX_VERSION;

% - Set the instance temporal resolution
stOptions.InstanceTemporalResolution = 0.99e-6;

% - Set the mapping temporal resolution
stOptions.MappingTemporalResolution = 1e-6;

% - Set the random number generator
stOptions.RandomGenerator = @rand;

% - Set the spike chunk size (maximum length for a spike chunk)
stOptions.SpikeChunkLength = 1024*2048;

% - Set the default window size for synchronous pair matching
stOptions.DefaultSynchWindowSize = 1e-3;

% - Set the default time window for cross-correlation analysis
stOptions.DefaultCorrWindow = 1e-3;

% - Set the default smoothing kernel for cross-correlation analysis
stOptions.DefaultCorrSmoothingKernel = 'gaussian';

% - Set the default smoothing window size factor for cross-correlation analysis
stOptions.DefaultCorrSmoothingWindowFactor = 10;

% - Set the default stimulation addressing mode
%   Default is for Elisabetta's chip
stasSpecificationOutput = STAddrSpecIgnoreSynapseNeuron(0, 4, 5, 15, 30);
stasSpecificationOutput(2).bReverse = true;
stOptions.stasDefaultOutputSpecification = stasSpecificationOutput;

% - Set the default monitoring addressing modes
%   Default is sequencer on channel 0, Elisabetta's chip on  channel 1
stasSpecificationElisabetta = STAddrSpecIgnoreSynapseNeuron(0, 0, 5);
stOptions.MonitorChannelsAddressing = {stasSpecificationOutput, stasSpecificationElisabetta, [], []};

% - Set the default channel addressing mode
%   Default is 14-bit chip ID, 2-bit channel ID
stOptions.stasMonitorChannelID = STAddrSpecChannel(14, 2);


% --- END of STToolboxDefaults.m ---

% $Log: STToolboxDefaults.m,v $
% Revision 2.3  2005/02/10 13:44:38  dylan
% * Modified STFindSynchronousPairs to use 'DefaultSynchWindowSize' for its
% toolbox default instead of 'DefaultWindowSize'.
%
% * Modified STOptions, STOptionsDescribe, STOptionsLoad and STToolboxDefaults to
% support the new DefaultSynchWindowSize option, as well as several new options
% to support cross-correlation analysis of spike trains.
%
% * Modified STCreateGlobals to set a new options structure signature.  This means
% that any saved options you have will need to be reset.
%
% Revision 2.2  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.1  2004/07/19 16:21:03  dylan
% * Major update of the spike toolbox (moving to v0.02)
%
% * Modified the procedure for retrieving and setting toolbox options.  The new
% suite of functions comprises of STOptions, STOptionsLoad, STOptionsSave,
% STOptionsDescribe, STCreateGlobals and STIsValidOptionsStruct.  Spike Toolbox
% 'factory default' options are defined in STToolboxDefaults.  Options can be
% saved as user defaults using STOptionsSave, and will be loaded automatically
% for each session.
%
% * Removed STAccessDefaults and STCreateDefaults.
%
% * Renamed STLogicalAddressConstruct, STLogicalAddressExtract,
% STPhysicalAddressContstruct and STPhysicalAddressExtract to
% STAddr<type><verb>
%
% * Drastically modified the way synapse addresses are specified for the
% toolbox.  A more generic approach is now taken, where addressing modes are
% defined by structures that outline the meaning of each bit-field in a
% physical address.  Fields can have their bits reversed, can be ignored, can
% have a description attached, and can be marked as major or minor fields.
% Any type of neuron/synapse topology can be addressed in this way, including
% 2D neuron arrays and chips with no separate synapse addresses.
%
% The following functions were created to handle this new addressing mode:
% STAddrDescribe, STAddrFilterArgs, STAddrSpecChannel, STAddrSpecCompare,
% STAddrSpecDescribe, STAddrSpecFill, STAddrSpecIgnoreSynapseNeuron,
% STAddrSpecInfo, STAddrSpecSynapse2DNeuron, STIsValidAddress, STIsValidAddrSpec,
% STIsValidChannelAddrSpec and STIsValidMonitorChannelsSpecification.
%
% This modification required changes to STAddrLogicalConstruct and Extract,
% STAddrPhysicalConstruct and Extract, STCreate, STExport, STImport,
% STStimulate, STMap, STCrop, STConcat and STMultiplex.
%
% * Removed the channel filter functions.
%
% * Modified STDescribe to handle the majority of toolbox variable types.
% This function will now describe spike trains, addressing specifications and
% spike toolbox options.  Added STAddrDescribe, STOptionsDescribe and
% STTrainDescribe.
%
% * Added an STIsValidSpikeTrain function to test the validity of a spike
% train structure.  Modified many spike train manipulation functions to use
% this feature.
%
% * Added features to Todo.txt, updated Readme.txt
%
% * Added an info.xml file, added a welcome HTML file (spike_tb_welcome.html)
% and associated images (an_spike-big.jpg, an_spike.gif)
%
