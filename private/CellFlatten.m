function [cellArray] = CellFlatten(varargin)

% CellFlatten - FUNCTION Convert a list of items to a single level cell array
% $Id: CellFlatten.m 7737 2007-10-05 13:54:24Z dylan $
%
% Usage: [cellArray] = CellFlatten(arg1, arg2, ...)
%
% CellFlatten will convert a list of arguments into a single-level cell array.
% If any argument is already a cell array, each cell will be concatenated to
% 'cellArray' in a list.  The result of this function is a single-dimensioned
% cell array containing a cell for each individual item passed to CellFlatten.
% The order of cell elements in the argument list is guaranteed to be
% preserved.
%
% This function is useful when dealing with variable-length argument lists,
% each item of which can also be a cell array of items.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th May, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin == 0)
   disp('*** CellFlatten: Do you want help?');
   help private/CellFlatten;
   return;
end


% -- Convert arguments

% - Find cell arrays
vbIsCell = CellForEach(@iscell, varargin);

if (any(vbIsCell))
   % - Flatten cell arrays and concatenate
   cFlattened = CellForEachCell(@CellFlatten, [varargin{vbIsCell}]);
   cellArray = [{varargin{~vbIsCell}} cFlattened{:}];

else
   % - Just return the arguments
   cellArray = varargin;
end


% --- END of CellFlatten.m ---
