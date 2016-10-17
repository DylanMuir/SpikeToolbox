function [varargout] = CellForEachCell(hfunction, cellArray, varargin)

% CellForEachCell - FUNCTION Executes a function for each element of a cell array
% $Id: CellForEachCell.m 7737 2007-10-05 13:54:24Z dylan $
%
% Usage: [oResult] = CellForEachCell(hfunction, cellArray, ...)
%
% 'hfunction' is a string specifying a function to execute or a function
% handle.  It will be passed any extra arguments sent to CellForEach, and
% should return a non-cell result.  'cellArray' is a cell array, each cell
% of which will be passed individually to 'hFunction'.  'oResult' will be
% a cell array the same size and shape of 'cellArray', each element of which
% will contain the result of 'hFunction' called on the corresponding element
% of 'cellArray'.
%
% Note that CellForEach will NOT flatten the cell array before execution.  For
% nested cell arrays, 'hFunction' will be called with the entire sub-array.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 25th August, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 2)
   disp('*** CellForEachCell: Incorrect usage');
   help private/CellForEachCell;
   return;
end

if (~iscell(cellArray))
   % - This should be an error, but we'll be lenient
   cellArray = {cellArray};
end


% -- Evaluate the function for each element

[nRows, nCols, nSlices] = size(cellArray);

for (nOutputIndex = 1:nargout)
   varargout{nOutputIndex} = cell(size(cellArray));
end

% - Pre-allocate return array
vnArgIndices = 1:nargout;
oReturn = cell(nargout, 1);

for (nIndex = 1:numel(cellArray))
   % - Evaluate function, get return arguments
   [oReturn{vnArgIndices}] = feval(hfunction, cellArray{nIndex}, varargin{:});
   
   for (nIndexOutput = vnArgIndices)
      varargout{nIndexOutput}{nIndex} = oReturn{nIndexOutput};
   end
end


% --- END of CellForEachCell.m ---
