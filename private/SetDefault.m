function [value, bNew] = SetDefault(strDefName, strDefValue)

% setDefault - FUNCTION Set a default value, but only if it doesn't yet exist
% $Id: SetDefault.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [value, bNew] = SetDefault(strDefName, strDefValue)
% Where: 'strDefName' is the name of a global default value to manipulate.  If
% this variable doesn't exist, it will be created with the value in
% 'strDefValue'.  If the variable already exists, it will not be overwritten.
% The new value of the variable in 'strDefName' is returned as 'value'.
% 'bNew' will be set to true if the variable had to be created.  Otherwise
% 'bNew' will be false;
%
% To use this function in your scripts:  Declare your script parameters global
% at the top of your script.  Then call this function to set the default
% values.  The global parameters will then contain the defaults, or if
% they've been modified by the user, these values will be preserved.
%
% Note: A global variable won't appear in the workspace browser window unless
% it is declared global at the console level.  It will still exist however,
% and will appear in the output from 'who'.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 17th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 2)
   disp('--- SetDefault: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** SetDefault: Incorrect usage');
   help private/SetDefault;
end


% -- Potentially create the global

eval(sprintf('global %s', strDefName));
bNew = false;

if (eval(sprintf('size(%s);', strDefName)) == [0 0])
    eval(sprintf('%s = %s;', strDefName, strDefValue));
    disp(sprintf('--- Creating global parameter %s = %s', strDefName, strDefValue));
    bNew = true;
end

value = eval(sprintf('%s;', strDefName));

% --- END of setDefault.m ---
