function [fInstFreq] = STInstantaneousFrequencyLinear(stTrainDef, tTimeCurr)

% STInstantaneousFrequencyLinear - FUNCTION Internal frequency profile function
% $Id: STInstantaneousFrequencyLinear.m 2411 2005-11-07 16:48:24Z dylan $
%
% NOT for command-line use

% Usage: [fInstFreq] = STInstantaneousFrequencyLinear(stTrainDef, tTimeCurr)

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 2)
   disp('*** STInstantaneousFrequencyLinear: Incorrect usage');
   disp('       This is an internal frequency profile function');
   help private/STInstantaneousFrequencyLinear;
   help private/STInstFreqDescription;
   return;
end


% - linear frequency gradient from min to max

fInstFreq = (0:(1/(length(tTimeCurr)-1)):1) .* (stTrainDef.fEndFreq - stTrainDef.fStartFreq) + stTrainDef.fStartFreq;

% --- END of STInstantaneousFrequencyLinear.m ---
