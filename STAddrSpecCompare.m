function [bEquivalent] = STAddrSpecCompare(varargin)

% STAddrSpecCompare - FUNCTION Compare two or more addressing specifications
% $Id: STAddrSpecCompare.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [bEquivalent] = STAddrSpecCompare(stasSpec1, stasSpec2, ...)
%        [bEquivalent] = STAddrSpecCompare(caStas1, caStas2, ...)
%
% STAddrSpecCompare will return true if all the supplied addressing
% specifications are binary-equivalent (same number of fields, same bit widths
% for fields, same bit-reversal specification, etc.)
%
% Addressing specifications can be supplied in cell arrays of specifications or
% as individual arguments.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 18th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 1)
   disp('*** STAddrSpecCompare: Incorrect number of arguments');
   help STAddrSpecCompare;
   return;
end

if ((nargin < 2) && ~iscell(varargin{1}))
   disp('*** STAddrSpecCompare: At least two specifications must be supplied');
   return;
end

% - Extract command line
varargin = CellFlatten(varargin);

% - Test that all are valid specifications
vbValid = CellForEach(@STIsValidAddrSpec, varargin);

if (~min(vbValid))
   % - At least one is invalid, therefore they can't be equivalent
   disp('--- STAddrSpecCompare: At least one invalid addressing specification supplied');
   bEquivalent = false;
   return;
end


% -- Compare specifications

% - Get defining info
nFields = length(varargin{1});
vWidths = [varargin{1}.nWidth];
vbReverseSpecs = [varargin{1}.bReverse];
vbInvertSpecs = [varargin{1}.bInvert];
vbIgnoreSpecs = [varargin{1}.bIgnore];

% - Compare
bEquivalent = false;
for (nSpecIndex = 2:length(varargin))        % Specification 1 is the defining spec
   % - Compare number of fields
   if (length(varargin{nSpecIndex}) ~= nFields)
      return;
   end
   
   % - Compare widths of fields
   if (max([varargin{nSpecIndex}.nWidth] ~= vWidths))
      return;
   end
   
   % - Compare reverse specifications of fields
   if (max([varargin{nSpecIndex}.bReverse] ~= vbReverseSpecs))
      return;
   end
   
   % - Compare invert specifications of fields
   if (max([varargin{nSpecIndex}.bInvert] ~= vbInvertSpecs))
      return;
   end
   
   % - Compare ignore specifications of fields
   if (max([varargin{nSpecIndex}.bIgnore] ~= vbIgnoreSpecs))
      return;
   end
end


% -- The tests were passed

bEquivalent = true;

% --- END of STAddrSpecCompare.m ---
