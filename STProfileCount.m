function [vBinnedCounts] = STProfileCount(stTrain, tTimeWindow, strLevel)

% FUNCTION STProfileCount - Bin spikes by a time window, and return the counts
%
% Usage: [vBinnedCounts] = STProfileCount(stTrain, tTimeWindow)
%        [vBinnedCounts] = STProfileCount(stTrain, tTimeWindow, strLevel)
%
% 'stTrain' is a spike train containing either an instance or a mapping.
% 'tTimeWindow' specifies the duration of the time bins that spikes will be
% lumped into.  'strLevel' optionally specifies whether a spike train instance
% or mapping will be used, and must be one of {instance, mapping}.
% STProfileCount will calculate the number of spikes falling into each time
% bin, and return the results in 'vBinnedCounts'.  The format of
% 'tBinnedCounts' is [time_stamp  count].  'time_stamp' is a real value
% representing the median time of each bin.  'count' is the number of spikes
% falling into each bin.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 29th April, 2004

% $Id: STProfileCount.m,v 1.1 2004/06/04 09:35:48 dylan Exp $

% -- Check arguments

if (nargin > 3)
   disp('--- STProfileCount: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STProfileCount: Incorrect usage');
   help STProfileCount;
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
% Revision 1.1  2004/06/04 09:35:48  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%