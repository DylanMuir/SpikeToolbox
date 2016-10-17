% HELP STFormats - Describe spike train toolbox formats
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
% is specified by 'MAPPING_TEMPORAL_RESOLUTON'.  The address format used by
% 'STMap' to create these trains is defined by 'NEURON_BITS' and
% 'SYNAPSE_BITS'.  See 'STMap' for details of how to create these
% spike trains from an instantiated train.  See 'STConstructLogicalAddress'
% for details of the address format used.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 29th April, 2004

% $Id: STFormats.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

function STFormats

% - Just give help
help STFormats;


% --- END of STFormats.m ---

% $Log: STFormats.m,v $
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