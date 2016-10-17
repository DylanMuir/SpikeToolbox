function [stOptions] = STOptionsLoad(filename)

% STOptionsLoad - FUNCTION Load Spike Toolbox options from disk
% $Id: STOptionsLoad.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: STOptionsLoad
%        [stOptions] = STOptionsLoad
%        STOptionsLoad(filename)
%
% The first usage will load the default options from disk.  The second usage
% will return the options in a Spike Toolbox options structure instead of
% setting the options for the toolbox.  The third usage will load the options
% from a specific file instead of the default options.
%
% If the Spike Toolbox options have never been set, the 'factory default'
% options will be set.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004

% -- Declare globals
global ST_OPTIONS_FILE;
STCreateGlobals;


% -- Check arguments

if (nargin > 1)
   disp('--- STOptionsLoad: Extra arguments ignored');
end

if (nargin < 1)
   filename = ST_OPTIONS_FILE;
end


% -- See if file exists
if (exist(filename) ~= 2)
   % - File doesn't exist
   if (nargin == 0)
      % - User wanted to load defaults, so create them
      stOptions = STToolboxDefaults;
      disp('--- STOptionsLoad: Loading factory default options');
   else
      % - The user wanted to load defaults from a file,
      %   but the file didn't exist
      fprintf(1, '*** STOptionsLoad: The options file [%s] does not exist', filename);
   end
   
else
   data = load(filename, 'stOptions');
   stOptions = data.stOptions;
   
   % - Check to see whether the options are for the current version
   if (~STIsValidOptionsStruct(stOptions))
      % - No, so load the toolbox defaults
      disp('*** STOptionsLoad: Saved options are for a previous toolbox version.');
      disp('       Loading factory default options instead.');
      
      stOptions = STToolboxDefaults;
   end
end


% -- Either set or return the options
if (nargout == 0)
   % - The user wanted to set the options
   STOptions(stOptions);
   clear stOptions;
end

% --- END of STOptionsLoad.m ---

% $Log: STOptionsLoad.m,v $
% Revision 2.3  2005/02/10 13:44:38  dylan
% * Modified STFindSynchronousPairs to use 'DefaultSynchWindowSize' for its
% toolbox default instead of 'DefaultWindowSize'.
%
% * Modified STOptions, STOptionsDescribe, STOptionsLoad and STToolboxDefaults to
% support the new DefaultSynchWindowSize option, as well as several new options
% to support cross-correlation analysis of spike trains.
%
% * Modified STCreateGlobals to set a new options structure signature.  This means
% that any saved options you have will need to be reset.
%
% Revision 2.2  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
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
