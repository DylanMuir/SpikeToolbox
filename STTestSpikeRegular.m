function [nSpikeIndices] = STTestSpikeRegular(tTimeCurr, fInstFreq)

% FUNCTION STTestSpikeRegular - Internal spike creation test function
% NOT for command-line use

% Usage: [nSpikeIndices] = STTestSpikeRegular(tTimeCurr, fInstFreq)

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% $Id: STTestSpikeRegular.m,v 1.1 2004/06/04 09:35:49 dylan Exp $

% -- Define globals

global INSTANCE_TEMPORAL_RESOLUTION;
STCreateDefaults;

% -- Check arguments

if (nargin < 2)
   disp('*** STTestSpikeRegular: Incorrect usage.');
   disp('       This is an internal spike creation test function');
   help STTestSpikeRegular;
   help STSpikeCreationTestDescription;
   return;
end

% -- Determine the spike indices

nSpikeIndices = find(rem(tTimeCurr, 1 ./ fInstFreq) < INSTANCE_TEMPORAL_RESOLUTION);    % Test for spikes

% --- END of STTestSpikeRegular.m ---

% $Log: STTestSpikeRegular.m,v $
% Revision 1.1  2004/06/04 09:35:49  dylan
% Reimported (nonote)
%
% Revision 1.4  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%