function [stMonTrain] = STStimulate(stTrain, tMonDuration)

% STStimulate - FUNCTION Send a mapped spike train to the PCI-AER board
% $Id: STStimulate.m 124 2005-02-22 16:34:38Z dylan $
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
% NOTE: STStimulate converts monitor and stimulate times into milliseconds,
% then uses the ceiling of this number.
%
% NOTE: STStimulate should be considered VERY beta; it currently relies on the
% 'stimmon' executable, which should be on the path.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 3rd May, 2004

% -- Check arguments

if (nargin > 2)
   disp('--- STStimulate: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STStimulate: Incorrect usage');
   help STStimulate;
   return;
end

if ((nargout > 0) | (exist('tMonDuration') == 1))
   bMonitor = true;
else
   bMonitor = false;
end

% - Detect stimmon link / executeable
if (exist('stimmon') ~= 2)
   disp('*** STStimulate: Cannot find stimmon on the path.  Cannot stimulate');
   return;
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

tStimDuration = ceil(stTrain.mapping.tDuration / 1e-3);     % Convert to ms

if (bMonitor)
   if (exist('tMonDuration') == 1)
      tMonDuration = ceil(tMonDuration / 1e-3);	% Convert to ms
   else
      tMonDuration = tStimDuration + 1000;	% Default is stim time + 1 second
   end
else
   tMonDuration = 0;
end


% -- Stimulate and monitor

system(sprintf('./stimmon %s %d %d 2000 > %s', strStimFile, tStimDuration, tMonDuration, strMonFile));


% -- Import spike train

if (bMonitor)
	[nul, stMonTrain] = STImport(strMonFile);
end

% -- Remove temp files

%delete(strStimFile);
delete(strMonFile);


% --- END of STStimulate.m ---

% $Log: STStimulate.m,v $
% Revision 2.6  2005/02/22 14:27:55  chiara
% *** empty log message ***
%
% Revision 2.5  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.4  2004/08/25 11:42:31  dylan
% Fixed a bug in STStimulate, where no stimulation would occur if the stimulus
% duration was not an integer.
%
% Revision 2.3  2004/08/20 09:49:32  dylan
% Updated STStimulate to check for the existence of stimmon (nonote)
%
% Revision 2.2  2004/07/22 11:39:54  dylan
% Fixed a bug in STImport and STStimulate (nonote)
%
% Revision 2.1  2004/07/19 16:21:03  dylan
% * Major update of the spike toolbox (moving to v0.02)
%
% * Modified the procedure for retrieving and setting toolbox options.  The new
% suite of functions comprises of STOptions, STOptionsLoad, STOptionsSave,
% STOptionsDescribe, STCreateGlobals and STIsValidOptionsStruct.  Spike Toolbox
% 'factory default' options are defined in STToolboxDefaults.  Options can be
% saved as user defaults using STOptionsSave, and will be loaded automatically
% for each session.
%
% * Removed STAccessDefaults and STCreateDefaults.
%
% * Renamed STLogicalAddressConstruct, STLogicalAddressExtract,
% STPhysicalAddressContstruct and STPhysicalAddressExtract to
% STAddr<type><verb>
%
% * Drastically modified the way synapse addresses are specified for the
% toolbox.  A more generic approach is now taken, where addressing modes are
% defined by structures that outline the meaning of each bit-field in a
% physical address.  Fields can have their bits reversed, can be ignored, can
% have a description attached, and can be marked as major or minor fields.
% Any type of neuron/synapse topology can be addressed in this way, including
% 2D neuron arrays and chips with no separate synapse addresses.
%
% The following functions were created to handle this new addressing mode:
% STAddrDescribe, STAddrFilterArgs, STAddrSpecChannel, STAddrSpecCompare,
% STAddrSpecDescribe, STAddrSpecFill, STAddrSpecIgnoreSynapseNeuron,
% STAddrSpecInfo, STAddrSpecSynapse2DNeuron, STIsValidAddress, STIsValidAddrSpec,
% STIsValidChannelAddrSpec and STIsValidMonitorChannelsSpecification.
%
% This modification required changes to STAddrLogicalConstruct and Extract,
% STAddrPhysicalConstruct and Extract, STCreate, STExport, STImport,
% STStimulate, STMap, STCrop, STConcat and STMultiplex.
%
% * Removed the channel filter functions.
%
% * Modified STDescribe to handle the majority of toolbox variable types.
% This function will now describe spike trains, addressing specifications and
% spike toolbox options.  Added STAddrDescribe, STOptionsDescribe and
% STTrainDescribe.
%
% * Added an STIsValidSpikeTrain function to test the validity of a spike
% train structure.  Modified many spike train manipulation functions to use
% this feature.
%
% * Added features to Todo.txt, updated Readme.txt
%
% * Added an info.xml file, added a welcome HTML file (spike_tb_welcome.html)
% and associated images (an_spike-big.jpg, an_spike.gif)
%
% Revision 2.0  2004/07/13 12:56:32  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
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