function [nSpikeIndices] = STTestSpikeRegular(tTimeTrace, fInstFreq, fRandList, fMemTau)

% STTestSpikeRegular - FUNCTION Internal spike creation test function
% $Id: STTestSpikeRegular.m 2411 2005-11-07 16:48:24Z dylan $
%
% NOT for command-line use

% Usage: [nSpikeIndices] = STTestSpikeRegular(tTimeTrace, fInstFreq <,fRandList, fMemTau>)
%
% 'tTimeTrace' is a vector of time stamps in seconds.  'fInstFreq' is a vector
% of desired instantaneous frequencies in Hz, with an element corresponding to
% each element in 'tTimeTrace'.  'fRandList' is an optional vector of random
% numbers to use for spike generation instead of generating a new random
% sequence.  If 'fRandList' is an empty matrix, it will not be used.
% 'fMemTau' is an optional argument to use in creating a non-ergodic spike
% train.  It will be used as the time constant for an exponential filtering of
% the random sequence.  If 'fMemTau' is an empty matrix, it will not be used.
%
% Note that a regular spike train does not use any random sequence for train
% generation, and so will ignore these optional arguments.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

stOptions = STOptions;
InstanceTemporalResolution = stOptions.InstanceTemporalResolution;


% -- Check arguments

if (nargin > 4)
   disp('--- STTestSpikeRegular: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STTestSpikeRegular: Incorrect usage.');
   disp('       This is an internal spike creation test function');
   help private/STTestSpikeRegular;
   help private/STSpikeCreationTestDescription;
   return;
end

% -- Determine the spike indices

nSpikeIndices = find(rem(tTimeTrace, 1 ./ fInstFreq) < InstanceTemporalResolution);    % Test for spikes

% --- END of STTestSpikeRegular.m ---
