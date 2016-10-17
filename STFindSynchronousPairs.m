function [stPairs] = STFindSynchronousPairs(stTrain1, stTrain2, tWindowSize, strLevel)

% STFindSynchronousPairs - FUNCTION Identify synchronous spikes in spike trains
% $Id: STFindSynchronousPairs.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stPairs] = STFindSynchronousPairs(stTrain1, stTrain2)
%        [stPairs] = STFindSynchronousPairs(stTrain1, stTrain2, tWindowSize)
%        [stPairs] = STFindSynchronousPairs(stTrain1, stTrain2, tWindowSize, strLevel)
%        [stPairs] = STFindSynchronousPairs(stTrainArray)
%        [stPairs] = STFindSynchronousPairs(stTrainArray, tWindowSize)
%        [stPairs] = STFindSynchronousPairs(stTrainArray, tWindowSize, strLevel)
%
% 'stPairs' will contain a spike train instance, each spike of which
% represents a spike in 'stTrain1' that had a corresponding spike in
% 'stTrain2' that falls within the specified time window.  If 'tWindowSize' is
% not supplied, the toolbox option DefaultWindowSize will be used.  To
% change this setting, see STOptions.
%
% 'strLevel' can optionally be provided to specify a spike train level to
% match, and should be one of {'instance', 'mapping'}.
%
% STFindSynchronousPairs can accept a cell array of spike trains.  In this
% case, the matching result from the first two trains will be repeatedly
% matched through the remaining trains.  For example, the first two trains
% will be matched, then this result will be matched with the third train, and
% so on.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 28th April, 2004

% -- Get options

stOptions = STOptions;


% -- Check arguments

if ((nargin > 1) & iscell(stTrain1))
   % - The user has supplied a cell array of spike trains
   if (nargin > 3)
      disp('--- STFindSynchronousPairs: Extra arguments ignored');
   end
   
   % - Extract the 'strLevel' argument
   if (nargin > 2)
      strLevel = tWindowSize;
   end
   
   % - Extract the 'tWindowSize' argument
   if (nargin > 1)
      tWindowSize = stTrain2;
   else
      tWindowSize = stOptions.DefaultSynchWindowSize;
      disp(sprintf('--- STFindSynchronousPairs: Using default window size [%.2f] msec', tWindowSize / 1e-3));
   end
   
else  % The user hasn't supplied a cell array or spike trains
   if (nargin > 4)
      disp('--- STFindSynchronousPairs: Extra arguments ignored');
   end

   if (~exist('tWindowSize'))
      tWindowSize = stOptions.DefaultWindowSize;
      disp(sprintf('--- STFindSynchronousPairs: Using default window size [%.2f] msec', tWindowSize / 1e-3));
   end
end


% -- Handle cell array of spike trains

