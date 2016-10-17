function [vInstFrequency, vKey] = STProfileFrequencyAddresses(stMappedTrain, tTimeWindow)

% STProfileFrequencyAddresses - FUNCTION Calculate a frequency profile from a mapped spike train, for each address
% $Id: STProfileFrequencyAddresses.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [vInstFrequency, vKey] = STProfileFrequencyAddresses(stMappedTrain, tTimeWindow)
%
% 'stTrain' is a spike train containing a mapping.
% 'tTimeWindow' specifies the duration in seconds of the time bins that spikes
% will be lumped into.  'strLevel' optionally specifies whether a spike train
% instance or mapping will be used, and must be one of {instance, mapping}.
% STProfileFrequency will calculate the spike train frequency for each bin.
% These frequencies will be returned in 'vInstFrequency'.  The format will be
% [time_stamp  frequency]. 'time_stamp' is a real value representing the median
% time of each bin.  'frequency' is the average frequency of the spike train
% during each time bin, in Hz.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 16th September, 2004 (from STProfileFrequency)

% -- Check arguments

if (nargin > 2)
   disp('--- STProfileFrequencyAddresses: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STProfileFrequencyAddresses: Incorrect usage');
   help STProfileFrequency;
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

% $Log: STProfileFrequencyAddresses.m,v $
% Revision 2.2  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.1  2004/09/16 10:22:13  dylan
% * Added two new functions, STProfileCountAddresses and
% STProfileFrequencyAddresses.  These functions handle multiplexed spike trains
% nicely, by performing separate counts for each mapped spike address.
%
% * Added help text to STProfileCount and STProfileFrequency to indicate their
% suitability only for spike train instances, and to point users to the new
% functions.
%