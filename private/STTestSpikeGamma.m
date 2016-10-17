function [tSpikeTimes] = STTestSpikeGamma(tTimeTrace, tLastSpike, fhInstFreq, ...
                                          definition, vfRandList, fMemTau, fISIVar) %#ok<INUSL>

% STTestSpikeGamma - FUNCTION Internal spike creation test function
% $Id: STTestSpikeGamma.m 8603 2008-02-27 17:49:41Z dylan $
%
% NOT for command-line use

% Usage: [tSpikeTimes] = STTestSpikeGamma(tTimeTrace, tLastSpike, fhInstFreq, ...
%                                        	definition, vfRandList, fMemTau, fISIVar)
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

if (nargin < 7)
   disp('*** STTestSpikeGamma: Incorrect usage.');
   disp('       This is an internal spike creation test function');
   help private/STTestSpikeGamma;
   help private/STSpikeCreationTestDescription;
   return;
end


% -- Determine whether we can use the fast or slow generation algorithm

bISIMode = true;

if (~exist('fMemTau', 'var') || isempty(fMemTau))
   fMemTau = [];
   bISIMode = false;
end

if (~exist('vfRandList', 'var') || isempty(vfRandList))
   vfRandList = [];
   bISIMode = false;
end


% --  Call the generation algorithm

if (bISIMode)
   disp('--- STTestSpikeGamma: Warning: Correlated and non-ergodic spike trains are not supported by');
   disp('       ''gamma'' mode generation.  This spike train will be generated without these options.');
end

% - Was a variable-frequency spike train requested?
if (~strcmp(definition.strType, 'constant'))
   disp('*** STTestSpikeGamma: Error: Variable-frequency spike trains are not supported by ''gamma''');
   disp('       mode generation.  An empty spike train will be returned.');
   tSpikeTimes = [];
   return;
end

% - Call the generation algorithm
tSpikeTimes = STTestSpikeGammaISI(tTimeTrace, tLastSpike, fhInstFreq, definition, vfRandList, fMemTau, fISIVar);

% --- END of STTestSpikeGamma.m ---
