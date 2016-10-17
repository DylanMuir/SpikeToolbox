function [fInstFreq] = STInstantaneousFrequencyLinear(stTrainDef, tTimeCurr)

% FUNCTION STInstantaneousFrequencyLinear - Internal frequency profile function
% NOT for command-line use

% Usage: [fInstFreq] = STInstantaneousFrequencyLinear(stTrainDef, tTimeCurr)

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% $Id: STInstantaneousFrequencyLinear.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Check arguments

if (nargin < 2)
   disp('*** STInstantaneousFrequencyLinear: Incorrect usage');
   disp('       This is an internal frequency profile function');
   help STInstantaneousFrequencyLinear;
   help STInstFreqDescription;
   return;
end


% - linear frequency gradient from min to max

fInstFreq = (0:(1/(length(tTimeCurr)-1)):1) .* (stTrainDef.fEndFreq - stTrainDef.fStartFreq) + stTrainDef.fStartFreq;

% --- END of STInstantaneousFrequencyLinear.m ---

% $Log: STInstantaneousFrequencyLinear.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%