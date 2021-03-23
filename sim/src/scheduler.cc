///////////////////////////////////////////////////////////////////////////
//
//         InfiniBand FLIT (Credit) Level OMNet++ Simulation Model
//
// Author: M.R. Siavash Katebzadeh
//
///////////////////////////////////////////////////////////////////////////
//
//
#include "ib_m.h"
#include "scheduler.h"

Define_Module(IBScheduler);

void IBScheduler::initialize() {
    numSchedulerPorts = par("numSchedulerPorts");
    networkDelay_ns = par("networkDelay");
    computeDelay_ns = par("computeDelay");
    if(strcmp(par("algorithm"), "ib") == 0) {
        algorithm = IB;
    } else if(strcmp(par("algorithm"), "idealmaxmin") == 0) {
        algorithm = IDEALMAXMIN;
    } else if(strcmp(par("algorithm"), "bestfitsmart") == 0){
        algorithm = BESTFITSMART;
    } else if(strcmp(par("algorithm"), "hierarchicalsmart") == 0) {
        algorithm = HIERARCHICALSMART;
    } else if(strcmp(par("algorithm"), "idealsmart") == 0) {
        algorithm = IDEALSMART;
    } else {
        algorithm = IB;
        EV << "Scheduler algorithm not found. Fallback to IB" << endl;
    }
}

void IBScheduler::sendSLOut(IBScheduleRepMsg *p_msg) {
    send(p_msg, "ports$o", p_msg->getDstLid());
}

void IBScheduler::handleScheduleReq(IBScheduleReqMsg *p_msg) {
    int sl = p_msg->getSL();
    char name[256];
    sprintf(name, "schedule-response-%d-%d", sl + 1, p_msg->getSrcLid());
    IBScheduleRepMsg *r_msg = new IBScheduleRepMsg(name, IB_SCHEDULE_REP_MSG);

    r_msg->setNewSL(4);
    r_msg->setDstLid(p_msg->getSrcLid() - 1);

    sendSLOut(r_msg);
}

void IBScheduler::handleMessage(cMessage *p_msg) {
    handleScheduleReq((IBScheduleReqMsg *)p_msg);
}

void IBScheduler::finish() {
  EV << "Scheduler STAT ----------------------------------------" << endl;
}

IBScheduler::~IBScheduler() {

}
