///////////////////////////////////////////////////////////////////////////
//
//         InfiniBand FLIT (Credit) Level OMNet++ Simulation Model
//
// Author: M.R. Siavash Katebzadeh
//
///////////////////////////////////////////////////////////////////////////
//
//
package ib_model;

simple SWConfig
{
	parameters:
		int numSwitchPorts;
    gates:
        input schedule;
        output vlarb_schedule[];
}



