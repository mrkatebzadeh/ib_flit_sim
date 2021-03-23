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
        EV << "Scheduler algorithm: IB" << endl;
    } else if(strcmp(par("algorithm"), "idealmaxmin") == 0) {
        algorithm = IDEALMAXMIN;
        EV << "Scheduler algorithm: IdealMaxMin" << endl;
    } else if(strcmp(par("algorithm"), "bestfitsmart") == 0){
        algorithm = BESTFITSMART;
        EV << "Scheduler algorithm: BestFitSmart" << endl;
    } else if(strcmp(par("algorithm"), "hierarchicalsmart") == 0) {
        algorithm = HIERARCHICALSMART;
        EV << "Scheduler algorithm: HierarchicalSmart" << endl;
    } else if(strcmp(par("algorithm"), "idealsmart") == 0) {
        algorithm = IDEALSMART;
        EV << "Scheduler algorithm: IdealSmart" << endl;
    } else {
        algorithm = IB;
        EV << "Scheduler algorithm not found. Fallback to IB" << endl;
    }

    const char *profileTableFile = par("profileTableFile");
    loadProfileTable(profileTableFile);
}

void IBScheduler::loadProfileTable(const char* profileTableFile) {
    std::ifstream myFile(profileTableFile);
    std::string line, colname;
    double val;

    if(myFile.good()) {
        // Extract the first line in the file
        std::getline(myFile, line);
    }

    // Read data, line by line
    while(std::getline(myFile, line)) {
        // Create a stringstream of the current line
        ProfileRecord pr;
        std::stringstream ss(line);

        ss >> val;
        pr.app = (int) val;
        if(ss.peek() == ',') ss.ignore();
        ss >> val;
        pr.bw = (int) val;
        if(ss.peek() == ',') ss.ignore();
        ss >> val;
        pr.time =  val;
        if(ss.peek() == ',') ss.ignore();
        ss >> val;
        pr.slowdown = val;
        profileTable.push_back(pr);
    }

    myFile.close();
}

void IBScheduler::sendSLOut(IBScheduleRepMsg *p_msg) {
    send(p_msg, "ports$o", p_msg->getDstLid());
}

void IBScheduler::handleScheduleReq(IBScheduleReqMsg *p_msg) {
    int sl = p_msg->getSL();
    char name[256];
    sprintf(name, "schedule-response-%d-%d", sl + 1, p_msg->getSrcLid());
    IBScheduleRepMsg *r_msg = new IBScheduleRepMsg(name, IB_SCHEDULE_REP_MSG);

    int newSL = sl;
    switch(algorithm){
        case IB:
            newSL = calculateSLbyIB(p_msg);
            break;
        case IDEALMAXMIN:
            newSL = calculateSLbyIdealMaxMin(p_msg);
            break;
        case BESTFITSMART:
            newSL = calculateSLbyBestFitSmart(p_msg);
            break;
        case HIERARCHICALSMART:
            newSL = calculateSLbyHierarchicalSmart(p_msg);
            break;
        case IDEALSMART:
            newSL = calculateSLbyIdealSmart(p_msg);
            break;
        default:
            EV << "Scheduler algorithm not found. Fallback to IB" << endl;
            newSL = calculateSLbyIB(p_msg);
            break;
    }
    r_msg->setNewSL(newSL);
    r_msg->setDstLid(p_msg->getSrcLid() - 1);

    sendSLOut(r_msg);
}

int IBScheduler::calculateSLbyIB(IBScheduleReqMsg *p_msg) {

    return 1;
}

int IBScheduler::calculateSLbyIdealMaxMin(IBScheduleReqMsg *p_msg) {
    int appId = p_msg->getAppIdx();

    return appId;
}

int IBScheduler::calculateSLbyBestFitSmart(IBScheduleReqMsg *p_msg) {

    return 0; //TODO
}

int IBScheduler::calculateSLbyHierarchicalSmart(IBScheduleReqMsg *p_msg) {

    return 0; //TODO
}

int IBScheduler::calculateSLbyIdealSmart(IBScheduleReqMsg *p_msg) {

    return 0; //TODO
}

void IBScheduler::handleMessage(cMessage *p_msg) {
    handleScheduleReq((IBScheduleReqMsg *)p_msg);
}

void IBScheduler::finish() {
  EV << "Scheduler STAT ----------------------------------------" << endl;
  EV << "Algorithm: " << algorithm << endl;
}

IBScheduler::~IBScheduler() {

}
