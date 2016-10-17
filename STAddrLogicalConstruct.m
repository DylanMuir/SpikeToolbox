function [addrLog] = STAddrLogicalConstruct(varargin)

% STAddrLogicalConstruct - FUNCTION Build a logical address from a neuron and synapse ID
% $Id: STAddrLogicalConstruct.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [addrLog] = STAddrLogicalConstruct(nAddr1, nAddr2, ...)
%        [addrLog] = STAddrLogicalConstruct(stasSpecification, nAddr1, nAddr2, ...)
%
% STAddrLogicalConstruct will return the logical address corresponding to a
% synapse address provided by the addressing fields.  The returned address will
% take the form defined by the addressing specification.  If a specification
% is not supplied in the argument list, the default output address
% specification will be taken from the toolbox options.
%
% Address fields marked as 'major' fields in the specification will be to the
% left of the decimal point.  Fields marked as 'minor' fields will be to the
% right of the decimal point.  Fields will be taken from the command line in
% least to most significant order.  The most significant 'minor' field will be
% closest to the decimal point.
%
% Note that logical addresses are intended to be in semi-human readable form,
% and therefore addressing fields marked for reversal will not be reversed.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 9th May, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 1)
   disp('*** STAddrLogicalConstruct: Incorrect number of arguments');
   help STAddrLogicalConstruct;
   return;
end

% - Check for a valid address
if (~STIsValidAddress(varargin{:}))
   disp('*** STAddrLogicalConstruct: An invalid address was supplied for the given');
   disp('       addressing specification');
   return;
end


% -- Extract the addressing arguments

[stasSpecification, varargin] = STAddrFilterArgs(varargin{:});

% - Fill empty fields in the specification
stasSpecification = STAddrSpecFill(stasSpecification);

% -- Construct the address

nFieldIndex = 1;
nIntegerBitsUsed = 0;
nFractionalComponent = 0;
nIntegerComponent = 0;
for (nEntryIndex = 1:length(stasSpecification))
   if (~stasSpecification(nEntryIndex).bIgnore)
      % - Constrain to the width of the field
      nComponent = bitshift(varargin{nFieldIndex}, 0, stasSpecification(nEntryIndex).nWidth);

      if (stasSpecification(nEntryIndex).bMajorField)
         % - Use as a integer component
         % - Shift the field left
         nComponent = nComponent .* 2^(nIntegerBitsUsed);
         nIntegerComponent = nIntegerComponent + nComponent;
         nIntegerBitsUsed = nIntegerBitsUsed + stasSpecification(nEntryIndex).nWidth;
      else
         % - Use as a fractional component
         % - Shift the existing stuff right
         nFractionalComponent = nFractionalComponent .* 2^(-stasSpecification(nEntryIndex).nWidth);
         nFractionalComponent = nFractionalComponent + nComponent .* 2^(-stasSpecification(nEntryIndex).nWidth);
      end
      
      nFieldIndex = nFieldIndex + 1;
   end
end

addrLog = nIntegerComponent + nFractionalComponent;

% --- END of STAddrLogicalConstruct.m ---
