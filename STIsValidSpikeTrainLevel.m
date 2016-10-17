function [bValidLevel, strLevelCanonical] = STIsValidSpikeTrainLevel(strLevel)

% STIsValidSpikeTrainLevel - FUNCTION Test for a valid spike train level description
% $Id: STIsValidSpikeTrainLevel.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [bValidLevel] = STIsValidSpikeTrainLevel(strLevel)
%        [bValidLevel, strLevelCanonical] = STIsValidSpikeTrainLevel(strLevel)
%
% 'strLevel' is a string (hopefully) specifying a spike train level.  If
% 'strLevel' is one of {'definition', 'instance', 'mapping'} then 'bValid'
% will be true.  Otherwise 'bValid' will be false.
%
% STIsValidSpikeTrainLevel is insensitive to case.  If a valid (but
% non-standard) spike train level was supplied in 'strLevel', then the correct
% value will be returned in 'strCanonical'.  For example 'DefInITion' -->
% 'definition'.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 27th August, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STIsValidSpikeTrainLevel: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STIsValidSpikeTrainLevel: Incorrect usage');
   help STIsValidSpikeTrainLevel;
   return;
end


% -- Test strLevel

switch lower(strLevel)
   case {'d', 'definition'}
      bValidLevel = true;
      strLevelCanonical = 'definition';
      return;
      
   case {'i', 'instance'}
      bValidLevel = true;
      strLevelCanonical = 'instance';
      return;
      
   case {'m', 'mapping'}
      bValidLevel = true;
      strLevelCanonical = 'mapping';
      return;
      
   otherwise
      bValidLevel = false;
      strLevelCanonical = '';
      return;
end

% --- END of STIsValidSpikeTrainLevel.m ---
