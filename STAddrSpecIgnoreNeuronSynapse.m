function [stasSpecification] = STAddrSpecIgnoreNeuronSynapse(nIgnoreBits, nNeuronBits, nSynapseBits, ...
                                                                nNeuronMax, nSynapseMax, ...
                                                                bInvertNeuron, bInvertSynapse, ...
                                                                bReverseNeuron, bReverseSynapse)

% STAddrSpecIgnoreNeuronSynapse - FUNCTION Address specification utility function
% $Id: STAddrSpecIgnoreNeuronSynapse.m 6114 2007-02-08 09:14:02Z dylan $
%
% Usage: [stasSpecification] = STAddrSpecIgnoreNeuronSynapse(nIgnoreBits, nNeuronBits, nSynapseBits, ...
%                                                               < nSynapseMax, nNeuronMax, ...
%                                                               bInvertNeuron, bInvertSynapse, ...
%                                                               bReverseNeuron, bReverseSynapse >)
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
% See the toolbox documentation for information about address
% specifications.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 25th January, 2005 (modified from STAddrSpecIgnoreSynapseNeuron)
% Copyright (c) 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 9)
   disp('--- STAddrSpecIgnoreNeuronSynapse: Extra arguments ignored');
end

if (nargin < 3)
   disp('*** STAddrSpecIgnoreNeuronSynapse: Incorrect usage');
   help STAddrSpecIgnoreNeuronSynapse;
   return;
end

bRangeCheckSynapse = true;
bRangeCheckNeuron = true;

if (~exist('nSynapseMax', 'var') || isempty(nSynapseMax))
   bRangeCheckSynapse = false;
   nSynapseMax = [];
end

if (~exist('nNeuronMax', 'var') || isempty(nNeuronMax))
   bRangeCheckNeuron = false;
   nNeuronMax = [];
end

if (~exist('bInvertSynapse', 'var') || isempty(bInvertSynapse))
   bInvertSynapse = false;
end

if (~exist('bInvertNeuron', 'var') || isempty(bInvertNeuron))
   bInvertNeuron = false;
end

if (~exist('bReverseSynapse', 'var') || isempty(bReverseSynapse))
   bReverseSynapse = false;
end

if (~exist('bReverseNeuron', 'var') || isempty(bReverseNeuron))
   bReverseNeuron = false;
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
   if (bRangeCheckSynapse || bRangeCheckNeuron)
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
   field.bReverse = bReverseNeuron;
   field.bInvert = bInvertNeuron;
   field.bMajorField = true;
   field.bRangeCheck = bRangeCheckNeuron;
   if (bRangeCheckNeuron || bRangeCheckSynapse)
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
   field.bReverse = bReverseSynapse;
   field.bInvert = bInvertSynapse;
   field.bMajorField = false;
   field.bRangeCheck = bRangeCheckSynapse;
   if (bRangeCheckSynapse || bRangeCheckNeuron)
      field.nMax = nSynapseMax;
   end
   field.bIgnore = false;
   
   stasSpecification(nFieldIndex) = field;
   % nFieldIndex = nFieldIndex + 1;
end


% - Check to make sure it's a valid spec
if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrSpecIgnoreNeuronSynapse: Invalid specification supplied');
   clear stasSpecification;
   return;
end

% --- END of STAddrSpecIgnoreNeuronSynapse.m ---
