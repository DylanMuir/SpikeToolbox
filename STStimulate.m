function [stMonTrain] = STStimulate(stTrain, tMonDuration)

% FUNCTION STStimulate - Send a mapped spike train to the PCI-AER board
%
% Usage: [stMonTrain] = STStimulate(stTrain)
%        [stMonTrain] = STStimulate(stTrain, tMonDuration)
%
% 'stTrain' is a spike train mapped to a neuron/synapse address, as created
% by STMap.  'tMonDuration' optionally specifies the duration during which to
% monitor the board for spikes.  If 'tMonDuration' is not supplied, it is
% assumed to be the same duration as 'stTrain', plus one second.  If
% 'stMonTrain' is not required, monitoring will not be performed.
%
% NOTE: STStimulate should be considered VERY beta; it currently relies on the
% 'stimmon' executeable, which should be on the path.

% Author: Dylan Muir <sylan@ini.phys.ethz.ch>
% Created: 3rd May, 2004

% $Id: STStimulate.m,v 1.1 2004/06/04 09:35:49 dylan Exp $

% -- Check arguments

if (nargin > 2)
   disp('--- STStimulate: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STStimulate: Incorrect usage');
   help STStimulate;
   return;
end

if ((nargout > 0) | exist('tMonDuration'))
   bMonitor = true;
else
   bMonitor = false;
end


% -- Create temporary file name

strStimFile = strcat(tempname, '.spiketrain');
strMonFile = strcat(tempname, '.spiketrain');


% -- Check spike train

if (~isfield(stTrain, 'mapping'))
   disp('*** STStimulate: The spike train to use as stimulus must contain a mapping');
   return;
end


% -- Export spike train to file

STExport(stTrain, strStimFile);


% -- Get durations

tStimDuration = stTrain.mapping.tDuration / 1e-3;     % Convert to ms

if (bMonitor)
   if (exist('tMonDuration') == 1)
      tMonDuration = tMonDuration / 1e-3;	% Convert to ms
   else
      tMonDuration = tStimDuration + 1000;	% Default is stim time + 1 second
   end
else
   tMonDuration = 0;
end


% -- Stimulate and monitor

system(sprintf('./stimmon %s %d %d 2000 > %s', strStimFile, tStimDuration, tMonDuration, strMonFile));


% -- Import spike train

stMonTrain = STImport(strMonFile, {[] @STChannelFilterNeuron});
stMonTrain = stMonTrain{2};


% -- Remove temp files

delete(strStimFile);
delete(strMonFile);


% --- END of STStimulate.m ---

% $Log: STStimulate.m,v $
% Revision 1.1  2004/06/04 09:35:49  dylan
% Reimported (nonote)
%
% Revision 1.9  2004/05/25 10:51:05  dylan
% Bug fixes (nonote)
%
% Revision 1.8  2004/05/19 08:24:11  dylan
% Added the new default DEFAULT_CHANNEL_FILTER to STAccessDefaults.  Fixed bugs (nonote)
%
% Revision 1.7  2004/05/19 07:56:50  dylan
% * Modified the syntax of STImport -- STImport now uses an updated version
% of stimmon, which acquires data from all four PCI-AER channels.  STImport
% now imports to a cell array of spike trains, one per channel imported.
% Which channels to import can be specified through the calling syntax.
% * STImport uses channel filter functions to handle different addressing
% formats on the AER bus.  Added two standard filter functions:
% STChannelFilterNeuron and STChannelFilterNeuronSynapse.  Added help files
% for this functionality: STChannelFiltersDescription,
% STChannelFilterDevelop
%
% Revision 1.6  2004/05/14 16:17:50  dylan
% Bug fix (nonote)
%
% Revision 1.5  2004/05/10 09:34:02  dylan
% Bug fixes (nonote)
%
% Revision 1.4  2004/05/10 08:26:44  dylan
% Bug fixes
%
% Revision 1.3  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%