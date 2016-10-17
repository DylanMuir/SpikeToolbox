function [nSpikeIndices] = STTestSpikePoisson(tTimeCurr, fInstFreq)

% FUNCTION STTestSpikePoisson - Internal spike creation test function
% NOT for command-line use

% Usage: [nSpikeIndices] = STTestSpikePoisson(tTimeCurr, fInstFreq)

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% $Id: STTestSpikePoisson.m,v 1.1 2004/06/04 09:35:49 dylan Exp $

% -- Define globals
global INSTANCE_TEMPORAL_RESOLUTION RANDOM_GENERATOR;
STCreateDefaults;


% -- Check arguments

if (nargin < 2)
   disp('*** STTestSpikePoisson: Incorrect usage.');
   disp('       This is an internal spike creation test function');
   help STTestSpikePoisson;
   help STSpikeCreationTestDescription;
   return;
end


% -- Determine the spike indices

fInstSpikeProb = fInstFreq .* INSTANCE_TEMPORAL_RESOLUTION;
fRandList = feval(RANDOM_GENERATOR, 1, length(tTimeCurr));
nSpikeIndices = find(fRandList <= fInstSpikeProb);

% --- END of STTestSpikeRegular.m ---

% $Log: STTestSpikePoisson.m,v $
% Revision 1.1  2004/06/04 09:35:49  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%