function [bValid] = STIsValidOptionsStruct(stOptions)

% STIsValidOptionsStruct - FUNCTION Tests for a valid Spike Toolbox options structure
% $Id: STIsValidOptionsStruct.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [bValid] = STIsValidOptionsStruct(stOptions)
%
% 'stOptions' is a matlab variable.  If 'stOptions' is a valid options
% structure, 'bValid' will be true.  Otherwise 'bValid' will be false.  Type
% 'help STOptions' for help on retrieving a valid Spike Toolbox options
% structure.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 13th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Declare globals
global ST_OPTIONS_STRUCTURE_SIGNATURE;
STCreateGlobals;

% -- Check arguments

if (nargin < 1)
   disp('*** STIsValidOptionsStruct: Incorrect usage');
   help STIsValidOptionsStruct;
   return;
end

bValid = false;

% - Check for the signature field
if (~isfield(stOptions, 'Signature'))
   return;
end

% - Check for a valid signature
if (~strcmp(stOptions.Signature, ST_OPTIONS_STRUCTURE_SIGNATURE))
   disp('--- STIsValidOptionsStruct: Invalid options signature field.  This options');
   disp('       structure may be from a previous revision of the toolbox');
   return;
end

% - Check for a valid output addressing specification
if (~STIsValidAddrSpec(stOptions.stasDefaultOutputSpecification))
   disp('--- STIsValidOptionsStruct: An invalid output addressing specification was');
   disp('       supplied in the options structure');
   return;
end

% - Check for valid monitor channel addressing specifications
if (FieldExists(stOptions, 'MonitorChannelsAddressing'))
   if (~STIsValidMonitorChannelsSpecification(stOptions.MonitorChannelsAddressing))
      % - The spec is invalid
      return;
   end
else
   % - The field doesn't even exist!
   disp('--- STIsValidOptionsStruct: No addressing specifications were supplied for');
   disp('       the monitor channels in the options structure');
end



if (FieldExists(stOptions, 'stasMonitorChannelID'))
   if (~STIsValidChannelAddrSpec(stOptions.stasMonitorChannelID))
      % - The spec is invalid
      return;
   end
else
   % - The spec doesn't even exist!
   disp('--- STIsValidOptionsStruct: No addressing specifcation was supplied for the');
   disp('       monitor channel ID in the options structure');
   return;
end


% -- Passed the tests

bValid = true;

% --- END of STIsValidOptionsStruct ---
