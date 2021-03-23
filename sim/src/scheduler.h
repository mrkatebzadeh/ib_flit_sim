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
using namespace omnetpp;

#define VERBOSE 0

//
// Allocates BW and Assigns SL
//
class IBScheduler : public cSimpleModule
{
 private:
  // parameters:
  int numSchedulerPorts;
  int networkDelay_ns;
  int computeDelay_ns;

    // methods
 private:

  void sendSLOut(IBScheduleRepMsg *p_msg);
  void handleScheduleReq(IBScheduleReqMsg *p_msg);
  virtual ~IBScheduler();
 protected:
  virtual void initialize();
  virtual void handleMessage(cMessage *msg);
  virtual void finish();
};

#endif
