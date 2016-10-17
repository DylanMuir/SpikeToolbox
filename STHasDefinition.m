function [bHasDefinition] = STHasDefinition(stTrain)

% STHasDefinition - FUNCTION test whether a spike train has a definition
% $Id: STHasDefinition.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [bHasDefinition] = STHasDefinition(stTrain)
%
% 'stTrain' is a valid spike train.  'bHasDefinition' will be true if
% 'stTrain' contains a definition, and false otherwise.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 8th May, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STHasDefinition: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STHasDefinition: Incorrect usage');
   help STHasDefinition;
   return;
end

% - Check for a valid spike train
if (~STIsValidSpikeTrain(stTrain))
   disp('*** STHasDefinition: Invalid spike train supplied');
   return;
end


% -- Check for a definition

if (FieldExists(stTrain, 'definition'))
   bHasDefinition = true;
else
   bHasDefinition = false;
end

return;


% --- END of STHasDefinition.m ---
