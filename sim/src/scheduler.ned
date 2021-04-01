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

simple IBScheduler
{
    parameters:
        string algorithm;
        string profileTableFile;
        int numSchedulerPorts;
        int networkDelay @unit(ns);
        int computeDelay @unit(ns);
		int availableSLs = default(8);
		int availableVLs = default(2);
        @display("i=abstract/router");
    gates:
        inout ports[];
}


