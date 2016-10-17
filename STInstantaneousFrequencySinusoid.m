function [fInstFreq] = STInstantaneousFrequencySinusoid(stTrainDef, tTimeCurr)

% FUNCTION STInstantaneousFrequencySinusoid - Internal frequency profile function
% NOT for command-line use

% Usage: [fInstFreq] = STInstantaneousFrequencySinusoid(stTrainDef, tTimeCurr)

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% $Id: STInstantaneousFrequencySinusoid.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Check arguments

if (nargin < 2)
   disp('*** STInstantaneousFrequencySinusoid: Incorrect usage');
   disp('       This is an internal frequency profile function');
   help STInstantaneousFrequencyLinear;
   help STInstFreqDescription;
   return;
end


% - Sinusoidal frequency profile

fInstFreq = (sin(2*pi .* tTimeCurr ./ stTrainDef.tPeriod) + 1) .* (stTrainDef.fMaxFreq - stTrainDef.fMinFreq)/2 + stTrainDef.fMinFreq;

% --- END of STInstantaneousFrequencySinusoid.m ---

% $Log: STInstantaneousFrequencySinusoid.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%