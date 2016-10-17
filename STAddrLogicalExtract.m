function [varargout] = STAddrLogicalExtract(addrLog, stasSpecification)

% STAddrLogicalExtract - FUNCTION Extract the neuron and synapse IDs from a logical address
% $Id: STAddrLogicalExtract.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [nAddr1, nAddr2, ...] = STAddrLogicalExtract(addrLog)
%        [nAddr1, nAddr2, ...] = STAddrLogicalExtract(addrLog, stasSpecification)
%
% 'addrLog' should be a logical address as constructed by
% STAddrLogicalConstruct.  STAddrLogicalExtract will extract the
% indices for each addressing field, as defined by the addressing
% specification.  If this specification is not supplied in the argument
% list, the default output addressing specification will be taken from
% the toolbox options.  The field indices will be returned in the variable
% length argument list.  STAddrLogicalExtract is vectorised.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 9th May, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

stOptions = STOptions;


% -- Check arguments

if (nargin > 2)
   disp('--- STAddrLogicalExtract: Extra arguments ignored');
end

if (nargin < 2)
   stasSpecification = stOptions.stasDefaultOutputSpecification;
end

if (nargin < 1)
   disp('*** STAddrLogicalExtract: Incorrect usage');
   help STAddrLogicalExtract;
   return;
end

% - Check for a valid address specification
if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrLogicalExtract: Invalid addressing specification supplied');
   return;
end

% - Check for the correct number of output arguments
nRequiredFields = sum(~[stasSpecification.bIgnore]);

if (nargout ~= nRequiredFields)
   disp('--- STAddrLogicalExtract: Outputting a different number of addressing fields');
   disp('       than you''ve provided');
end


% -- Extract the indices

% - Which field are major?
vbMajorField = [stasSpecification.bMajorField];
vbMinorField = ~vbMajorField;

% - Count bits for the minor fields
if (any(vbMinorField))
   nMinorBits = sum([stasSpecification(find(~vbMajorField)).nWidth]);
else
   nMinorBits = 0;
end

% - Separate the major and minor fields
nMajorAddress = fix(addrLog);
nMinorAddress = (addrLog - fix(addrLog)) .* 2^nMinorBits;

nField = 1;
for (nEntryIndex = 1:length(stasSpecification))
   if (~stasSpecification(nEntryIndex).bIgnore)
      if (vbMajorField(nEntryIndex))
         % - Mask off the current address field
         varargout{nField} = bitshift(nMajorAddress, 0, stasSpecification(nEntryIndex).nWidth);
         
         % - Shift the rest of the field, truncate the decimal portion
         nMajorAddress = fix(nMajorAddress .* 2^(-stasSpecification(nEntryIndex).nWidth));
      else
         % - Mask off the current address field
         varargout{nField} = bitshift(nMinorAddress, 0, stasSpecification(nEntryIndex).nWidth);
         
         % - Shift the rest of the field
         nMinorAddress = fix(nMinorAddress .* 2^(-stasSpecification(nEntryIndex).nWidth));
      end
      
      nField = nField + 1;
   end
end


% --- END of STAddrLogicalExtract.m ---
