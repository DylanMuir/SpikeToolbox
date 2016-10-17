function STHelpWeb(strHelpFile)

% STHelpWeb - FUNCTION Display a documentation file in the Matlab help browser
% $Id: STHelpWeb.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: STHelpWeb(strHelpFile)
%
% 'strHelpFile' should specify an html file somewhere in the spike toolbox
% documentation tree.  STHelpWeb will determine the current Matlab version
% and display the file using the required syntax.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 29th August, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STHelpWeb: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STHelpWeb: Incorrect usage');
   help STHelpWeb;
   return;
end


% -- Find the documentation file

% - Add the spike toolbox documentation location
strDocPath = [fileparts(which('STWelcome')) '/spike/' strHelpFile];

% - Does the file exist?
if (~exist(strDocPath))
   fprintf(1, '*** STHelpWeb: The file [%s] does not exist in the spike toolbox\n', strHelpFile);
   disp('       documentation tree.');
   return;
end


% -- Display the file

% - What version of Matlab are we running?
nRelease = str2num(version('-release'));

% - Use the release-dependent method for displaying help
if (nRelease < 14)
   web(['file:///' strDocPath]);
else
   web(['file:///' strDocPath], '-helpbrowser');
end

% --- END of STHelpWeb.m ---
