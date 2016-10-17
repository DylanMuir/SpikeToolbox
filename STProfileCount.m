function [vBinnedCounts] = STProfileCount(stTrain, tTimeWindow, strLevel)

% STProfileCount - FUNCTION Bin spikes by a time window, and return the counts
% $Id: STProfileCount.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [vBinnedCounts] = STProfileCount(stTrain, tTimeWindow)
%        [vBinnedCounts] = STProfileCount(stTrain, tTimeWindow, strLevel)
%
% 'stTrain' is a spike train containing either an instance or a mapping.
% 'tTimeWindow' specifies the duration in seconds of the time bins that spikes
% will be lumped into.  'strLevel' optionally specifies whether a spike train
% instance or mapping will be used, and must be one of {instance, mapping}.
% STProfileCount will calculate the number of spikes falling into each time
% bin, and return the results in 'vBinnedCounts'.  The format of
% 'tBinnedCounts' is [time_stamp  count].  'time_stamp' is a real value
% representing the median time of each bin.  'count' is the number of spikes
% falling into each bin.
%
% See STProfileFrequency for calculating binned instantaneous frequencies.
% See STProfileCountAddresses for binning spikes from multiplexed mappings.
% Note that STProfileCount will count spikes irrespective of individual
% addresses.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 29th April, 2004

% -- Check arguments

if (nargin > 3)
   disp('--- STProfileCount: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STProfileCount: Incorrect usage');
   help STProfileCount;
   return;
end

% - Test for a zero-duration spike train
if (STIsZeroDuration(stTrain))
   warning('SpikeToolbox:ZeroDuration', 'STProfileCount: Zero-duration spike train.');
   vBinnedCounts = [0 0];
   return;
end


% -- Which spike train level should we try to count?

if (exist('strLevel'))
   % - The user wants to tell us
   switch lower(strLevel)
      case {'mapping', 'm'}
         if (~isfield(stTrain, 'mapping'))
            disp('*** STProfileCount: To count mappings, a mapping must exist in the spike train');
         else
            vBinnedCounts = STProfileCountNode(stTrain.mapping, tTimeWindow, true);
         end
         
      case {'instance', 'i'}
         if (~isfield(stTrain, 'instance'))
            disp('*** STProfileCount: To count instances, an instance must exist in the spike train');
         else
            vBinnedCounts = STProfileCountNode(stTrain.instance, tTimeWindow, false);
         end
         
      otherwise
         SingleLinePrintf('*** STProfileCount: Unknown train level [%s].\n', strLevel);
         disp('       strLevel must be one of {mapping, instance}');
   end
   
else
   % - We should try to work it out ourselves
   % - Try mappings first
   if (isfield(stTrain, 'mapping'))
      vBinnedCounts = STProfileCountNode(stTrain.mapping, tTimeWindow, true);
      
   elseif (isfield(stTrain, 'instance'))
      vBinnedCounts = STProfileCountNode(stTrain.instance, tTimeWindow, false);
      
   else
      disp('*** STProfileCount: The spike train must contain either an instance or a mapping');
   end
end


% --- FUNCTION STProfileCountNode

function [vBinnedCounts] = STProfileCountNode(stNode, tTimeWindow, bIsMapping)

% - Extract spike lists
if (stNode.bChunkedMode)
   spikeList = stNode.spikeList;
else
   spikeList = {stNode.spikeList};
end

vBinnedCounts = [];

for (nWindowIndex = 1:ceil(stNode.tDuration / tTimeWindow))
   % - Calculate time window
   tWindowMin = (nWindowIndex-1) * tTimeWindow;
   tWindowMax = nWindowIndex * tTimeWindow;
   
   nNumSpikes = 0;
   for (nChunkIndex = 1:length(spikeList))
      % - Get spike list
      sList = spikeList{nChunkIndex}(:, 1);
      
      if (bIsMapping)
         % - Convert to real time signature format
         sList = sList .* stNode.fTemporalResolution;
      end
      
      % - Apply time window
      windowedSpikes = (sList >= tWindowMin) & (sList <= tWindowMax);
      nNumSpikes = nNumSpikes + sum(windowedSpikes);
   end
   
   % - Append to spike count list
   vBinnedCounts = [vBinnedCounts;...
                    [(nWindowIndex-1) * tTimeWindow + (tTimeWindow/2), nNumSpikes] ];
end


% --- END of STProfileCount ---

% $Log: STProfileCount.m,v $
% Revision 2.6  2005/02/20 13:15:08  dylan
% Modified STMap, STMultiplex, STProfileFrequency and STProfileCount to use the
% MATLAB warning system when warning about zero-duration spike trains.  These
% warnings can now be turned off using the built-in WARNING function.  The message
% ID for these warnings (and for the rest of the toolbox as well) will be
% 'SpikeToolbox:ZeroDuration'.
%
% Revision 2.5  2005/02/19 18:10:22  dylan
% STProfileCount and STProfileFrequency now check for zero-duration spike trains.
%
% Revision 2.4  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.3  2004/09/16 10:22:13  dylan
% * Added two new functions, STProfileCountAddresses and
% STProfileFrequencyAddresses.  These functions handle multiplexed spike trains
% nicely, by performing separate counts for each mapped spike address.
%
% * Added help text to STProfileCount and STProfileFrequency to indicate their
% suitability only for spike train instances, and to point users to the new
% functions.
%
% Revision 2.2  2004/09/01 12:15:28  dylan
% Updated several functions to use if (any(... instead of if (max(...
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
