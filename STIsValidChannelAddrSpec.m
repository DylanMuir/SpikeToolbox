function [bValid] = STIsValidChannelAddrSpec(stasChannelSpec)

% STIsValidChannelAddrSpec - FUNCTION Checks an address specification for use with channel IDs
% $Id: STIsValidChannelAddrSpec.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [bValid] = STIsValidChannelAddrSpec(stasChannelSpec)
%
% This function verifies that an addresssing specification is valid to be used
% to specify the monitor channel ID address.  The specification must contain
% two fields only, the first ignore and the second not ignored.  The second
% field will specify the bits interpreted as the monitor channel ID.  The
% descriptions are ignored.
%
% See 'STAddrSpecChannel' for help in creating a valid channel addressing
% specification.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 18th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STIsValidChannelAddrSpec: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STIsValidChannelAddrSpec: Incorrect usage');
   return;
end


% -- Check the specification

bValid = false;

% - Is it even a valid specification?
if (~STIsValidAddrSpec(stasChannelSpec))
   disp('--- STIsValidChannelAddrSpec: An invalid addressing specification was supplied');
   return;
end

% - Check for a valid channel addressing specification
if ((length(stasChannelSpec) ~= 2) | ~stasChannelSpec(1).bIgnore | stasChannelSpec(2).bIgnore)
   % - There should be two fields only, the first ignored and the second
   % not ignored
   disp('--- STIsValidChannelAddrSpec: The addressing specification supplied for the monitor');
   disp('       channel ID does not meet the requirements for that use.  Please use');
   disp('       ''STAddrSpecChannel'' to create a conforming specification.');
   return;
end


% -- Passed the tests

bValid = true;

% --- END of STIsValidChannelAddrSpec.m ---