if (iscell(stTrain1))
   % - Do we have at least two spike trains?
   if ~(length(stTrain1) >= 2)
      disp('*** STFindSynchronousPairs: I need at least two spike trains!');
      return;
   end
   
   % - Show some status
   fprintf(1, 'Spike train [%02d/%02d]', 2, length(stTrain1));
   
   % - Get the first set of pairs
   if (exist('strLevel') == 1)
      stPairs = STFindSynchronousPairs(stTrain1{1}, stTrain2{2}, tWindowSize, strLevel);
   else
      stPairs = STFindSynchronousPairs(stTrain1{1}, stTrain2{2}, tWindowSize);
   end
   
   % - Loop over the remaining trains (won't get executed if length(stTrain1) < 3
   for (nTrainIndex = 3:length(stTrain1))
      if (exist('strLevel') == 1)
         stPairs = STFindSynchronousPairs(stPairs, stTrain{nTrainIndex}, strLevel);
      else
         stPairs = STFindSynchronousPairs(stPairs, stTrain{nTrainIndex});
      end
      
      fprintf(1, '\b\b\b\b\b\%02d/%02d]', nTrainIndex, length(stTrain1));         
   end
   
   fprintf(1, '\n');
   
   return;
end


% -- Handle non-cell array spike trains

% -- Which spike train level should we try to match?

if (exist('strLevel') == 1)
   % - The user supplied a spike train level, so verify it
   [strLevel, bNotExisting, bInvalidLevel] = STFindMatchingLevel(stTrain1, stTrain2, strLevel);
   
   if (bNotExisting)
      % - The supplied level doesn't exist in one or both spike trains
      SingleLinePrinf('*** STFindSynchronousPairs: To match [%s], [%s] must exist in each spike train.', strLevel, strLevel);
      return;
   end
   
   if (bInvalidLevel | strcmp(strLevel, 'definition'))
      % - The user supplied an invalid spike train level
      SingleLinePrintf('*** STFindSynchronousPairs: Invalid spike train level [%s].', strLevel);
      disp('       strLevel must be one of {instance, mapping}');
      return;
   end

else  % - Determine a spike train level we can use
   [strLevel, bNoMatching] = STFindMatchingLevel(stTrain1, stTrain2);
   
   if (bNoMatching)
      % - There is no consistent spike train level
      disp('*** STFindSynchronousPairs: To match trains, either a mapping or an instance must');
      disp('       exist in both spike trains');
      return;
   end
end
   
% - Match nodes
switch lower(strLevel)   
   case {'mapping', 'm'}
      stPairs = STFindSynchronousPairsNodes(stTrain1.mapping, stTrain2.mapping, tWindowSize, true);
      
   case {'instance', 'i'}
      stPairs = STFindSynchronousPairsNodes(stTrain1.instance, stTrain2.instance, tWindowSize, false);
      
   otherwise
      disp('*** STConcat: This error should never occur!');
end



% --- FUNCTION STFindSynchronousPairsNodes

function [stPairs] = STFindSynchronousPairsNodes(node1, node2, tWindowSize, bIsMapping)

nodeMatch = [];
nodeMatch.bChunkedMode = node1.bChunkedMode;
nodeMatch.nNumChunks = node1.nNumChunks;
nodeMatch.tDuration = node1.tDuration;

% - Make sure the nodes share a common temporal resolution
nodeMatch.fTemporalResolution = node1.fTemporalResolution;

% -- Extract the spikelists
if (node1.bChunkedMode)
   spikeList1 = node1.spikeList;
else
   spikeList1 = {node1.spikeList};
end

if (node2.bChunkedMode)
   spikeList2 = node2.spikeList;
else
   spikeList2 = {node2.spikeList};
end


% -- Match the spikelists

for (nChunkIndex1 = 1:length(spikeList1))
   spikeTime1 = spikeList1{nChunkIndex1}(:, 1);
   
   if (bIsMapping)
      % - Convert to time signature format
      spikeTime1 = spikeTime1 .* node1.fTemporalResolution;
   end
   
   chunkMatches = [];
   
   for (nChunkIndex2 = 1:length(spikeList2))
      % - Get list of spike times from spike list 2
      spikeTime2 = spikeList2{nChunkIndex2}(:, 1);
      
      if (bIsMapping)
         % - Convert to time signature format
         spikeTime2 = spikeTime2 .* node2.fTemporalResolution;
      end
      
      % - Make sure both spike lists are the same length
      % - Pad the shorter list with NaNs
      spikeTime2 = [spikeTime2; nan * ones(length(spikeTime1) - length(spikeTime2), 1)];
      spikeTime1 = [spikeTime1; nan * ones(length(spikeTime2) - length(spikeTime1), 1)];

      % - Get the min and max time windows
      minTime = spikeTime1 - (tWindowSize/2);
      maxTime = spikeTime1 + (tWindowSize/2);
      
      for (nListIndex2 = 1:length(spikeTime2))
         % - Get a shifted version of the spike times from spike train 2
         spikeSearch2 = [spikeTime2(nListIndex2:length(spikeTime2));...
                         spikeTime2(1:nListIndex2-1)];
         
         % - Match the times with spike train 1
         chunkMatches = [chunkMatches;...
                         spikeTime1(find((spikeSearch2 >= minTime) & (spikeSearch2 <= maxTime)))];
      end
   end
   
   % - Only keep unique matches
   nodeMatch.spikeList{nChunkIndex1} = unique(chunkMatches);
end


% - Assign the instance
stPairs.instance = nodeMatch;

% --- END of STFindSynchronousPairs.m ---

% $Log: STFindSynchronousPairs.m,v $
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
% Revision 2.2  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.1  2004/07/19 16:21:02  dylan
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
% Revision 2.0  2004/07/13 12:56:31  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.5  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%
