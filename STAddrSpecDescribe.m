function STAddrSpecDescribe(stasSpecification)

% STAddrSpecDescribe - FUNCTION Pretty print an addressing specification
% $Id: STAddrSpecDescribe.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: STAddrSpecDescribe(stasSpecification)
%
% This function will display a user-friendly overview of an addressing
% specification.  All field will be shown, with bit-number extents,
% decriptions (if available) and an indication of whether the bits in the
% field are reversed or not.  Note that the display is never to scale.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STAddrSpecDescribe: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STAddrSpecDescribe: Incorrect usage');
   help STAddrSpecDescribe;
   return;
end


% -- Check that we have at least the basic addressing requirements

if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrSpecDescribe: An invalid addressing specification was supplied');
   return;
end

% -- Print the address format

% - Fill empty fields in the addressing specification
stasSpecification = STAddrSpecFill(stasSpecification);

% - How many bits in total?
nTotalBits = sum([stasSpecification.nWidth]);

% - Iterate from most to least significant
nCurrMaxBits = nTotalBits;
for (nFieldIndex = length(stasSpecification):-1:1)
   if (FieldExists(stasSpecification(nFieldIndex), 'bReverse') && stasSpecification(nFieldIndex).bReverse)
      sReverse = '<-> ';
   else
      sReverse = '';
   end
   
   if (FieldExists(stasSpecification(nFieldIndex), 'bInvert') && stasSpecification(nFieldIndex).bInvert)
      sDescription = sprintf('~(%s)', stasSpecification(nFieldIndex).Description);
   else
      sDescription = stasSpecification(nFieldIndex).Description;
   end
   
   fprintf(1, '|(%d)  %s %s (%d)', nCurrMaxBits-1, sDescription, sReverse, nCurrMaxBits - stasSpecification(nFieldIndex).nWidth);
   nCurrMaxBits = nCurrMaxBits - stasSpecification(nFieldIndex).nWidth;
end
fprintf(1, '|\n');

% --- END of STAddrSpecDescribe.m ---
