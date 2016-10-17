function [stasSpecification] = STAddrSpecIgnoreSynapseNeuron(nIgnoreBits, nSynapseBits, nNeuronBits, ...
                                                                nSynapseMax, nNeuronMax, ...
                                                                bInvertSynapse, bInvertNeuron)

% STAddrSpecIgnoreSynapseNeuron - FUNCTION Address specification utility function
% $Id: STAddrSpecIgnoreSynapseNeuron.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stasSpecification] = STAddrSpecIgnoreSynapseNeuron(nIgnoreBits, nSynapseBits, nNeuronBits)
%        [stasSpecification] = STAddrSpecIgnoreSynapseNeuron(nIgnoreBits, nSynapseBits, nNeuronBits, ...
%                                                               nSynapseMax, nNeuronMax, ...
%                                                               bInvertSynapse, bInvertNeuron)
%
% This function returns an address specification structure for use with the
% Spike Toolbox.  This specification will contain a single ignored address
% field, a single synapse address field and a single neuron address field,
% all with user-specified widths.  The neuron address field is most significant.
%
% The user can optionally specify an integer maximum for each field.  If this
% is supplied, then addresses will be range checked.  If a width of zero is
% specified for any field, this field will not be included in the
% specification.
%
% Type 'help STAddrSpecInfo' for information about specifying address formats.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004

% -- Check arguments

if (nargin > 7)
   disp('--- STAddrSpecIgnoreSynapseNeuron: Extra arguments ignored');
end

if (nargin < 3)
   disp('*** STAddrSpecIgnoreSynapseNeuron: Incorrect usage');
   help STAddrSpecIgnoreSynapseNeuron;
   return;
end

bRangeCheckSynapse = true;
bRangeCheckNeuron = true;

if (nargin < 4)
   bRangeCheckSynapse = false;
   nSynapseMax = [];
end

if (nargin < 5)
   bRangeCheckNeuron = false;
   nNeuronMax = [];
end

if (nargin < 6)
   bInvertSynapse = false;
end

if (nargin < 7)
   bInvertNeuron = false;
end


% -- Make the address specification structure

nFieldIndex = 1;

if (nIgnoreBits > 0)
   % - 'Ignore' address field
   field.Description = '(Ignored)';
   field.nWidth = nIgnoreBits;
   field.bReverse = false;
   field.bInvert = false;
   field.bMajorField = false;
   field.bRangeCheck = false;
   if (bRangeCheckSynapse | bRangeCheckNeuron)
      field.nMax = [];
   end
   field.bIgnore = true;
   
   stasSpecification(nFieldIndex) = field;
   nFieldIndex = nFieldIndex + 1;
end

if (nSynapseBits > 0)
   % - Synapse address field
   clear field;
   field.Description = 'Synapse address';
   field.nWidth = nSynapseBits;
   field.bReverse = false;
   field.bInvert = bInvertSynapse;
   field.bMajorField = false;
   field.bRangeCheck = bRangeCheckSynapse;
   if (bRangeCheckSynapse | bRangeCheckNeuron)
      field.nMax = nSynapseMax;
   end
   field.bIgnore = false;
   
   stasSpecification(nFieldIndex) = field;
   nFieldIndex = nFieldIndex + 1;
end

if (nNeuronBits > 0)
   % - Neuron address field
   clear field;
   field.Description = 'Neuron address';
   field.nWidth = nNeuronBits;
   field.bReverse = false;
   field.bInvert = bInvertNeuron;
   field.bMajorField = true;
   field.bRangeCheck = bRangeCheckNeuron;
   if (bRangeCheckNeuron | bRangeCheckSynapse)
      field.nMax = nNeuronMax;
   end
   field.bIgnore = false;

   stasSpecification(nFieldIndex) = field;
   nFieldIndex = nFieldIndex + 1;
end


% - Check to make sure it's a valid spec
if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrSpecIgnoreSynapseNeuron: Invalid specification supplied');
   clear stasSpecification;
   return;
end

% --- END of STAddrSpecIgnoreSynapseNeuron.m ---

% $Log: STAddrSpecIgnoreSynapseNeuron.m,v $
% Revision 2.4  2005/01/25 16:29:27  dylan
% * Created STAddrSpecIgnoreNeuronSynapse.m -- This function constructs an
% addressing specification in the field order required for Giacomo's new chip.
% The syntax is identical to STAddrSpecIgnoreSynapseNeuron.
%
% * Fixed a bug in STAddrSpecIgnoreSynapseNeuron.  The function broke in Matlab
% 7.0.1, when creating an addressing structure with an ignore field and at least
% one other field.  The 'bInvert' field had been swapped with the 'bIgnore' field.
%
% Revision 2.3  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
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
