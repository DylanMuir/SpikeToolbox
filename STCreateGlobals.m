function STCreateGlobals

% STCreateGlobals - FUNCTION (Internal) Creates Spike Toolbox global variables
% $Id: STCreateGlobals.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: STCreateGlobals
% NOT for console use

% Auhtor: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 13th July, 2004

% - Create toolbox version string
[null, bNew] = SetDefault('ST_TOOLBOX_VERSION', '0.02');

% - Create options structure signature string
[null, bNew] = SetDefault('ST_OPTIONS_STRUCTURE_SIGNATURE', '''ST_0-02a_OPT''');

% - Create default options file name string
[null, bNew] = SetDefault('ST_OPTIONS_FILE', sprintf('''%s''', fullfile(prefdir, 'st_options_defaults.mat')));

if (bNew)
   % - Display a reminder about seeding
   disp(' ');
   disp('*******************************************************************');
   disp('*** Spike Toolbox: REMEMBER TO SEED THE RANDOM NUMBER GENERATOR ***');
   disp('*******************************************************************');
   disp(' ');
end

% --- END of STCreateGlobals.m ---

% $Log: STCreateGlobals.m,v $
% Revision 2.5  2005/02/10 13:44:38  dylan
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
% Revision 2.4  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.3  2004/08/11 15:35:58  dylan
% (nonote)
%
% Revision 2.2  2004/08/05 09:38:03  dylan
% Changed the default location of preference files to use the Matlab
% preference directory.  You will have to rebuild any custom preferences.
% This does not effect preference files saved in custom locations.
%
% Revision 2.1  2004/07/19 16:21:01  dylan
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
