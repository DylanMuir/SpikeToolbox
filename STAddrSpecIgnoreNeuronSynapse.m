function [stasSpecification] = STAddrSpecIgnoreNeuronSynapse(nIgnoreBits, nNeuronBits, nSynapseBits, ...
                                                                nNeuronMax, nSynapseMax, ...
                                                                bInvertNeuron, bInvertSynapse)

% STAddrSpecIgnoreNeuronSynapse - FUNCTION Address specification utility function
% $Id: STAddrSpecIgnoreNeuronSynapse.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stasSpecification] = STAddrSpecIgnoreNeuronSynapse(nIgnoreBits, nNeuronBits, nSynapseBits)
%        [stasSpecification] = STAddrSpecIgnoreNeuronSynapse(nIgnoreBits, nNeuronBits, nSynapseBits, ...
%                                                               nNeuronMax, nSynapseMax, ...
%                                                               bInvertNeuron, bInvertSynapse)
%
% This function returns an address specification structure for use with the
% Spike Toolbox.  This specification will contain a single ignored address
% field, a single neuron address field and a single synapse address field,
% all with user-specified widths.  The synapse address field is most significant.
%
% The user can optionally specify an integer maximum for each field.  If this
% is supplied then addresses will be range checked.  If a width of zero is
% specified for any field, this field will not be included in the
% specification.
%
% Type 'help STAddrSpecInfo' for information about specifying address formats.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 25th January, 2005 (modified from STAddrSpecIgnoreSynapseNeuron)

% -- Check arguments

if (nargin > 7)
   disp('--- STAddrSpecIgnoreNeuronSynapse: Extra arguments ignored');
end

if (nargin < 3)
   disp('*** STAddrSpecIgnoreNeuronSynapse: Incorrect usage');
   help STAddrSpecIgnoreNeuronSynapse;
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


% - Check to make sure it's a valid spec
if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrSpecIgnoreNeuronSynapse: Invalid specification supplied');
   clear stasSpecification;
   return;
end

% --- END of STAddrSpecIgnoreNeuronSynapse.m ---

% $Log: STAddrSpecIgnoreNeuronSynapse.m,v $
% Revision 2.1  2005/01/25 16:29:27  dylan
% * Created STAddrSpecIgnoreNeuronSynapse.m -- This function constructs an
% addressing specification in the field order required for Giacomo's new chip.
% The syntax is identical to STAddrSpecIgnoreSynapseNeuron.
%
% * Fixed a bug in STAddrSpecIgnoreSynapseNeuron.  The function broke in Matlab
% 7.0.1, when creating an addressing structure with an ignore field and at least
% one other field.  The 'bInvert' field had been swapped with the 'bIgnore' field.
%
