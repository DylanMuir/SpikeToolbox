% STFormats - HELP Describe spike train toolbox formats
% $Id: STFormats.m 124 2005-02-22 16:34:38Z dylan $
%
% -- Spike train definitions
% Describes a desired frequency profile for a spike train in an abstract way.
% The spike toolbox can create trains with a variety of frequency profiles:
% constant frequency, linearly changing between two frequencies or
% sinusoidally changing over time.  See 'STCreate' for details of how to
% specify these definitions.
%
% Note that complex spike trains can be created by concatenating simple trains
% using 'STConcat'.
%
%
% -- Spike train instances
% These spike trains represent a series of spikes from some abstract source.
% Each spike has a real valued time signature.  See 'STInstantiate' for
% details of how to create these spike trains from an abstract definition.
%
%
% -- Spike train mappings
% These spike trains represent a series of spikes to be sent to a specific
% (set of) neuron(s) and synapse(s).  Each spike has an integer 'time step'
% style signature, as well as an address to send the spike to.  The time step
% is specified by the MappingTemporalResolution toolbox option.  The address
% format used by 'STMap' to create these trains is defined by the
% stasDefaultOutputSpecification toolbox option, but a different specification
% can be passed to STMap.  See 'STMap' for details of how to create these
% spike trains from an instantiated train.  See 'STAddrSpecInfo' for details
% of how to define and modify addressing specifications.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 29th April, 2004

function STFormats

% - Just give help
help STFormats;


% --- END of STFormats.m ---

% $Log: STFormats.m,v $
% Revision 2.3  2004/09/16 11:45:22  dylan
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
% Revision 2.0  2004/07/13 12:56:32  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/09 17:55:15  dylan
% * Created STFlatten function to convert a spike train mapping back into an
% instance.
% * Created STExtract function to extract a train(s) from a multiplexed
% mapped spike train
% * Renamed STConstructAddress to STConstructPhysicalAddress
% * Modified the address format for spike train mappings such that the
% integer component of an address specifies the neuron.  This makes raster
% plots much easier to read.  The format is now
% |NEURON_BITS|.|SYNAPSE_BITS|  This is now referred to as a logical
% address.  The format required by the PCIAER board is referred to as a
% physical address.
% * Created STConstructLogicalAddress and STExtractLogicalAddress to
% convert neuron and synapse IDs to and from logical addresses
% * Created STExtractPhysicalAddress to convert a physical address back to
% neuron and synapse IDs
% * Modified STConstructPhysicalAddress so that it accepts vectorised input
% * Modified STConcat so that it accepts cell arrays of spike trains to
% concatenate
% * Modified STExport, STImport so that they handle logical / physical
% addresses
% * Fixed a bug in STMultiplex and STConcat where spike event addresses were
% modified when temporal resolutions were different across spike trains
% * Modified STFormats to reflect addresss format changes
%
% Revision 1.2  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%