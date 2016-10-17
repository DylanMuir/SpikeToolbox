function [addrPhys] = STAddrPhysicalConstruct(varargin)

% STAddrPhysicalConstruct - FUNCTION Determine a synapse physical address
% $Id: STAddrPhysicalConstruct.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [addrPhys] = STAddrPhysicalConstruct(nAddr1, nAddr2, ...)
%        [addrPhys] = STAddrPhysicalConstruct(stasSpecification, nAddr1, nAddr2, ...)
%
% STAddrLogicalConstruct will return the logical address corresponding to a
% synapse address provided by the addressing fields.  The returned address will
% take the form defined by the addressing specification.  If a specification
% is not supplied in the argument list, the default output address
% specification will be taken from the toolbox options.
%
% Fields will be taken from the command line in least to most significant order.
% STAddrPhysicalConstruct uses the floor of all addressing fields.
% STAddrPhysicalConstruct is also vectorised.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 1st April, 2004 (no, really)
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

% stOptions = STOptions;


% -- Check arguments

if (nargin < 1)
   disp('*** STAddrPhysicalConstruct: Incorrect number of arguments');
   help STAddrPhysicalConstruct;
   return;
end

% - Check for a valid address
if (~STIsValidAddress(varargin{:}))
   disp('*** STAddrPhysicalConstruct: An invalid address was supplied for the given');
   disp('       addressing specification');
   return;
end


% -- Extract the addressing arguments

[stasSpecification, varargin] = STAddrFilterArgs(varargin{:});

% - Fill empty fields in the specification
stasSpecification = STAddrSpecFill(stasSpecification);


% -- Construct the address

nFieldIndex = 1;
nBitsUsed = 0;
addrPhys = 0;
for (nEntryIndex = 1:length(stasSpecification))
   nFieldWidth = stasSpecification(nEntryIndex).nWidth;
   if (~stasSpecification(nEntryIndex).bIgnore)
      % - Constrain supplied index to the width of the field
      nComponent = bitshift(varargin{nFieldIndex}, 0, nFieldWidth);
      
      % - Reverse the bits in the field if required
      if (FieldExists(stasSpecification(nEntryIndex), 'bReverse') && stasSpecification(nEntryIndex).bReverse)
         nComponent = BitReverse(nComponent, nFieldWidth);
      end
      
      % - Invert the bits in the field if required
      if (FieldExists(stasSpecification(nEntryIndex), 'bInvert') && stasSpecification(nEntryIndex).bInvert)
         nComponent = (2^nFieldWidth - 1) - nComponent;
      end

      % - Shift the field left
      nComponent = nComponent .* 2^(nBitsUsed);
      
      addrPhys = addrPhys + nComponent;
     
      nFieldIndex = nFieldIndex + 1;
   end
   nBitsUsed = nBitsUsed + nFieldWidth;
end

return;

% --- END of STAddrPhysicalConstruct.m ---
 
