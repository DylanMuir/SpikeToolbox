function SameLinePrintf(varargin)

% SameLinePrintf - FUNCTION Prints a line of text without a line feed
%
% Usage: SameLinePrintf(...)
% Accepts the same syntax as sprintf

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 29th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

fprintf(1, varargin{:});

% --- END of SameLinePrintf.m ---