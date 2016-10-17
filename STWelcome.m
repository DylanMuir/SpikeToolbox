function STWelcome(strSection)

% STWelcome - FUNCTION Initialise toolbox and display welcome page
% $Id: STWelcome.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: STWelcome
%        STWelcome(strSection)
%
% STWelcome checks and initiliases some aspects of the spike
% toolbox, and displays the welcome page if all is well.
%
% If the optional argument 'strSection' is supplied, then the corresponding
% documentation section will be displayed in the matlab help browser.
% STWelcome understands values of 'documentation', 'get_started' and
% 'tutorial'.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd March, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- MEX compilation options

STW__strMexFlags = '-O';


% -- Check arguments

if (nargin > 1)
   disp('--- STWelcome: Extra arguments ignored');
end


% -- Test if path is set up correctly

if (~exist('STProgress', 'file'))
	disp('*** STWelcome: The toolbox directory doesn''t appear to be in');
	disp('       the MATLAB path.  Please add this directory to the path:');
	STW__strPath = fileparts(which('STWelcome'));
	fprintf(1, '       %s\n', STW__strPath);
   clear STW__strPath;
	return;
end

% - Get path to private directory
STW__strToolboxPath = fileparts(which('STCreate'));
STW__strPrivatePath = fullfile(STW__strToolboxPath, 'private');

% - Get toolbox options
%STW__stO = STOptions;


% -- Search for mex files

STW__bMexSuccess = true;

% - ConvBarrier.mex___
if (exist(['ConvBarrier.' mexext], 'file') ~= 3)
   disp('--- STWelcome: Compiling ConvBarrier.mex___');
	% - Try to compile it
	STW__strWD = cd;
	cd(STW__strPrivatePath);
   STW__strCommand = sprintf('mex %s ConvBarrier.c', STW__strMexFlags);
	eval(STW__strCommand);
	cd(STW__strWD);
   
   STW__bMexSuccess = STW__bMexSuccess & (exist(['ConvBarrier.' mexext], 'file') == 3);
end

% - twister.mex___
if (exist(['twister.' mexext], 'file') ~= 3)
   disp('--- STWelcome: Compiling twister.mex___');
	% - Try to compile it
	STW__strWD = cd;
	cd(STW__strPrivatePath);
   STW__strCommand = sprintf('mex %s twister.cpp', STW__strMexFlags);
	eval(STW__strCommand);
	cd(STW__strWD);
   
   STW__bMexSuccess = STW__bMexSuccess & (exist(['twister.' mexext], 'file') == 3);
end

% - pciaer_stim_mon.mex___
if (exist(['pciaer_stim_mon.' mexext], 'file') ~= 3)
   disp('--- STWelcome: Compiling pciaer_stim_mon.mex___');
	% - Test for PCI-AER toolbox
	% - Try to compile it
	STW__strWD = cd;
	cd(STW__strPrivatePath);
   
   % - Should test for PCI-AER environment variable!
   
   !make mex
	cd(STW__strWD);
   
   STW__bMexSuccess = STW__bMexSuccess & (exist(['pciaer_stim_mon.' mexext], 'file') == 3);
end

% - PCI-AER library link mex files


% -- Display welcome page, if successful

if (~STW__bMexSuccess)
   % - Display some error text
   disp('*** STWelcome: I couldn''t compile the required toolbox mex files.');
   disp('       Please make sure that the ''mex'' compiler is available from');
   disp('       your default shell, and that the mex compiler options are set');
   disp('       correctly.  Note that pciaer_stim_mon is only required for');
   disp('       stimulation of devices using the PCI-AER system.  The toolbox');
   disp('       will function in every other aspect if this file is not compiled.');
end

% - Did the user specify a section to display?
if (~exist('strSection', 'var'))
   % - Display the "getting started" section by default
   strSection = 'get_started';
end

% - Display the desired documentation section
switch lower(strSection)
   case {'documentation'}
      STHelpWeb('spike_product_page.html');
      
   case {'get_started'}
      STHelpWeb('spike_tb_getstarted.html');
         
   case {'tutorial'}
      STHelpWeb('spike_tb_tutorial_index.html');
end      


% -- Clean up

clear STW__stO STW__strWD STW__strMexFlags STW__strToolboxPath STW__strPrivatePath STW__bMexSuccess;

% --- END of STWelcome.m ---
