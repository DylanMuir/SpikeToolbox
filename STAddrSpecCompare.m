function [bEquivalent] = STAddrSpecCompare(varargin)

% STAddrSpecCompare - FUNCTION Compare two or more addressing specifications
% $Id: STAddrSpecCompare.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [bEquivalent] = STAddrSpecCompare(stasSpec1, stasSpec2, ...)
%        [bEquivalent] = STAddrSpecCompare(caStas1, caStas2, ...)
%
% STAddrSpecCompare will return true if all the supplied addressing
% specifications are binary-equivalent (same number of fields, same bit widths
% for fields, same bit-reversal specification, etc.)
%
% Addressing specifications can be supplied in cell arrays of specifications or
% as individual arguments.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 18th July, 2004 

% -- Check arguments

if (nargin < 1)
   disp('*** STAddrSpecCompare: Incorrect number of arguments');
   help STAddrSpecCompare;
   return;
end

if ((nargin < 2) & ~iscell(varargin{1}))
   disp('*** STAddrSpecCompare: At least two specifications must be supplied');
   return;
end

% - Extract command line
varargin = CellFlatten(varargin);

% - Test that all are valid specifications
vbValid = CellForEach(@STIsValidAddrSpec, varargin);

if (~min(vbValid))
   % - At least one is invalid, therefore they can't be equivalent
   disp('--- STAddrSpecCompare: At least one invalid addressing specification supplied');
   bEquivalent = false;
   return;
end


% -- Compare specifications

% - Get defining info
nFields = length(varargin{1});
vWidths = [varargin{1}.nWidth];
vbReverseSpecs = [varargin{1}.bReverse];
vbInvertSpecs = [varargin{1}.bInvert];
vbIgnoreSpecs = [varargin{1}.bIgnore];

% - Compare
bEquivalent = false;
for (nSpecIndex = 2:length(varargin))        % Specification 1 is the defining spec
   % - Compare number of fields
   if (length(varargin{nSpecIndex}) ~= nFields)
      return;
   end
   
   % - Compare widths of fields
   if (max([varargin{nSpecIndex}.nWidth] ~= vWidths))
      return;
   end
   
   % - Compare reverse specifications of fields
   if (max([varargin{nSpecIndex}.bReverse] ~= vbReverseSpecs))
      return;
   end
   
   % - Compare invert specifications of fields
   if (max([varargin{nSpecIndex}.bInvert] ~= vbInvertSpecs))
      return;
   end
   
   % - Compare ignore specifications of fields
   if (max([varargin{nSpecIndex}.bIgnore] ~= vbIgnoreSpecs))
      return;
   end
end


% -- The tests were passed

bEquivalent = true;

% --- END of STAddrSpecCompare.m ---

% $Log: STAddrSpecCompare.m,v $
% Revision 2.4  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.3  2004/07/30 10:18:17  dylan
% * Added a new field to addressing specifications: bIgnore will cause a field
% in a hardware address to be binary-inverted when converting to and from
% hardware addresses.
%
% Revision 2.2  2004/07/30 09:00:36  dylan
% Fixed a bug in STAddrSpecIgnoreSYnapseNeuron.m (nonote)
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