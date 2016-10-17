function STAddrDescribe(varargin)

% STAddrDescribe - FUNCTION Print information about an address
% $Id: STAddrDescribe.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: STAddrDescribe(nAddr1, nAddr2, ...)
%        STAddrDescribe(stasSpecification, nAddr1, nAddr2, ...)
%
% This function will display information about a spike toolbox address.  The
% addressing fields should be sent as function arguments.  If an addressing
% specification is not included in the argument list, the default output
% addressing specification will be taken from the toolbox options.
%
% Note: STAddrDescribe is NOT vectorised.  That wouldn't be very useful
% anyway.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 19th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 1)
   disp('*** STAddrDescribe: Incorrect usage');
   help STAddrDescribe;
   return;
end


% -- Extract the address

[stasSpecification, varargin] = STAddrFilterArgs(varargin{:});

% - Check that we were supplied with a valid specification
if (~STIsValidAddrSpec(stasSpecification))
   disp('--- STIsValidAddress: An invalid addressing specification was supplied');
   return;
end

% - Fill out the empty fields in the specificaiton
stasSpecification = STAddrSpecFill(stasSpecification);

% - Is the address valid?
if (~STIsValidAddress(stasSpecification, varargin{:}))
   disp('*** STAddrDescribe: Invalid address');
   return;
end


% -- Display the address

% - Print the fields
disp('Address fields:');

nFieldIndex = 1;
for (nEntryIndex = 1:length(stasSpecification))
   if (~stasSpecification(nEntryIndex).bIgnore)
      fprintf(1, '   [%s]: [%d]\n', stasSpecification(nEntryIndex).Description, varargin{nFieldIndex});
      nFieldIndex = nFieldIndex + 1;
   end
end

fprintf('\n');

% - Print the specification
disp('Addressing specification:');
fprintf(1, '   ');
STAddrSpecDescribe(stasSpecification);
fprintf(1, '\n');

% - Print the logical and physical addresses
fprintf(1, 'Logical address: [%.4f]\n', STAddrLogicalConstruct(stasSpecification, varargin{:}));
fprintf(1, 'Physical address: [%x] hex\n', STAddrPhysicalConstruct(stasSpecification, varargin{:}));
fprintf(1, '\n');

% --- END of STAddrDescribe.m ---
