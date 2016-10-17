function [stOptionsOld] = STOptions(stOptionsNew)

% STOptions - FUNCTION Retrieve and set options for the Spike Toolbox
% $Id: STOptions.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stOptions] = STOptions
%                      STOptions(stOptions)
%        [stOptionsOld] = STOptions(stOptionsNew)
%
% The first usage will retrieve the current toolbox options, for the user to
% either examine or modify.  The modified options can them be set by calling
% STOptions with the second usage mode.
%
% The third usage will set the toolbox options, and return the PREVIOUS
% options in 'stOptionsOld'.
%
% STOptions must be called with a valid options structure, as defined by
% STIsValidOptionsStruct.  This structure must contain values for all of
% the Spike Toolbox options.  The easiest way to do this is to use STOptions
% to retrieve the current options, modify the returned structure and pass the
% modified structure back to STOptions.  STOptions guarantees to return a
% valid options structure.
%
% Note that modifying the structure is not enough; to set the toolbox options,
% the structure must be passed back to STOptions as an argument.
%
% Various utility functions exist to make setting addressing modes easier.
% See the STAddrSpec... family of functions for details.
%
% STDescribe will print a summary of the toolbox options when passed an
% options structure as an argument.  STOptionsDescribe will describe the
% current toolbox options.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 13th July, 2004

% -- Define globals
global ST_OPTIONS_STRUCTURE_SIGNATURE;
global ST_Options;

% - Does the user want help?
if ((nargin == 0) & (nargout == 0))
   help STOptions;
   return;
end

STCreateGlobals;

% - Check to see if any options are loaded
if (~STIsValidOptionsStruct(ST_Options))
   % - Load the default options from disk
   ST_Options = STOptionsLoad;
end

if (nargout > 0)
   % - The user wants to retrieve the existing / old options
   stOptionsOld = ST_Options;
end

if (nargin > 0)
   % - The user wants to set some options
   % - Check to see if the use has supplied a valid options structure
   if (~STIsValidOptionsStruct(stOptionsNew))
      disp('*** STOptions: Invalid Spike Toolbox options structure provided.')
      disp('       Type "help STOptions" for help on retrieving a valid structure');
   else
      ST_Options = stOptionsNew;
   end
end

% --- END of STOptions.m ---

% $Log: STOptions.m,v $
% Revision 2.4  2005/02/10 13:44:38  dylan
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
% Revision 2.3  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.2  2004/07/29 14:04:29  dylan
% * Fixed a bug in STAddrLogicalExtract where it would incorrectly handle
% addressing specifications with no minor address fields.
%
% * Updated the help for STOptions, making it more verbose.
%
% * Modified the help for STAddrSpecInfo: Added a reference to STDescribe.
%
% * Modifed readme.txt to point to the welcome HTML file.
%
% * Modified the spike_tb_welcome.html file: Added a reference to STDescribe.
%
% * Modified STAddrSpecSynapse2DNeuron: This function now accepts an argument
% 'bXSecond' which can swap the order of the two neuron address fields.
%
% * Added a more explicit description of 'strPlotOptions' to STPlotRaster.
%
% * Updated STFormats to bring it up to date with the new toolbox variable
% formats.
%
% Revision 2.1  2004/07/19 16:21:02  dylan
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