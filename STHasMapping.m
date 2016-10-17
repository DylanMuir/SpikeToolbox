function [bHasMapping] = STHasMapping(stTrain)

% STHasMapping - FUNCTION test whether a spike train has a mapping
% $Id: STHasMapping.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [bHasMapping] = STHasMapping(stTrain)
%
% 'stTrain' is a valid spike train.  'bHasMapping' will be true if
% 'stTrain' contains a mapping, and false otherwise.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 8th May, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STHasMapping: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STHasMapping: Incorrect usage');
   help STHasMapping;
   return;
end

% - Check for a valid spike train
if (~STIsValidSpikeTrain(stTrain))
   disp('*** STHasMapping: Invalid spike train supplied');
   return;
end


% -- Check for a mapping

if (FieldExists(stTrain, 'mapping'))
   bHasMapping = true;
else
   bHasMapping = false;
end

return;


% --- END of STHasMapping.m ---
