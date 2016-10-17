function [bValid] = STIsValidAddrSpec(stasSpecification)

% STIsValidAddrSpec - FUNCTION Test for a valid address specification structure
% $Id: STIsValidAddrSpec.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [bValid] = STIsValidAddrSpec(stasSpecification)
%
% Returns true if 'stasSpecification' is a valid address specification, and
% false otherwise.  At least an 'nWidth' field is required for each addressing
% field for the specification to be considered valid.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STIsValidAddrSpec: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STIsValidAddrSpec: Incorrect usage');
   help STIsValidAddrSpec;
   return;
end


% -- Test for a valid address specification

bValid = false;

if (isempty(stasSpecification))
   % - An empty matrix is not a valid specification
   return;
end

% - Does the 'nWidth' field have an entry for each entry?
for (nFieldIndex = 1:length(stasSpecification))
   if (~FieldExists(stasSpecification(nFieldIndex), 'nWidth'))
      return;
   end
   
   if (FieldExists(stasSpecification(nFieldIndex), 'bRangeCheck') && (stasSpecification(nFieldIndex).bRangeCheck == true))
      % - There should also be a 'nMax' field
      if (~FieldExists(stasSpecification(nFieldIndex), 'nMax'))
         return;
      end
      
      % - The 'nMax' field should not be bigger than the representation
      if (stasSpecification(nFieldIndex).nMax > (2 ^ stasSpecification(nFieldIndex).nWidth - 1))
         return;
      end
   end
end

bValid = true;

% --- END of STIsValidAddrSpec.m ---
