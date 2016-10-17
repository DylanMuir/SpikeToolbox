function [bExists] = FieldExists(struct, fieldName)

% FieldExists - FUNCTION Tests for the existence of a non-empty field in a structure
% $Id: FieldExists.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [bExists] = FieldExists(struct, fieldName)
%
% 'struct' is a matlab variable.  'fieldName' is the name of the field to test
% for.  'bExists' will be true if the field exists in the structre and is
% non-empty.  'bExists' will be false otherwise.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 2)
   disp('--- FieldExists: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** FieldExists: Incorrect usage');
   help private/FieldExists;
   return;
end


% -- Check for field existence

bExists = false;

if (~isfield(struct, fieldName))
   return;
end

% - Only check for non-emptiness if we're looking at a single structure
% element
if (max(size(struct)) == 1)
   if (isempty(getfield(struct, fieldName)))
      return;
   end
end

bExists = true;


% --- END of FieldExists.m ---
