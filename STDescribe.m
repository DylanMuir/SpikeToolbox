function STDescribe(var)

% STDescribe - FUNCTION Print a description of a spike train toolbox variable
% $Id: STDescribe.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: STDescribe(var)
%
% STDescribe will print as much information as is available about 'var'.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 29th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

stOptions = STOptions;


% -- Check arguments

if (nargin > 1)
   disp('--- STDescribe: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STDescribe: Incorrect number of arguments');
   help STDescribe;
   return;
end


% -- Print some info

SameLinePrintf('--- Spike toolbox version [%.2f]\n', stOptions.ToolboxVersion);

% - Is is a spike train?
if (STIsValidSpikeTrain(var))
   % - Show some info
   STTrainDescribe(var);
   return;
end

% - Is it an addressing specification?
if (STIsValidAddrSpec(var))
   disp('This is an addressing specification:');
   fprintf(1, '   ');
   STAddrSpecDescribe(var);
   return;
end

% - Is it an options structre?
if (STIsValidOptionsStruct(var))
   disp('This is a spike toolbox options structure:');
   STOptionsDescribe(var);
   return;
end

% - I don't know!
disp('This is not a spike toolbox variable!');

% --- END of STDescribe.m ---
