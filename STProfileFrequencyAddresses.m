function [vInstFrequency, vKey] = STProfileFrequencyAddresses(stMappedTrain, tTimeWindow)

% STProfileFrequencyAddresses - FUNCTION Calculate a frequency profile from a mapped spike train, for each address
% $Id: STProfileFrequencyAddresses.m 3293 2006-03-01 16:40:50Z dylan $
%
% Usage: [vInstFrequency, vKey] = STProfileFrequencyAddresses(stMappedTrain, tTimeWindow)
%
% 'stTrain' is a spike train containing a mapping.
% 'tTimeWindow' specifies the duration in seconds of the time bins that spikes
% will be lumped into.  STProfileFrequency will calculate the spike train
% frequency for each bin.  These frequencies will be returned in
% 'vInstFrequency'.  The format will be [time_stamp  frequency1  frequency2 ...].
% 'time_stamp' is a real value representing the median time of each
% bin.  'frequencyN' is the average firing frequency of a single neuron
% during each time bin, in Hz. Each row in 'vKey' gives the address of the
% neuron corresponding to one of the columns in 'vInstFrequency'.  For
% example, vKey(1) is the address of the neuron corresponding to
% 'frequency1' in 'vInstFrequency'.
%
% Note that STProfileFrequencyAddresses will skip neurons with no spikes
% in 'stMappedTrain'.  Don't rely on the order of 'vKey' being
% monotonically increasing.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 16th September, 2004 (from STProfileFrequency)
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 2)
   disp('--- STProfileFrequencyAddresses: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STProfileFrequencyAddresses: Incorrect usage');
   help STProfileFrequencyAddresses;
   return;
end

% - Check for a mapping
if (~FieldExists(stMappedTrain, 'mapping'))
   disp('*** STProfileFrequencyAddresses: The spike train must contain a mapping');
end

% - Get binned counts
[vBinnedCounts, vKey] = STProfileCountAddresses(stMappedTrain, tTimeWindow);

% - Convert to frequency
vInstFrequency = [vBinnedCounts(:, 1), vBinnedCounts(:, 2:end) ./ tTimeWindow];

% --- END of STProfileFrequencyAddresses.m ---
