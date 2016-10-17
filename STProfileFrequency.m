function [vInstFrequency] = STProfileFrequency(stTrain, tTimeWindow, strLevel)

% STProfileFrequency - FUNCTION Calculate a frequency profile from a spike train
% $Id: STProfileFrequency.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [vInstFrequency] = STProfileFrequency(stTrain, tTimeWindow)
%        [vInstFrequency] = STProfileFrequency(stTrain, tTimeWindow, strLevel)
%
% 'stTrain' is a spike train with either an instance or a mapping.
% 'tTimeWindow' specifies the duration in seconds of the time bins that spikes
% will be lumped into.  'strLevel' optionally specifies whether a spike train
% instance or mapping will be used, and must be one of {instance, mapping}.
% STProfileFrequency will calculate the spike train frequency for each bin.
% These frequencies will be returned in 'vInstFrequency'.  The format will be
% [time_stamp  frequency]. 'time_stamp' is a real value representing the median
% time of each bin.  'frequency' is the average frequency of the spike train
% during each time bin, in Hz.
%
% See STProfileCount for basic spike binning.
% See STProfileFrequencyAddresses for profiling spikes from multiplexed mapped
% spike trains.
% Note that STProfileFrequency will calculate frequencies using spikes
% irrespective of their source or target address.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 29th April, 2004

% -- Check arguments

if (nargin > 3)
   disp('--- STProfileFrequency: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STProfileFrequency: Incorrect usage');
   help STProfileFrequency;
   return;
end

% - Test for a zero-duration spike train
if (STIsZeroDuration(stTrain))
   warning('SpikeToolbox:ZeroDuration','STProfileFrequency: Zero-duration spike train.');
   vInstFrequency = [0 0];
   return;
end


% -- Get binned counts

if (exist('strLevel') == 1)
   vBinnedCounts = STProfileCount(stTrain, tTimeWindow, strLevel);
else
   vBinnedCounts = STProfileCount(stTrain, tTimeWindow);
end


% -- Convert to frequency

vInstFrequency = [vBinnedCounts(:, 1), vBinnedCounts(:, 2) ./ tTimeWindow];

% --- END of STProfileFrequency.m ---

% $Log: STProfileFrequency.m,v $
% Revision 2.5  2005/02/20 13:15:08  dylan
% Modified STMap, STMultiplex, STProfileFrequency and STProfileCount to use the
% MATLAB warning system when warning about zero-duration spike trains.  These
% warnings can now be turned off using the built-in WARNING function.  The message
% ID for these warnings (and for the rest of the toolbox as well) will be
% 'SpikeToolbox:ZeroDuration'.
%
% Revision 2.4  2005/02/19 18:10:22  dylan
% STProfileCount and STProfileFrequency now check for zero-duration spike trains.
%
% Revision 2.3  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.2  2004/09/16 10:22:13  dylan
% * Added two new functions, STProfileCountAddresses and
% STProfileFrequencyAddresses.  These functions handle multiplexed spike trains
% nicely, by performing separate counts for each mapped spike address.
%
% * Added help text to STProfileCount and STProfileFrequency to indicate their
% suitability only for spike train instances, and to point users to the new
% functions.
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
% Revision 2.0  2004/07/13 12:56:32  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
% Revision 1.1  2004/06/04 09:35:48  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%
