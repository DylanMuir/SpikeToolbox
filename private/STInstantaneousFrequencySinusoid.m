function [fInstFreq] = STInstantaneousFrequencySinusoid(stTrainDef, tTimeCurr)

% STInstantaneousFrequencySinusoid - FUNCTION Internal frequency profile function
% $Id: STInstantaneousFrequencySinusoid.m 2411 2005-11-07 16:48:24Z dylan $
%
% NOT for command-line use

% Usage: [fInstFreq] = STInstantaneousFrequencySinusoid(stTrainDef, tTimeCurr)

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 2)
   disp('*** STInstantaneousFrequencySinusoid: Incorrect usage');
   disp('       This is an internal frequency profile function');
   help private/STInstantaneousFrequencyLinear;
   help private/STInstFreqDescription;
   return;
end


% - Sinusoidal frequency profile

fInstFreq = (sin(2*pi .* tTimeCurr ./ stTrainDef.tPeriod) + 1) .* (stTrainDef.fMaxFreq - stTrainDef.fMinFreq)/2 + stTrainDef.fMinFreq;

% --- END of STInstantaneousFrequencySinusoid.m ---
