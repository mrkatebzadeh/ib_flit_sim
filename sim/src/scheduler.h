///////////////////////////////////////////////////////////////////////////
//
//         InfiniBand FLIT (Credit) Level OMNet++ Simulation Model
//
// Author: M.R. Siavash Katebzadeh
//
///////////////////////////////////////////////////////////////////////////
//
//


#ifndef __SCHEDULE_H
#define __SCHEDULE_H

#include <omnetpp.h>
#include <vector>
#include <cstring>
#include <fstream>
#include "ib_m.h"
using namespace omnetpp;

enum Algorithm {
    IB,
    IDEALMAXMIN,
    BESTFITSMART,
    HIERARCHICALSMART,
    IDEALSMART
};

struct ProfileRecord {
    int app;
    int bw;
    double time;
    double slowdown;
};

struct BandwidthAllocationRecord {
    int app;
    int src;
    int dst;
    int sl;
    int bw;
};

//
// Allocates BW and Assigns SL
//
class IBScheduler : public cSimpleModule
{
 private:
  // parameters:
  Algorithm algorithm;
  int numSchedulerPorts;
  int networkDelay_ns;
  int computeDelay_ns;
  std::vector<ProfileRecord> profileTable;
  std::vector<BandwidthAllocationRecord> allocationTable;

    // methods
 private:

  void loadProfileTable(const char* profileTableFile);
  void sendSLOut(IBScheduleRepMsg *p_msg);
  void handleScheduleReq(IBScheduleReqMsg *p_msg);
  int calculateSLbyIB(IBScheduleReqMsg *p_msg);
  int calculateSLbyIdealMaxMin(IBScheduleReqMsg *p_msg);
  int calculateSLbyBestFitSmart(IBScheduleReqMsg *p_msg);
  int calculateSLbyHierarchicalSmart(IBScheduleReqMsg *p_msg);
  int calculateSLbyIdealSmart(IBScheduleReqMsg *p_msg);
  virtual ~IBScheduler();
 protected:
  virtual void initialize();
  virtual void handleMessage(cMessage *msg);
  virtual void finish();
};

#endif
