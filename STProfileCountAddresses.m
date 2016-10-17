function [vBinnedCounts, vKey] = STProfileCountAddresses(stMappedTrain, tTimeWindow)

% STProfileCountAddresses - FUNCTION Bin mapped spikes by a time window, and return the counts for each address
% $Id: STProfileCountAddresses.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [vBinnedCounts, vKey] = STProfileCountAddresses(stMappedTrain, tTimeWindow)
%
% 'stMappedTrain' is a spike train containing a mapping. 'tTimeWindow'
% specifies the duration of the time bins that spikes will be lumped into in
% seconds.
% STProfileCountAddresses will calculate the number of spikes falling into
% each time bin, and return the results in 'vBinnedCounts'.  The format of
% 'tBinnedCounts' is [time_stamp  count1  count2  ...].  'time_stamp' is a real
% value representing the median time of each bin.  'count' is the number of
% spikes falling into each bin for a particular neuron.
% 'vKey' will give the addresses corresponding to each count column in
% 'vBinnedCounts'.
%
% See STProfileFrequencyAddresses for calculating frequency profiles from
% multiplexed mapped spike trains.
% See STProfileCount for binning spike train instances.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 15th September, 2004 (from STProfileCount)
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 2)
   disp('--- STProfileCountAddresses: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STProfileCountAddresses: Incorrect usage');
   help STProfileCountAddresses;
   return;
end

% - Test that a mapping exists in the spike train
if (~FieldExists(stMappedTrain, 'mapping'))
   disp('*** STProfileCountAddresses: The spike train doesn''t contain a mapping');
   return;
end

% - Extract the mapping
mapping = stMappedTrain.mapping;

% - Extract spike lists
if (mapping.bChunkedMode)
   spikeList = mapping.spikeList;
else
   spikeList = {mapping.spikeList};
end

% - Get a list of used addresses
% - Convert spike list to real time signature format
vKey = [];
for (nChunkIndex = 1:length(spikeList))
   vKey = unique([vKey  spikeList{nChunkIndex}(:, 2)]);
   spikeList{nChunkIndex}(:, 1) = spikeList{nChunkIndex}(:, 1) .* mapping.fTemporalResolution;
end

vBinnedCounts = [];

for (nWindowIndex = 1:ceil(mapping.tDuration / tTimeWindow))
   % - Calculate time window
   tWindowMin = (nWindowIndex-1) * tTimeWindow;
   tWindowMax = nWindowIndex * tTimeWindow;
   
   vCounts = zeros(1, length(vKey));
   for (nChunkIndex = 1:length(spikeList))
      % - Get spike list
      sList = spikeList{nChunkIndex}(:, 1);
      
      % - Apply time window
      windowedSpikes = (sList >= tWindowMin) & (sList <= tWindowMax);
      sList = spikeList{nChunkIndex}(windowedSpikes, 2);
      
      % - Count spikes for different addresses
      for (nNeuronIndex = 1:length(vKey))
         vCounts(nNeuronIndex) = vCounts(nNeuronIndex) + sum(sList == vKey(nNeuronIndex));
      end
   end
   
   % - Append to spike count list
   vBinnedCounts = [vBinnedCounts;...
                    [(nWindowIndex-1) * tTimeWindow + (tTimeWindow/2), vCounts] ];
end


% --- END of STProfileCountAddresses ---
