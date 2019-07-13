#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul 12 20:13:43 2019

@author: spiros
"""


#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Jun 20 17:33:43 2019

@author: spiros
"""

from brian2 import ms, mV, cm, uF, mS
from brian2 import NeuronGroup, StateMonitor, Network, collect
from brian2 import Synapses, SpikeGeneratorGroup, defaultclock, array
import matplotlib.pyplot as plt

# =============================================================================
# Simulation parameters
simtime         = 100 * ms
defaultclock.dt = 0.1 * ms
# =============================================================================

# =============================================================================
# EXTERNAL INPUTS
indices = array([0])
times = array([50]) * ms
EXT1 = SpikeGeneratorGroup(1, indices, times)
EXT2 = SpikeGeneratorGroup(1, indices, times)

# =============================================================================

print ("Building the Network...")

# Parameters for Excitatory Neurons
E_L       = -80. * mV      # reversal (rest) membrane potential
V_thr     = -45. * mV      # threshold for spike
V_reset   = -80. * mV      # reset potential after an emission of a spike
C_m_E     = 1.0 * uF/cm**2 # membrane capacitance
g_L       = 0.1 * mS/cm**2 # leak conductunce
g_c       = 0.2 * mS/cm**2 # coupling conductance
tau_rp_E  = 2.0 * ms       # refractory period

# Synaptic constants
E_ext     = 0. * mV
g_ext     = 0.1 * mS/cm**2
tau_ext   = 5. * ms


# =============================================================================
# Modeling Pyramidal and Interneurons
# =============================================================================

eqs_E = '''

dv_soma / dt = ( - g_L * ( v_soma - E_L ) - g_c * ( v_soma - v_dend1 ) - g_c * ( v_soma - v_dend2 )) / C_m_E : volt (unless refractory)

dv_dend1 / dt = ( - g_L * ( v_dend1 - E_L ) - g_c * ( v_dend1 - v_soma ) - I_ext1) / C_m_E : volt
dv_dend2 / dt = ( - g_L * ( v_dend2 - E_L ) - g_c * ( v_dend2 - v_soma ) - I_ext2) / C_m_E : volt

I_ext1 = g_ext * ( v_dend1 - E_ext ) * s_ext1 : amp/metre**2
ds_ext1 / dt = - s_ext1 / tau_ext : 1

I_ext2 = g_ext * ( v_dend2 - E_ext ) * s_ext2 : amp/metre**2
ds_ext2 / dt = - s_ext2 / tau_ext : 1

'''


P_E = NeuronGroup(1, eqs_E, threshold='v_soma > V_thr', reset='v_soma = V_reset', refractory=tau_rp_E, method='euler')
P_E.v_soma  = E_L
P_E.v_dend1 = E_L
P_E.v_dend2 = E_L

# =============================================================================
# EXTERNAL STIMULUS/SYNAPSES
S1 = Synapses(EXT1, P_E, model='w : 1', on_pre='s_ext1 += w', method='euler')
S1.connect(j='i') # one-to-one
S1.w[:] = 1

S2 = Synapses(EXT2, P_E, model='w : 1', on_pre='s_ext2 += w', method='euler')
S2.connect(j='i') # one-to-one
S2.w[:] = 0

# =============================================================================


# =============================================================================

M = StateMonitor(P_E, ('v_soma', 'v_dend1', 'v_dend2'), record=True)

# SIMULATION RUNNING
net = Network(collect())
net.add(M)
net.run(simtime, report='stdout')


# =============================================================================
# A N A L Y S I S    o f    t h e    S I M U L A T I O N
# =============================================================================
plt.figure(1)
plt.plot(M.t/ms, M[0].v_soma, label='soma')
plt.plot(M.t/ms, M[0].v_dend1, label='dend1')
plt.plot(M.t/ms, M[0].v_dend2, label='dend2')
plt.xlabel("Time [ms]")
plt.ylabel("Voltage [mV]")
plt.legend(['soma', 'dendrite 1', 'dendrite 2'])

print ("The peak voltage is: ", max(M[0].v_soma)-E_L)