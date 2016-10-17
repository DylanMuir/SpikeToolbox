function STProgress(varargin)

% STProgress - FUNCTION (Internal) Display a progress string using sprintf
% $Id: STProgress.m 2411 2005-11-07 16:48:24Z dylan $
%
% NOT for command line use

% Usage: STProgress(strFormat, ...)
%
% 'strFormat' is a format string as defined by sprintf.  The other arguments
% will be used as substitution parameters for the format string.  Progress
% will only be displayed if the global toolbox option progress flag is set.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 28th February, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Globals

global ST_bProgress;


% -- Check arguments

if (nargin < 1)
   disp('*** STProgress: Incorrect usage')
   help private/STProgress;
   return;
end


% -- Do the progress print, if required
if (ST_bProgress)
   fprintf(1, varargin{:});
   drawnow;
end

% --- END of STProgress.m ---
