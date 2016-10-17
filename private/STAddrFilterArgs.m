function [stasSpecification, cFiltered] = STAddrFilterArgs(varargin)

% STAddrFilterArgs - FUNCTION (Internal) Filter address specifications and arguments
% $Id: STAddrFilterArgs.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [stasSpecification, cFiltered] = STAddrFilterArgs(nAddr1, nAddr2, ...)
%        [stasSpecification, cFiltered] = STAddrFilterArgs(stasSpecification, nAddr1, nAddr2, ...)
%
% If a specification was provided in the addressing arguments, it will be
% filtered off and returned in 'stasSpecification'.  'cFiltered' will contain
% a cell array of the remaining arguments, with any specifications removed.
% If no specification was supplied in the argument list, the default output
% addressing specification will be taken from the toolbox options.
%
% This is an internal Spike Toolbox function and should not be used from the
% command line.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 16th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

stOptions = STOptions;

% -- Check arguements

if (nargin == 0)
   disp('*** STAddrFilterArgs: Incorrect usage');
   help private/STAddrFilterArgs;
   return;
end


% -- Extract a specification from the command line

vbIsSpecification = CellForEach(@STIsValidAddrSpec, varargin);

if (any(vbIsSpecification))
   % - At least one entry is a valid specification
   %   so use the first one given
   nSpecIndex = min(find(vbIsSpecification));
   stasSpecification = varargin{nSpecIndex};
else
   stasSpecification = stOptions.stasDefaultOutputSpecification;
end


% -- Filter the remaining arguments

cFiltered = varargin(find(~vbIsSpecification));

% --- END of STAddrFilterArgs.m ---
