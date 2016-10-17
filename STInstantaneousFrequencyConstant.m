function [fInstFreq] = STInstantaneousFrequencyConstant(stTrainDef, tTimeCurr)

% FUNCTION STInstantaneousFrequencyConstant - Internal frequency profile function
% NOT for command-line use

% Usage: [fInstFreq] = STInstantaneousFrequencyConstant(stTrainDef, tTimeCurr)

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% $Id: STInstantaneousFrequencyConstant.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Check arguments

if (nargin < 2)
   disp('*** STInstantaneousFrequencyConstant: Incorrect usage');
   disp('       This is an internal frequency profile function');
   help STInstantaneousFrequencyConstant;
   help STInstFreqDescription;
   return;
end


% - Constant frequency, so just return the frequency from the definition
fInstFreq = stTrainDef.fFreq * ones(1, length(tTimeCurr));

% --- END of STInstantaneousFrequencyConstant.m ---

% $Log: STInstantaneousFrequencyConstant.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%