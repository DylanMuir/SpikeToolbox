function STOptionsSave(stOptions, filename)

% STOptionsSave - FUNCTION Save Spike Toolbox options to a file
% $Id: STOptionsSave.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: STOptionsSave
%        STOptionsSave(stOptions)
%        STOptionsSave(stOptions, filename)
%
% The first usage will save the current options as the default for the
% toolbox.  The second usage will save the specified options as the toolbox
% defaults.  The third usage will save the specified options to a particular
% file.  This file can then be loaded with STOptionsLoad.
%
% 'stOptions' muct be a valid Spike Toolbox options structure.  Use STOptions
% to retrieve a current valid options structure.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 13th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Declare globals
global ST_OPTIONS_FILE; % ST_OPTIONS_STRUCTURE_SIGNATURE
STCreateGlobals;


% -- Check arguments

if (nargin > 2)
   disp('--- STOptionsSave: Extra arguments ignored');
end

if (nargin < 2)
   filename = ST_OPTIONS_FILE;
end

if (nargin < 1)
   stOptions = STOptions;
end

% -- Check the options structure
if (~STIsValidOptionsStruct(stOptions))
   disp('*** STOptionsSave: Invalid options structure.');
   disp('*** Type "help STOptions" for help on retrieving a valid structure');
   return;
end

% -- Save the options to file
save(filename, 'stOptions');

% --- END of STOptionsSave.m ---
