function [vInstFrequency] = STProfileFrequency(stTrain, tTimeWindow, strLevel)

% STProfileFrequency - FUNCTION Calculate a frequency profile from a spike train
% $Id: STProfileFrequency.m 3987 2006-05-09 13:38:38Z dylan $
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
% Copyright (c) 2004, 2005 Dylan Richard Muir

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

if (exist('strLevel', 'var') == 1)
   vBinnedCounts = STProfileCount(stTrain, tTimeWindow, strLevel);
else
   vBinnedCounts = STProfileCount(stTrain, tTimeWindow);
end


% -- Convert to frequency

vInstFrequency = [vBinnedCounts(:, 1), vBinnedCounts(:, 2) ./ tTimeWindow];

% --- END of STProfileFrequency.m ---
