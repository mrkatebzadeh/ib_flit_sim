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
        int numSchedulerPorts;
        int networkDelay @unit(ns);
        int computeDelay @unit(ns);
        @display("i=abstract/router");
    gates:
        inout ports[];
}


