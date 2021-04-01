///////////////////////////////////////////////////////////////////////////
//
//         InfiniBand FLIT (Credit) Level OMNet++ Simulation Model
//
// Author: M.R. Siavash Katebzadeh
//
///////////////////////////////////////////////////////////////////////////
//
//
#include <cmath>
#include <numeric>
#include "ib_m.h"
#include "scheduler.h"

Define_Module(IBScheduler);

void IBScheduler::initialize() {
    numSchedulerPorts = par("numSchedulerPorts");
    networkDelay_ns = par("networkDelay");
    computeDelay_ns = par("computeDelay");
    available_SLs = par("availableSLs");
    available_VLs = par("availableVLs");
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
	generateSlowdownTable();
	generateSensitivityTable();
	clusterApplications();
	clusterSLs();
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
        profile_table.push_back(pr);
    }

    myFile.close();
}

void IBScheduler::generateSlowdownTable() {
	for(auto record : profile_table) {
		slowdown_table[record.app].push_back(record.slowdown);
	}
}

void IBScheduler::generateSensitivityTable() {
	// For now, just simple average. //TODO weighted average
	for(auto app : slowdown_table) {
		sensitivity_table[app.first] = std::accumulate(app.second.begin(), app.second.end(), 0.0) / app.second.size();
	}
}

void IBScheduler::clusterApplications() {
	int npoints = sensitivity_table.size();
	int opt_method = HCLUST_METHOD_SINGLE;

	double *distmat = new double[(npoints * (npoints - 1)) / 2];
	int k = 0;

	for (int i = 0; i < npoints; i++) {
    	for (int j = i + 1; j < npoints; j++) {
    		distmat[k] = std::fabs(sensitivity_table[i] - sensitivity_table[j]);
    		k++;
    	}
  	}

	// clustering call
  	int *merge = new int[2 * (npoints - 1)];
  	double *height = new double[npoints - 1];
  	hclust_fast(npoints, distmat, opt_method, merge, height);

  	int *labels = new int[npoints];
  	cutree_k(npoints, merge, available_SLs, labels);

	for (int i = 0; i < npoints; i++) {
		sl_to_app_table[labels[i]].push_back(i);
		app_to_sl_table.push_back(labels[i]);
	}

	// clean up
	delete[] distmat;
	delete[] merge;
	delete[] height;
	delete[] labels;

}

void IBScheduler::clusterSLs() {
	int npoints = available_SLs;
	int opt_method = HCLUST_METHOD_SINGLE;

	double *distmat = new double[(npoints * (npoints - 1)) / 2];
	int k = 0;

	for (int i = 0; i < npoints; i++) {
		double sl1 = std::accumulate(sl_to_app_table[i].begin(), sl_to_app_table[i].end(), 0.0) / sl_to_app_table[i].size();
    	for (int j = i + 1; j < npoints; j++) {
			double sl2 = std::accumulate(sl_to_app_table[j].begin(), sl_to_app_table[j].end(), 0.0) / sl_to_app_table[j].size();
    		distmat[k] = std::fabs(sl1 - sl2);
    		k++;
    	}
  	}

	// clustering call
  	int *merge = new int[2 * (npoints - 1)];
  	double *height = new double[npoints - 1];
  	hclust_fast(npoints, distmat, opt_method, merge, height);

  	int *labels = new int[npoints];
  	cutree_k(npoints, merge, available_VLs, labels);

	for (int i = 0; i < npoints; i++) {
		sl_to_vl_table.push_back(labels[i]);
	}

	// clean up
	delete[] distmat;
	delete[] merge;
	delete[] height;
	delete[] labels;
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
    int srcLid = p_msg->getSrcLid();

    return srcLid;
}

int IBScheduler::calculateSLbyBestFitSmart(IBScheduleReqMsg *p_msg) {

    return 0; //TODO
}

int IBScheduler::calculateSLbyHierarchicalSmart(IBScheduleReqMsg *p_msg) {
    int srcLid = p_msg->getSrcLid();

    return app_to_sl_table[srcLid];
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
