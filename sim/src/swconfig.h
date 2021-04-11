/*
* =====================================================================================
*
*       Filename:  swconfig.h
*
*    Description:  
*
*        Version:  1.0
*        Created:  07/04/21 19:49:49
*       Revision:  none
*       Compiler:  gcc
*
*         Author:  M.R. Siavash Katebzadeh (mt.katebzadeh@gmail.com)
*   Organization:  
*
* =====================================================================================
*/


#ifndef __SWCONFIG_H
#define __SWCONFIG_H

#include <omnetpp.h>
#include "ib_m.h"
using namespace omnetpp;

class SWConfig : public cSimpleModule
{
 private:
  // parameters:
  unsigned int numSwitchPorts;

  bool verbose;
  // methods
 private:

  void sendScheduleOut(IBScheduleVLA *p_msg); 
  void handleSchedule(IBScheduleSCF *p_msg); 
  virtual ~SWConfig();
 protected:
  virtual void initialize();
  virtual void handleMessage(cMessage *msg);
  virtual void finish();
};

#endif
