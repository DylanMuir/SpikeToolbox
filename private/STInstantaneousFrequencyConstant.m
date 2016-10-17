function [fInstFreq] = STInstantaneousFrequencyConstant(stTrainDef, tTimeCurr)

% STInstantaneousFrequencyConstant - FUNCTION Internal frequency profile function
% $Id: STInstantaneousFrequencyConstant.m 2411 2005-11-07 16:48:24Z dylan $
%
% NOT for command-line use

% Usage: [fInstFreq] = STInstantaneousFrequencyConstant(stTrainDef, tTimeCurr)

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 2)
   disp('*** STInstantaneousFrequencyConstant: Incorrect usage');
   disp('       This is an internal frequency profile function');
   help private/STInstantaneousFrequencyConstant;
   help private/STInstFreqDescription;
   return;
end


% - Constant frequency, so just return the frequency from the definition
fInstFreq = stTrainDef.fFreq * ones(1, length(tTimeCurr));

% --- END of STInstantaneousFrequencyConstant.m ---
