function [stasSpecification] = STAddrSpecChannel(nIgnoreBits, nChannelBits, bInvert)

% STAddrSpecChannel - FUNCTION Address specification utility function
% $Id: STAddrSpecChannel.m 3985 2006-05-09 13:03:02Z dylan $
%
% Usage: [stasSpecification] = STAddrSpecChannel(nIgnoreBits, nChannelBits)
%        [stasSpecification] = STAddrSpecChannel(nIgnoreBits, nChannelBits, bInvert)
%
% This function returns an address specification structure for use with the
% Spike Toolbox.  This specification will contain a single ignored address
% field and a single channel address field, with user-specified widths.  The
% channel address field is most significant.
%
% The user can optionally supply an argument 'bInvert'.  If this boolean value
% is true, the channel ID address field will have its bits inverted.  If not
% supplied, this argument defaults to false.
%
% This function is used to help identify the bits used for channel ID
% filtering for monitored spike trains.
%
% See the toolbox documentation for information about address
% specifications.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004 
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 3)
   disp('--- STAddrSpecChannel: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STAddrSpecChannel: Incorrect usage');
   help STAddrSpecChannel;
   return;
end

if (nargin < 3)
   bInvert = false;
end


% -- Make the address specification structure

% - 'Ignore' address field
field.Description = '(Ignored)';
field.nWidth = nIgnoreBits;
field.bReverse = false;
field.bInvert = false;
field.bMajorField = false;
field.bRangeCheck = false;
field.bIgnore = true;
stasSpecification(1) = field;

% - Channel ID address field
clear field;
field.Description = 'Channel ID';
field.nWidth = nChannelBits;
field.bReverse = false;
field.bInvert = bInvert;
field.bMajorField = false;
field.bRangeCheck = false;
field.bIgnore = false;
stasSpecification(2) = field;


% - Check to make sure it's a valid spec
if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrSpecChannel: Invalid specification supplied');
   clear stasSpecification;
   return;
end

% --- END of STAddrSpecChannel.m ---
