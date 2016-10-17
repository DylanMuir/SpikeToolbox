function [nReversed] = BitReverse(nInput, nWidth)

% BitReverse - FUNCTION Reverse the bits in a field
% $Id: BitReverse.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [nReversed] = BitReverse(nInput, nWidth)
%
% BitReverse will reverse the bits in a integer binary field. 'nInput' is an
% integer bit field to reverse.  'nWidth' is the width of the field.
% 'nReversed' will be the result of reversing the order of bits in 'nInput'.
%
% BitReverse is vectorised.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 28th August, 2004 (extracted from STAddrPhysicalConstruct)
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 2)
   disp('--- BitReverse: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** BitReverse: Incorrect usage');
   help private/BitReverse;
   return;
end


% -- Reverse field

nReversed = zeros(size(nInput));
for (nBitIndex = 1:nWidth)
   vbSet = bitget(nInput, nBitIndex);
   nSetIndex = find(vbSet);
   nReversed(nSetIndex) = bitset(nReversed(nSetIndex), (nWidth+1)-nBitIndex);
end

return;

% --- END of BitReverse.m ---
