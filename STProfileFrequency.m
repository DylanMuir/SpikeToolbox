function [vInstFrequency] = STProfileFrequency(stTrain, tTimeWindow, strLevel)

% FUNCTION STProfileFrequency - Calculate a frequency profile from a spike train
%
% Usage: [vInstFrequency] = STProfileFrequency(stTrain, tTimeWindow)
%        [vInstFrequency] = STProfileFrequency(stTrain, tTimeWindow, strLevel)
%
% 'stTrain' is a spike train with either an instance or a mapping.
% 'tTimeWindow' specifies the duration of the time bins that spikes will be
% lumped into.  'strLevel' optionally specifies whether a spike train instance
% or mapping will be used, and must be one of {instance, mapping}.
% STProfileFrequency will calculate the spike train frequency for each bin.
% These frequencies will be returned in 'vInstFrequency'.  The format will be
% [time_stamp  frequency]. 'time_stamp' is a real value representing the median
% time of each bin.  'frequency' is the average frequency of the spike train
% during each time bin, in Hz.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 29th April, 2004

% $Id: STProfileFrequency.m,v 1.1 2004/06/04 09:35:48 dylan Exp $

% -- Check arguments

if (nargin > 3)
   disp('--- STProfileFrequency: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STProfileFrequency: Incorrect usage');
   help STProfileFrequency;
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
% Revision 1.1  2004/06/04 09:35:48  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%