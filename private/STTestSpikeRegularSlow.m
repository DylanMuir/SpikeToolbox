function [vtSpikeTimes] = STTestSpikeRegularSlow(vtTimeTrace, tLastSpike, fhInstFreq, ...
                                                 definition, varargin)

% STTestSpikeRegularSlow - FUNCTION Internal spike creation test function
% $Id: STTestSpikeRegularSlow.m 8603 2008-02-27 17:49:41Z dylan $
%
% NOT for command-line use

% Usage: [vtSpikeTimes] = STTestSpikeRegularSlow(vtTimeTrace, tLastSpike, fhInstFreq, ...
%                                            	 definition)
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

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

stOptions = STOptions;
InstanceTemporalResolution = stOptions.InstanceTemporalResolution;


% -- Check arguments

if (nargin < 4)
   disp('*** STTestSpikeRegularSlow: Incorrect usage.');
   disp('       This is an internal spike creation test function');
   help private/STTestSpikeRegularSlow;
   help private/STSpikeCreationTestDescription;
   return;
end


% -- Compensate for previous spike

if (~exist('tLastSpike', 'var') || isempty(tLastSpike))
   fLastSpikeComp = 0;
else
   vtIntervening = tLastSpike:InstanceTemporalResolution:(vtTimeTrace(1)-InstanceTemporalResolution);
   fLastSpikeComp = sum(feval(fhInstFreq, definition, vtIntervening) .* InstanceTemporalResolution);
end


% -- Determine the spike times

vfInstFreq = feval(fhInstFreq, definition, vtTimeTrace);
vtSpikeTimes = vtTimeTrace(diff([0 fix(cumsum(vfInstFreq .* InstanceTemporalResolution) + fLastSpikeComp)]) >= 1);



% --- END of STTestSpikeRegularSlow.m ---
