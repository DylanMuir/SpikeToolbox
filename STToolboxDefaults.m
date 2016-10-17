function [stOptions] = STToolboxDefaults

% STToolboxDefaults - FUNCTION Creates the user-configurable default options for the spike toolbox
% $Id: STToolboxDefaults.m 11393 2009-04-02 13:48:59Z dylan $
%
% Usage: [stOptions] = STToolboxDefaults
% Returns a Spike Toolbox options structure containing the default options for
% the toolbox.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

global ST_TOOLBOX_VERSION ST_OPTIONS_STRUCTURE_SIGNATURE;
STCreateGlobals;

% -- Spike toolbox options signature
stOptions.Signature = ST_OPTIONS_STRUCTURE_SIGNATURE;

% -- Spike toolbox version string
stOptions.ToolboxVersion = ST_TOOLBOX_VERSION;

% - Set the progress flag
stOptions.bDisplayProgress = true;

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
%   Default is sequencer on channel 0, Elisabetta's chip on channel 1
stasSpecificationElisabetta = STAddrSpecIgnoreSynapseNeuron(0, 0, 5);
stOptions.MonitorChannelsAddressing = {stasSpecificationOutput, stasSpecificationElisabetta, [], []};

% - Set the default channel addressing mode
%   Default is 14-bit chip ID, 2-bit channel ID
stOptions.stasMonitorChannelID = STAddrSpecChannel(14, 2);

% - Set the default logical-hardware address translator function
stOptions.fhHardwareAddressConstruction = @STAddrPhysicalConstruct;

% - Set the default hardware-logical address translator function
stOptions.fhHardwareAddressExtraction = @STAddrPhysicalExtract;

% --- END of STToolboxDefaults.m ---
