function [stasSpecificationFilled] = STAddrSpecFill(stasSpecification)

% STAddrSpecFill - FUNCTION Fill empty fields in a address specification
% $Id: STAddrSpecFill.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [stasSpecificationFilled] = STAddrSpecFill(stasSpecification)
%
% This function will take a valid (but minimal) addressing specification given
% in 'stasSpecification' and fill any fields which have been left empty with
% their defaults.  This function will never change the functional aspects of
% an address specification.
%
% See the toolbox documentation for information about address
% specifications.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STAddrSpecFill: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STAddrSpecFill: Incorrect usage');
   help STAddrSpecFill;
   return;
end


% -- Check for a valid specification

if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrSpecFill: Invalid address spefication supplied');
   return;
end


% -- Fill the address fields

for (nFieldIndex = 1:length(stasSpecification))
   if (~FieldExists(stasSpecification(nFieldIndex), 'Description'))
      if (FieldExists(stasSpecification(nFieldIndex), 'bIgnored') && stasSpecification(nFieldIndex).bIgnored)
         stasSpecification(nFieldIndex).Description = '(Ignored)';
      else
         stasSpecification(nFieldIndex).Description = sprintf('Field%d', nFieldIndex-1);
      end
   end
   
   if (~FieldExists(stasSpecification(nFieldIndex), 'bReverse'))
      stasSpecification(nFieldIndex).bReverse = false;
   end
   
   if (~FieldExists(stasSpecification(nFieldIndex), 'bInvert'))
      stasSpecification(nFieldIndex).bInvert = false;
   end
   
   if (~FieldExists(stasSpecification(nFieldIndex), 'bMajorField'))
      stasSpecification(nFieldIndex).bMajorField = false;
   end
   
   if (~FieldExists(stasSpecification(nFieldIndex), 'bRangeCheck'))
      stasSpecification(nFieldIndex).bRangeCheck = false;
   end
   
   if (~FieldExists(stasSpecification(nFieldIndex), 'bIgnore'))
      stasSpecification(nFieldIndex).bIgnore = false;
   end   
end

stasSpecificationFilled = stasSpecification;

% --- END of STAddrSpecFill.m ---
