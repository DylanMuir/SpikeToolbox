function STCreateGlobals

% STCreateGlobals - FUNCTION (Internal) Creates Spike Toolbox global variables
% $Id: STCreateGlobals.m 11422 2009-04-08 12:22:44Z dylan $
%
% Usage: STCreateGlobals
% NOT for console use

% Auhtor: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 13th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% - Create toolbox version string
[null, bNew] = SetDefault('ST_TOOLBOX_VERSION', '0.041');

% - Create options structure signature string
[null, bNew] = SetDefault('ST_OPTIONS_STRUCTURE_SIGNATURE', '''ST_0-041_OPT''');

% - Create default options file name string
[null, bNew] = SetDefault('ST_OPTIONS_FILE', sprintf('''%s''', fullfile(prefdir, 'st_options_defaults.mat')));

if (bNew)
   % - Display a reminder about seeding
   disp(' ');
   disp('*******************************************************************');
   disp('*** Spike Toolbox: REMEMBER TO SEED THE RANDOM NUMBER GENERATOR ***');
   disp('*******************************************************************');
   disp(' ');
end

% --- END of STCreateGlobals.m ---
