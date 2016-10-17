function [tSpikeTimes] = STTestSpikePoissonSlow(tTimeTrace, nul1, fhInstFreq, ...
                                                definition, vfRandList, fMemTau, nul2) %#ok<INUSD,INUSL>

% STTestSpikePoissonSlow - FUNCTION Internal spike creation test function
% $Id: STTestSpikePoissonSlow.m 8603 2008-02-27 17:49:41Z dylan $
%
% NOT for command-line use

% Usage: [tSpikeTimes] = STTestSpikePoissonSlow(tTimeTrace, [], fhInstFreq, ...
%                                            	definition <, vfRandList, fMemTau, []>)
%
% 'vtTimeTrace' is a vector of discrete time bins over which to generate the
% spike train.  This may correspond to only a single chunk of the train, or the
% entire train.  These bins are to be used when discrete time bins are required,
% but continuous-time generation algorithms are free to ignore them.  This
% vector does define the limits of the train (or chunk) to be generated.
% 'fhInstFreq' is the instantaneous frequency function for this spike train.  It
% must be a function of the form fh(definition, vTimeBins).  'definition' is the
% spike train definition node, and must be passed to 'fhInstFreq' when this
% function is called.
%
% The optional argument 'vfRandList' is a list of random numbers, one for each
% time bin in 'vtTimeTrace', and should be used to generate the train at the
% corresponding bin if supplied.  This will be used to correlate sets of trains.
% The optional argument 'fMemTau', is present, defines the memory time constant
% to be used to create a non-ergodic spike train.  It may be used to filter a
% sequence of random numbers used to generate the spike train.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

stOptions = STOptions;
InstanceTemporalResolution = stOptions.InstanceTemporalResolution;
RandomGenerator = stOptions.RandomGenerator;


% -- Check arguments

if (nargin < 2)
   disp('*** STTestSpikePoissonSlow: Incorrect usage.');
   disp('       This is an internal spike creation test function');
   help private/STTestSpikePoissonSlow;
   help private/STSpikeCreationTestDescription;
   return;
end

% - Do we need to generate our own random sequence, or was one provided?
if (~exist('fRandList', 'var') || isempty(vfRandList))
   fRandList = feval(RandomGenerator, 1, numel(tTimeTrace));
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

% -- Determine the spike times

fInstSpikeAvgNum = feval(fhInstFreq, definition, tTimeTrace) .* InstanceTemporalResolution;
fInstSpikeProb = exp(-fInstSpikeAvgNum) .* fInstSpikeAvgNum;
tSpikeTimes = tTimeTrace(fRandList <= fInstSpikeProb);

% --- END of STTestSpikePoissonSlow.m ---
