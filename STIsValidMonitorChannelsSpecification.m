function [bValid] = STIsValidMonitorChannelsSpecification(cellstasMonitorSpec)

% STIsValidMonitorChannelsSpecification - FUNCTION Tests the validity of a monitor channels specification
% $Id: STIsValidMonitorChannelsSpecification.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [bValid] = STIsValidMonitorChannelsSpecification(cellstasMonitorSpec)
%
% STIsValidMonitorChannelsSpecification checks whether a variable is valid
% to be used as a monitor channels specification, for insertion into the
% toolbox options.
%
% 'cellstasMonitorSpec' should be a cell array of valid addressing
% specifications, or empty matrices.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 19th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STIsValidMonitorChannelsSpecification: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STIsValidMonitorChannelsSpecification: Incorrect usage');
   help STIsValidMonitorChannelsSpecification;
   return;
end


% -- Check specification

bValid = false;

% - Is it a cell array?
if (~isa(cellstasMonitorSpec, 'cell'))
   disp('--- STIsValidMonitorChannelsSpecification: The specification should be a cell array');
   return;
end

% - Are the non-null values valid specs?
vbNullChannels = CellForEach(@isempty, cellstasMonitorSpec);
vbValidSpecs = CellForEach(@STIsValidAddrSpec, cellstasMonitorSpec(~vbNullChannels));

if (~min(vbValidSpecs))
   % - At least one monitor channel has an invalid addressing specification
   disp('--- STIsValidMonitorChannelsSpecification: An invalid addressing specification was');
   disp('       supplied for at least one monitor channel');
   return;
end


% -- Passed the tests

bValid = true;


% --- END of STIsValidMonitorChannelsSpecification.m ---
