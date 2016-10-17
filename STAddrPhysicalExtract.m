function [varargout] = STAddrPhysicalExtract(addrPhys, stasSpecification)

% STAddrPhysicalExtract - FUNCTION Extract the neuron and synapse IDs from a physical address
% $Id: STAddrPhysicalExtract.m 4210 2006-06-06 14:40:33Z chiara $
%
% Usage: [nAddr1, nAddr2, ...] = STAddrPhysicalExtract(addrPhys)
%        [nAddr1, nAddr2, ...] = STAddrPhysicalExtract(addrPhys, stasSpecification)
%
% 'addrPhys' should be a physcial address as constructed by
% STAddrPhysicalConsstruct.  STAddrPhysicalExtract will extract the
% indices for each addressing field, as defined by the addressing
% specification.  If this specification is not supplied in the argument
% list, the default output addressing specification will be taken from
% the toolbox options.  The field indices will be returned in the variable
% length argument list.
%
% STAddrPhysicalExtract will respect the 'bReverse' field in the addressing
% specification, and reverse the bits in the respective fields in the supplied
% address.  STAddrPhysicalExtract will also respect the 'bInvert' field in the
% specification, and invert the bits in an addressing field.
%
% STAddrPhysicalExtract is vectorised.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 9th May, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

stOptions = STOptions;


% -- Check arguments

if (nargin > 2)
   disp('--- STAddrPhysicalExtract: Extra arguments ignored');
end

if (nargin < 2)
   stasSpecification = stOptions.stasDefaultOutputSpecification;
end

if (nargin < 1)
   disp('*** STAddrPhysicalExtract: Incorrect number of arguments');
   help STAddrPhysicalExtract;
   return;
end

% - Check for a valid address specification
if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrPhysicalExtract: Invalid addressing specification supplied');
   return;
end

% - Check for the correct number of output arguments
nRequiredFields = sum(~[stasSpecification.bIgnore]);

if (nargout ~= nRequiredFields)
   disp('--- STAddrPhysicalExtract: Outputting a different number of addressing fields');
   disp('        than you''ve provided');
end


% -- Extract the indices

nField = 1;
for (nEntryIndex = 1:length(stasSpecification))
  % - Extract the lengthof this field
  nFieldWidth = stasSpecification(nEntryIndex).nWidth;
  
  % - Should we extract this field?
  if (~stasSpecification(nEntryIndex).bIgnore)
      % - Mask off the current address field
      varargout{nField} = bitshift(addrPhys, 0, nFieldWidth);
                    
      % - Reverse the bits in the field if required
      if (FieldExists(stasSpecification(nEntryIndex), 'bReverse') && stasSpecification(nEntryIndex).bReverse)
         varargout{nField} = BitReverse(varargout{nField}, nFieldWidth);
      end
      
      % - Invert the bits in the field if required
      if (FieldExists(stasSpecification(nEntryIndex), 'bInvert') && stasSpecification(nEntryIndex).bInvert)
         varargout{nField} = (2^nFieldWidth - 1) - varargout{nField};
      end
      
      nField = nField + 1;
  end
  
   % - Shift the rest of the address, truncate the decimal portion
   addrPhys = fix(addrPhys .* 2^(-nFieldWidth));
end

return;

% --- END of STAddrPhysicalExtract.m ---
