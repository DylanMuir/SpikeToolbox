% STAddrSpecInfo - HELP Help on Spike Toolbox addressing specifcations
% $Id: STAddrSpecInfo.m 124 2005-02-22 16:34:38Z dylan $
% 
% Addresses are now defined in the Spike Toolbox by addressing specification
% structures.  This allows chips with any addressing mode to be stimulated by
% the toolbox, for example 2D arrays of neurons, neurons with 2D arrays of
% synapses, neurons with no addressable synapses, etc.
%
% An addressing specification is a matlab array of structures, with an array
% element for each field in the address.  The minimal information required for
% a valid addressing specification is a field called 'nWidth', which defines
% the number of bits in each field in the address.  Address fields are in
% least to most significant order in the array.
%
% Other structure fields which can be specified:
%    Description  - Provide a text description of the address field
%    bReverse     - Reverse the bits in the field when constructing or
%                      extracting a physical address
%    bInvert      - Perform a binary inversion of the addressing field when
%                      constructing or extarcting a physical address
%    bMajorField  - Fields marked as 'major' will be before the decimal point
%                      in a logical address.  See STAddrLogicalConstruct for
%                      more information
%    bRangeCheck  - This address field should be range checked when addresses
%                      are supplied.  If this structure field is present, then
%                      a structure field 'nMax' specifying the maximum
%                      allowable value must also be provided
%    nMax         - Defines the maximum allowed value for this address field,
%                      when the field is range checked
%    bIgnore      - This address field should be ignored in all addressing
%                      operations.  This option allows bits in an address to
%                      be ignored
%
% Example: For the addressing format
%    |(7)  Neuron address  (5)|(4)  ~(Synapse address)  (2)|(1)  (Ignored)  (0)|
%
% The following structure would be required:
% >> stasSpecification(1)
% ans = 
%     Description: '(Ignored)'
%          nWidth: 2
%        bReverse: 0
%         bInvert: 0
%     bMajorField: 0
%     bRangeCheck: 0
%         bIgnore: 1
% >> stasSpecification(2)
% ans = 
%     Description: 'Synapse address'
%          nWidth: 3
%        bReverse: 0
%         bInvert: 1
%     bMajorField: 0
%     bRangeCheck: 0
%         bIgnore: 0
% >> stasSpecification(3)
% ans = 
%     Description: 'Neuron address'
%          nWidth: 3
%        bReverse: 0
%         bInvert: 0
%     bMajorField: 1
%     bRangeCheck: 0
%         bIgnore: 0
%
%
% The Spike Toolbox supplies several functions for generating useful
% addressing specifications:
%    STAddrSpecIgnoreSynapseNeuron
%    STAddrSpecSynapse2DNeuron
%    STAddrSpecChannel
%
% Type 'help <function name>' for details of using these functions.
%
% For applying a new addressing specification to the spike toolbox, see the
% STOptions function.
%
% Restrictions: Only spike trains using the same addressing mode can be
% multiplexed or concatenated.
%
% STDescribe will print a summary of an addressing specification passed as a
% parameter.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 15th July, 2004

function STAddrSpecInfo

% - Just provide help

help STAddrSpecInfo

% --- END STAddrSpecInfo.m ---

% $Log: STAddrSpecInfo.m,v $
% Revision 2.5  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.4  2004/07/30 10:18:17  dylan
% * Added a new field to addressing specifications: bIgnore will cause a field
% in a hardware address to be binary-inverted when converting to and from
% hardware addresses.
%
% Revision 2.3  2004/07/30 09:00:36  dylan
% Fixed a bug in STAddrSpecIgnoreSYnapseNeuron.m (nonote)
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