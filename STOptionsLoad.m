function [stOptions] = STOptionsLoad(filename)

% STOptionsLoad - FUNCTION Load Spike Toolbox options from disk
% $Id: STOptionsLoad.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: STOptionsLoad
%        [stOptions] = STOptionsLoad
%        STOptionsLoad(filename)
%
% The first usage will load the default options from disk.  The second usage
% will return the options in a Spike Toolbox options structure instead of
% setting the options for the toolbox.  The third usage will load the options
% from a specific file instead of the default options.
%
% If the Spike Toolbox options have never been set, the 'factory default'
% options will be set.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Declare globals
global ST_OPTIONS_FILE;
STCreateGlobals;


% -- Check arguments

if (nargin > 1)
   disp('--- STOptionsLoad: Extra arguments ignored');
end

if (nargin < 1)
   filename = ST_OPTIONS_FILE;
end


% -- See if file exists
if (exist(filename, 'file') ~= 2)
   % - File doesn't exist
   if (nargin == 0)
      % - User wanted to load defaults, so create them
      stOptions = STToolboxDefaults;
      disp('--- STOptionsLoad: Loading factory default options');
   else
      % - The user wanted to load defaults from a file,
      %   but the file didn't exist
      fprintf(1, '*** STOptionsLoad: The options file [%s] does not exist', filename);
   end
   
else
   data = load(filename, 'stOptions');
   stOptions = data.stOptions;
   
   % - Check to see whether the options are for the current version
   if (~STIsValidOptionsStruct(stOptions))
      % - No, so load the toolbox defaults
      disp('*** STOptionsLoad: Saved options are for a previous toolbox version.');
      disp('       Loading factory default options instead.');
      
      stOptions = STToolboxDefaults;
   end
end


% -- Either set or return the options
if (nargout == 0)
   % - The user wanted to set the options
   STOptions(stOptions);
   clear stOptions;
end

% --- END of STOptionsLoad.m ---
