function [nSpikeIndices] = STTestSpikePoisson(tTimeTrace, fInstFreq, fRandList, fMemTau)

% STTestSpikePoisson - FUNCTION Internal spike creation test function
% $Id: STTestSpikePoisson.m 7737 2007-10-05 13:54:24Z dylan $
%
% NOT for command-line use

% Usage: [nSpikeIndices] = STTestSpikePoisson(tTimeTrace, fInstFreq <,fRandList, fMemTau>)
%
% 'tTimeTrace' is a vector of time stamps in seconds.  'fInstFreq' is a vector
% of desired instantaneous frequencies in Hz, with an element corresponding to
% each element in 'tTimeTrace'.  'fRandList' is an optional vector of random
% numbers to use for spike generation instead of generating a new random
% sequence.  If 'fRandList' is an empty matrix, it will not be used.
% 'fMemTau' is an optional argument to use in creating a non-ergodic spike
% train.  It will be used as the time constant for an exponential filtering of
% the random sequence.  If 'fMemTau' is an empty matrix, it will not be used.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

stOptions = STOptions;
InstanceTemporalResolution = stOptions.InstanceTemporalResolution;
RandomGenerator = stOptions.RandomGenerator;


% -- Check arguments

if (nargin > 4)
   disp('--- STTestSpikePoisson: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STTestSpikePoisson: Incorrect usage.');
   disp('       This is an internal spike creation test function');
   help private/STTestSpikePoisson;
   help private/STSpikeCreationTestDescription;
   return;
end

% - Do we need to generate our own random sequence, or was one provided?
if (~exist('fRandList', 'var') || isempty(fRandList))
   fRandList = feval(RandomGenerator, 1, length(tTimeTrace));
end

% - Should we perform an exponential filtering?
if (exist('fMemTau', 'var') && ~isempty(fMemTau));
   % - Determine temporal resolution
   fTemporalRes = tTimeTrace(2) - tTimeTrace(1);
   fRandList = MakeNonErgodic(fRandList, fMemTau, fTemporalRes);
end

% -- Poisson process
%                             x
% P(N=x) = exp(-lambda) lambda
%          --------------------
%                   x!

% - In our case, lambda is the instantaneous avg number of spikes per interval
%   and x is 1

% -- Determine the spike indices

fInstSpikeAvgNum = fInstFreq .* InstanceTemporalResolution;
fInstSpikeProb = exp(-fInstSpikeAvgNum) .* fInstSpikeAvgNum;
nSpikeIndices = find(fRandList <= fInstSpikeProb);

% --- END of STTestSpikePoisson.m ---
