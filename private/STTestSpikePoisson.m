function [tSpikeTimes] = STTestSpikePoisson(tTimeTrace, tLastSpike, fhInstFreq, ...
                                            	definition, vfRandList, fMemTau, fISIVar)

% STTestSpikePoisson - FUNCTION Internal spike creation test function
% $Id: STTestSpikePoisson.m 8349 2008-02-04 17:51:24Z dylan $
%
% NOT for command-line use

% Usage: [tSpikeTimes] = STTestSpikePoisson(tTimeTrace, tLastSpike, fhInstFreq, ...
%                                           definition <, vfRandList, fMemTau, fISIVar>)
%
% 'vtTimeTrace' is a vector of discrete time bins over which to generate the
% spike train.  This may correspond to only a single chunk of the train, or the
% entire train.  These bins are to be used when discrete time bins are required,
% but continuous-time generation algorithms are free to ignore them.  This
% vector does define the limits of the train (or chunk) to be generated.
% 'tLastSpike', if defined, is the time of the last spike in the previous chunk.
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
% sequence of random numbers used to generate the spike train.  The optional
% argument 'fISIVar', if present, defines the variance in inter-spike-intervals,
% in seconds.  This parameter may be used when generating a spike train.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

stOptions = STOptions;
InstanceTemporalResolution = stOptions.InstanceTemporalResolution;


% -- Check arguments

if (nargin < 4)
   disp('*** STTestSpikePoisson: Incorrect usage.');
   disp('       This is an internal spike creation test function');
   help private/STTestSpikePoisson;
   help private/STSpikeCreationTestDescription;
   return;
end


% -- Determine whether we can use the fast or slow generation algorithm

bISIMode = true;

if (~exist('fMemTau', 'var') || isempty(fMemTau))
   fMemTau = [];
else
   bISIMode = false;
end

if (~exist('vfRandList', 'var') || isempty(vfRandList))
   vfRandList = [];
else
   bISIMode = false;
end


% --  Call the generation algorithms

if (bISIMode)
   tSpikeTimes = STTestSpikePoissonISI(tTimeTrace, tLastSpike, fhInstFreq, ...
                                       definition, vfRandList, fMemTau, fISIVar);
else
   tSpikeTimes = STTestSpikePoissonSlow(tTimeTrace, tLastSpike, fhInstFreq, ...
                                        definition, vfRandList, fMemTau, fISIVar);
end

% --- END of STTestSpikePoisson.m ---
