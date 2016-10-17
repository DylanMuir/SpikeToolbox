function [bValidLevel, strLevelCanonical] = STIsValidSpikeTrainLevel(strLevel)

% STIsValidSpikeTrainLevel - FUNCTION Test for a valid spike train level description
% $Id: STIsValidSpikeTrainLevel.m 124 2005-02-22 16:34:38Z dylan $
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

% $Log: STIsValidSpikeTrainLevel.m,v $
% Revision 2.2  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.1  2004/08/27 12:35:57  dylan
% * STMap is now forgiving of arrays of addresses that have the same number of
% elements, but a different shape.
%
% * Created a new function STIsValidSpiketrainLevel.  This function tests the
% validity of a spike train level description.
%
% * STFindMatchingLevel now uses STIsValidSpiketrainLevel.
%
% * Created a new function STStripTo.  This function strips off undesired
% spiketrain levels, leaving only the specified levels remaining.
%
% * Created a new function STStrip.  This function strips off specified
% spiketrain levels from a train.
%
% * Modified an error message within STMap.
%
