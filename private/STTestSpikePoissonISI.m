function [vtSpikeTimes] = STTestSpikePoissonISI(vtTimeTrace, tLastSpike, fhInstFreq, ...
                                            	   definition, varargin) %#ok<VANUS>

% STTestSpikePoissonISI - FUNCTION Internal spike creation test function
% $Id: STTestSpikePoissonISI.m 10426 2008-10-22 12:40:03Z dylan $
%
% NOT for command-line use

% Usage: [tSpikeTimes] = STTestSpikePoissonISI(tTimeTrace, tLastSpike, fhInstFreq, ...
%                                              definition)
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
% Inhomogeneous spike trains are generated using the "thinning" algorithm of
% [1].
%
% [1] Lewis AW, Shedler GS. "Simulation of Nonhomogeneous Poisson Processes by
% Thinning." 1978, Technical report, Naval Postgraduate School Monterey
% California.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 3rd February, 2008
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

stO = STOptions;
fhRNG = stO.RandomGenerator;


% -- Check arguments

if (nargin < 4)
   disp('*** STTestSpikePoissonISI: Incorrect usage.');
   disp('       This is an internal spike creation test function');
   help private/STTestSpikePoissonISI;
   help private/STSpikeCreationTestDescription;
   return;
end


% -- Work out various spike train parameters

if (exist('tLastSpike', 'var') && ~isempty(tLastSpike))
   tTrainStart = tLastSpike;
else
   tTrainStart = vtTimeTrace(1);
   tLastSpike = [];
end

tTrainEnd = vtTimeTrace(end);
tTrainLength = tTrainEnd - tTrainStart;
nISIsToGenerate = max(fix(definition.fMaxFreq * tTrainLength * 1.3), 1) + 1;


% -- Generate ISIs until we fill the train

if (nISIsToGenerate > 0)
   tCurrentTime = tTrainStart;
   vISIs = [];
   while (tCurrentTime < tTrainEnd)
      vTheseISIs = exprnd(1/definition.fMaxFreq, 1, nISIsToGenerate);
      vISIs = [vISIs vTheseISIs]; %#ok<AGROW>
      tCurrentTime = tCurrentTime + sum(vISIs);
   end
else
   % - We aren't expecting any spikes at all!
   vISIs = [];
end

% -- Parcel out ISIs

% - Convert ISIs to spike times
vtSpikeTimes = cumsum([tLastSpike vISIs]);

% - Pick out the spike times which fall inside the vTimeTrace window
vbSpikesInTime = (vtSpikeTimes > tTrainStart) & (vtSpikeTimes <= tTrainEnd);

% - Include one extra spike, to take us over the vTimeTrace window.  This is so
% that we know for sure we've sampled from time which fills the whole window.
% We can disregard this extra spike at the end of the whole spike train.
nLastSpikeIndex = find(vbSpikesInTime, 1, 'last');
vbSpikesInTime(nLastSpikeIndex+1) = true;

% - Include the spikes which meet these criteria
vtSpikeTimes = vtSpikeTimes(vbSpikesInTime);


% -- Comb out ISIs

% - Find probabilities of observing the existing spikes
vfInstSpikeProb = feval(fhInstFreq, definition, vtSpikeTimes) ./ definition.fMaxFreq;

% - Thin the spike train by only keeping spikes with high spiking probability
bInclude = vfInstSpikeProb >= feval(fhRNG, 1, numel(vtSpikeTimes));
vtSpikeTimes = vtSpikeTimes(bInclude);

% --- END of STTestSpikePoissonISI.m ---
