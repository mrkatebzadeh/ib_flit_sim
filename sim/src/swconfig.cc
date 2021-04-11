/*
 * =====================================================================================
 *
 *       Filename:  swconfig.cc
 *
 *    Description:
 *
 *        Version:  1.0
 *        Created:  07/04/21 22:25:26
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  M. R. Siavash Katebzadeh (mr.katebzadeh@gmail.com)
 *   Organization:
 *
 * =====================================================================================
 */

#include "swconfig.h"

#include "ib_m.h"
#include "vec_file.h"
#include "vlarb.h"

Define_Module(SWConfig);

// main init of the module
void SWConfig::initialize() { 
	numSwitchPorts = par("numSwitchPorts");
}


void SWConfig::sendScheduleOut(IBScheduleVLA *p_msg) {
    send(p_msg, "schedule$o");
}

void SWConfig::handleSchedule(IBScheduleSCF *p_msg) {}

void SWConfig::handleMessage(cMessage *p_msg) {
    handleSchedule((IBScheduleSCF *)p_msg);
}

void SWConfig::finish() {}

SWConfig::~SWConfig() {}
