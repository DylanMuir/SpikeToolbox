function [stOptionsOld] = STOptions(stOptionsNew)

% STOptions - FUNCTION Retrieve and set options for the Spike Toolbox
% $Id: STOptions.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [stOptions] = STOptions
%                      STOptions(stOptions)
%        [stOptionsOld] = STOptions(stOptionsNew)
%
% The first usage will retrieve the current toolbox options, for the user to
% either examine or modify.  The modified options can them be set by calling
% STOptions with the second usage mode.
%
% The third usage will set the toolbox options, and return the PREVIOUS
% options in 'stOptionsOld'.
%
% STOptions must be called with a valid options structure, as defined by
% STIsValidOptionsStruct.  This structure must contain values for all of
% the Spike Toolbox options.  The easiest way to do this is to use STOptions
% to retrieve the current options, modify the returned structure and pass the
% modified structure back to STOptions.  STOptions guarantees to return a
% valid options structure.
%
% Note that modifying the structure is not enough; to set the toolbox options,
% the structure must be passed back to STOptions as an argument.
%
% Various utility functions exist to make setting addressing modes easier.
% See the STAddrSpec... family of functions for details.
%
% STDescribe will print a summary of the toolbox options when passed an
% options structure as an argument.  STOptionsDescribe will describe the
% current toolbox options.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 13th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Define globals
% global ST_OPTIONS_STRUCTURE_SIGNATURE;
global ST_Options;
global ST_bProgress;

% - Does the user want help?
if ((nargin == 0) && (nargout == 0))
   help STOptions;
   return;
end

STCreateGlobals;

% - Check to see if any options are loaded
if (~STIsValidOptionsStruct(ST_Options))
   % - Load the default options from disk
   ST_Options = STOptionsLoad;
   ST_bProgress = ST_Options.bDisplayProgress;
end

% -- Detect PCI-AER mex links here



if (nargout > 0)
   % - The user wants to retrieve the existing / old options
   stOptionsOld = ST_Options;
end

if (nargin > 0)
   % - The user wants to set some options
   % - Check to see if the use has supplied a valid options structure
   if (~STIsValidOptionsStruct(stOptionsNew))
      disp('*** STOptions: Invalid Spike Toolbox options structure provided.')
      disp('       Type "help STOptions" for help on retrieving a valid structure');
   else
      ST_Options = stOptionsNew;
      ST_bProgress = ST_Options.bDisplayProgress;
   end
end

% --- END of STOptions.m ---
