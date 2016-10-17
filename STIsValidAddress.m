function [bValid] = STIsValidAddress(varargin)

% STIsValidAddress - FUNCTION Checks for a valid address for a given addressing specification
% $Id: STIsValidAddress.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [bValid] = STIsValidAddress(nAddr1, nAddr2, ...)
%        [bValid] = STIsValidAddress(stasSpecification, nAddr1, nAddr2, ...)
%
% This function will check an address against an addressing specification.  If
% no specification is supplied in the argument list, then the default output
% specification will be used from the toolbox options.
%
% An index should be supplied for each non-ignored field in the address
% specification.  Extra indices will be ignored, but do not make an address
% invalid.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 16th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

% stOptions = STOptions;


% -- Check arguments

if (nargin == 0)
   disp('--- STIsValidAddress: Incorrect usage');
   help STIsValidAddress;
   return;
end

% - Filter the address arguments
[stasSpecification, varargin] = STAddrFilterArgs(varargin{:});

% - Check that we were supplied with a valid specification
if (~STIsValidAddrSpec(stasSpecification))
   disp('--- STIsValidAddress: An invalid addressing specification was supplied');
   return;
end

% - Fill out the specification
stasSpecification = STAddrSpecFill(stasSpecification);

% -- Test for a valid address

bValid = false;

% - Do we have at least enough addressing fields?
nRequiredFields = sum(~[stasSpecification.bIgnore]);

if (length(varargin) < nRequiredFields)
   % - We don't have enough fields
   disp('--- STIsValidAddress: Not enough address fields supplied for given');
   disp('                      addressing specification');
   return;
end;

% - Are the addressing fields all doubles?
vbIsDouble = CellForEach(@isa, varargin, 'double');
if (~min(vbIsDouble))
   disp('--- STIsValidAddress: All address indices must be of class ''double''');
   return;
end

% - Range check the fields
nFieldIndex = 1;
for (nEntryIndex = 1:length(stasSpecification))
   if (~stasSpecification(nEntryIndex).bIgnore)
      if (stasSpecification(nEntryIndex).bRangeCheck)
         % - User-supplied field maximum
         nFieldMax = stasSpecification(nEntryIndex).nMax;
      else
         % - Clip to field extents
         nFieldMax = (2 ^ stasSpecification(nEntryIndex).nWidth - 1);
      end
      
      % - Test all field values for the corresponding field range
      if (max(varargin{nFieldIndex} > nFieldMax))
         % - Out of range
         fprintf(1, '--- STIsValidAddress: Field [%d] is out of range (> [%d])\n', nFieldIndex, nFieldMax);
         return;
      end
      
      nFieldIndex = nFieldIndex + 1;
   end
end

% - Passed the tests
bValid = true;


% --- END of STIsValidAddress.m ---
