function [varargout] = CellForEach(hfunction, cellArray, varargin)

% CellForEach - FUNCTION Executes a function for each element of a cell array
% $Id: CellForEach.m 7737 2007-10-05 13:54:24Z dylan $
%
% Usage: [oResult1, oResult2, ...] = CellForEach(hfunction, cellArray, ...)
%
% 'hfunction' is a string specifying a function to execute or a function
% handle.  It will be passed any extra arguments sent to CellForEach, and
% should return a non-cell result.  'cellArray' is a cell array, each cell
% of which will be passed individually to 'hFunction'.  'oResult' will be
% a matrix the same size and shape of 'cellArray', each element of which
% will contain the result of 'hFunction' called on the corresponding element
% of 'cellArray'.
%
% Note that CellForEach will NOT flatten the cell array before execution.  For
% nested cell arrays, 'hFunction' will be called with the entire sub-array.
%
% Note also that for functions that return matricies with more than a single
% element, only the first element will be included in 'oResult'.  See
% CellForEachCell for a function that can return any matlab class and matrices
% of any size.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th May, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 2)
   disp('*** CellForEach: Incorrect usage');
   help private/CellForEach;
   return;
end

if (~iscell(cellArray))
   % - This should be an error, but we'll be lenient
   cellArray = {cellArray};
end


% -- Pre-allocate return arguments

try
   nNumRetArgs = min([nargout, nargout(hfunction)]);
catch
   [nul, err] = lasterr;
   if (err == 'MATLAB:narginout:doesNotApply')
      nNumRetArgs = nargout;
   else
      rethrow(err);
   end
end

[nRows, nCols] = size(cellArray);

oResult = cell(nNumRetArgs);
temp = cell(nNumRetArgs);


% -- Evaluate the function for each element

for (nIndexCol = 1:nCols)
   for (nIndexRow = 1:nRows)
      % - Get the result, only store the first element
      [temp{1:nNumRetArgs}] = feval(hfunction, cellArray{nIndexRow, nIndexCol}, varargin{:});
      
      % - Consolidate return arguments
      for (nRetArgIndex = 1:nNumRetArgs)
         oResult{nRetArgIndex}(nIndexRow, nIndexCol) = temp{nRetArgIndex};
      end
   end
end

varargout = oResult;

% --- END of CellForEach.m ---
