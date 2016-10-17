function [bHasInstance] = STHasInstance(stTrain)

% STHasInstance - FUNCTION test whether a spike train has a instance
% $Id
%
% Usage: [bHasInstance] = STHasInstance(stTrain)
%
% 'stTrain' is a valid spike train.  'bHasInstance' will be true if
% 'stTrain' contains a instance, and false otherwise.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 8th May, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STHasInstance: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STHasInstance: Incorrect usage');
   help STHasInstance;
   return;
end

% - Check for a valid spike train
if (~STIsValidSpikeTrain(stTrain))
   disp('*** STHasInstance: Invalid spike train supplied');
   return;
end


% -- Check for a instance

if (FieldExists(stTrain, 'instance'))
   bHasInstance = true;
else
   bHasInstance = false;
end

return;


% --- END of STHasInstance.m ---
