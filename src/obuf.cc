///////////////////////////////////////////////////////////////////////////
//
//         InfiniBand FLIT (Credit) Level OMNet++ Simulation Model
//
// Copyright (c) 2004-2013 Mellanox Technologies, Ltd. All rights reserved.
// This software is available to you under the terms of the GNU
// General Public License (GPL) Version 2, available from the file
// COPYING in the main directory of this source tree.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
///////////////////////////////////////////////////////////////////////////
//
// The IBOutBuf implements an IB port FIFO
// See functional description in the header file.
//
#include "ib_m.h"
#include "obuf.h"

Define_Module( IBOutBuf );

void IBOutBuf::initialize()
{
  // read parameters
  qSize = par("size");
  maxVL = par("maxVL");

  Enabled = par("enabled");

  // Initiazlize the statistical collection elements
  qDepthHist.setName("Queue Usage");
  qDepthHist.setRangeAutoUpper(0, 10, 1);
  packetStoreHist.setName("Packet Storage Time");
  packetStoreHist.setRangeAutoUpper(0, 10, 1.5);
  flowControlDelay.setName("Time between VL0 FC");
  flowControlDelay.setRangeAutoUpper(0,10,1.2);
  qDepth.setName("Queue Depth");

  curFlowCtrVL = 0;
  totalBytesSent = 0;
  firstPktSendTime = 0;
  flitsSources.setName("Flits Sources");

  p_popMsg = new cMessage("pop", IB_POP_MSG);;

  // queue is empty
  prevPop = IBPopType::NONE;
  prevFCTime = 0;
  pendingFreeCount = 0;

  for ( int i = 0; i < maxVL+1; i++ ) {
    prevSentFCTBS.push_back(-9999);
    prevSentFCCL.push_back(-9999);
    FCCL.push_back(0);
    FCTBS.push_back(0);
  }

  WATCH_VECTOR(prevSentFCTBS);
  WATCH_VECTOR(prevSentFCCL);
  WATCH_VECTOR(FCTBS);
  WATCH_VECTOR(FCCL);

  if (Enabled) {
    // Send the first pop immediately so that all is initialised
    // when we get first packets
    scheduleAt(simTime() , p_popMsg);
  } else {
    ev << "-I- " << getFullPath() << " port DISABLED " << endl;
  }
} // initialize

// send the message out
// Init a new pop message and schedule it after delay
// Note that at this stage the Q might be empty but a
// data packet will be streamed out
void IBOutBuf::sendOutMessage(IBWireMsg *p_msg) {

  EV << "-I- " << getFullPath() << " sending msg:" << p_msg->getName()
     << " at time " << simTime() <<endl;

  // track out going packets
  if ( p_msg->getKind() == IB_DATA_MSG ) {
    IBDataMsg *p_dataMsg = (IBDataMsg *)p_msg;

    // track if we are in the middle of packet
    if ( p_dataMsg->getFlitSn() + 1 == p_dataMsg->getPacketLength() ) {
      EV << "-I- prevPop now DATA_LAST_FLIT\n";
      prevPop = IBPopType::DATA_LAST_FLIT;
    } else {
      EV << "-I- prevPop now DATA_FLIT\n";
      prevPop = IBPopType::DATA_FLIT;
    }

    FCTBS[p_msg->getVL()]++;

    flitsSources.collect(p_dataMsg->getSrcLid());
  }
  send(p_msg, "out");

  if ( ! p_popMsg->isScheduled() ) {
    scheduleAt(gate("out")->getTransmissionChannel()->getTransmissionFinishTime(), p_popMsg);
  }

  if (firstPktSendTime == 0)
    firstPktSendTime = simTime();

  totalBytesSent += p_msg->getByteLength();

} // sendOutMessage

// Q a message to be sent out.
// If there is no pop message pending can directly send...
void
IBOutBuf::qMessage(IBDataMsg *p_msg) {
  // we stamp it to know how much time it stayed with us
  //p_msg->setTimestamp(simTime());

  if ( p_popMsg->isScheduled() ) {
    if ( qSize <= queue.length() ) {
      opp_error("-E- %s  need to insert into a full Q. qSize:%d qLength:%d",
                getFullPath().c_str(), qSize, queue.length());
    }

    EV << "-I- " << getFullPath() << " queued data msg:" << p_msg->getName()
       << " Qdepth " << queue.length() << endl;

    queue.insert(p_msg);
    qDepth.record(queue.length());
    qDepthHist.collect(queue.length());
  } else {
    // track the time this PACKET (all credits) spent in the Q
    // the last credit of a packet always
    if ( p_msg->getFlitSn() + 1 == p_msg->getPacketLength() ) {
      packetStoreHist.collect( simTime() - packetHeadTimeStamp );
    } else if ( p_msg->getFlitSn() == 0 ) {
      packetHeadTimeStamp = p_msg->getTimestamp();
    }
    qDepthHist.collect(0);
    sendOutMessage(p_msg);
  }
} // qMessage

// check if need to send a flow control and send it if required.
// return 1 if sent or 0 if not
// this function should be called by the pop event to check if flow control
// is required to be sent
// The minTime event only zeros out the curFlowCtrVL such that the operation
// restarts.
// New Hermon mode provides extra cases where a flow control might be sent:
// 1. If there are no other messages in the Q
//
// Also if there are messages in the Q we might not send FC unless the
// difference is large enough
int IBOutBuf::sendFlowControl()
{
  static long flowCtrlId = 0;
  int sentUpdate = 0;

  // we should not continue if the Q is not empty if we aren't in mintime mode
  if (! queue.empty())
    return(0);

  if (curFlowCtrVL >= maxVL+1) {
    curFlowCtrVL = 0;
  }

  for (; (sentUpdate == 0) && (curFlowCtrVL < maxVL+1); curFlowCtrVL++ ) {
    int i = curFlowCtrVL;

    if (i == 0) {
      // avoid the first send...
      if (prevFCTime != 0)
        flowControlDelay.collect(simTime() - prevFCTime);
      prevFCTime = simTime();
    }

    // We may have ignored prevSentFCTBS[i] == FCTBS[i] since the other side
    // tracks ABR but the spec asks us to send anyways
    if ( (prevSentFCTBS[i] != FCTBS[i]) || (prevSentFCCL[i] != FCCL[i]) ) {
      // create a new message and place in the Q
      char name[128];
      sprintf(name, "fc-%d-%ld", i, flowCtrlId++);
      IBFlowControl *p_msg = new IBFlowControl(name, IB_FLOWCTRL_MSG);

      p_msg->setBitLength(8*8);
      p_msg->setVL(i);
      p_msg->setFCCL(FCCL[i]);
      p_msg->setFCTBS(FCTBS[i]);
      prevSentFCCL[i] = FCCL[i];
      prevSentFCTBS[i] = FCTBS[i];
      EV << "-I- " << getFullPath() << " generated:" << p_msg->getName()
         << " vl: " << p_msg->getVL() << " FCTBS: "
         << p_msg->getFCTBS() << " FCCL: " << p_msg->getFCCL() << endl;

      // we do not need to Q as we are only called in pop
      sendOutMessage(p_msg);
      sentUpdate = 1;
    }
  }

  return(sentUpdate);
}

// Handle Pop Message
// Should not be called if the Q is empty.
// Simply pop and schedule next pop.
// Also schedule a "free" message to be sent out later
void IBOutBuf::handlePop()
{
  cancelEvent( p_popMsg );

  // if we got a pop - it means the previous message just left the
  // OBUF. In that case if it was a data credit packet we have now a
  // new space for it. tell the VLA.
  if (pendingFreeCount > 0) {
    cMessage *p_msg = new cMessage("free", IB_FREE_MSG);
    EV << "-I- " << getFullPath() << " sending 'free' to VLA as last "
       << " packet just completed." << endl;
    send(p_msg, "free");
    --pendingFreeCount;
  }

  if (prevPop != IBPopType::DATA_FLIT) {
    if (sendFlowControl()) {
      EV << "-I- prevPop now FC_PACKET\n";
      prevPop = IBPopType::FC_PACKET;
      return;
    }
  }

  // got to pop from the queue if anything there
  if ( !queue.empty() ) {
    IBWireMsg *p_msg = (IBWireMsg *)queue.pop();
    if ( p_msg->getKind() == IB_DATA_MSG ) {
      IBDataMsg *p_cred = (IBDataMsg *)p_msg;
      EV << "-I- " << getFullPath() << " popped data message:"
         << p_cred->getName() << endl;
      ++pendingFreeCount;
      sendOutMessage(p_msg);

      // we just popped a real credit
      // track the time this PACKET (all credits) spent in the Q
      // the last credit of a packet always
      if ( p_cred->getFlitSn() + 1 == p_cred->getPacketLength() ) {
        packetStoreHist.collect( simTime() - packetHeadTimeStamp );
      } else if ( p_cred->getFlitSn() == 0 ) {
        packetHeadTimeStamp = p_msg->getTimestamp();
      }
    } else {
      EV << "-E- " << getFullPath() << " unknown message type to pop:"
         << p_msg->getKind() << endl;
    }
  } else {
    // The queue is empty. Next message needs to immediately pop
    // so we clean this event
    EV << "-I- " << getFullPath() << " nothing to POP" << endl;
    if (prevPop != IBPopType::DATA_FLIT) {
      EV << "-I- prevPop now NONE\n";
      prevPop = IBPopType::NONE;
    }
  }

  qDepth.record(queue.length());
} // handlePop

// Handle rxCred
void IBOutBuf::handleRxCred(IBRxCredMsg *p_msg)
{
  // update FCCL...
  FCCL[p_msg->getVL()] = p_msg->getFCCL();
  delete p_msg;

  if (!p_popMsg->isScheduled()) {
      handlePop();
  }
}

void IBOutBuf::handleMessage(cMessage *p_msg)
{
  int msgType = p_msg->getKind();
  if ( msgType == IB_POP_MSG ) {
    handlePop();
  } else if ( msgType == IB_DATA_MSG ) {
    qMessage((IBDataMsg*)p_msg);
  } else if ( msgType == IB_RXCRED_MSG ) {
    handleRxCred((IBRxCredMsg*)p_msg);
  } else {
    EV << "-E- " << getFullPath() << " do no know how to handle message:"
       << msgType << endl;
    delete p_msg;
  }
}

void IBOutBuf::finish()
{
    EV << "STAT: " << getFullPath() << " Data Packet Q time num/avg/max/std:"
     << packetStoreHist.getCount() << " / "
     << packetStoreHist.getMean() << " / "
     << packetStoreHist.getMax() << " / "
     << packetStoreHist.getStddev() << endl;
    EV << "STAT: " << getFullPath() << " Q depth num/avg/max/std:"
     << qDepthHist.getCount() << " / "
     << qDepthHist.getMean() << " / "
     << qDepthHist.getMax() << " / "
     << qDepthHist.getStddev() << endl;
    EV << "STAT: " << getFullPath() << " FlowControl Delay num/avg/max/std:"
     << flowControlDelay.getCount() << " / "
     << flowControlDelay.getMean() << " / "
     << flowControlDelay.getMax() << " / "
     << flowControlDelay.getStddev() << endl;
  double oBW = totalBytesSent / (simTime() - firstPktSendTime);
  recordScalar("Output BW (Byte/Sec)", oBW);
  flitsSources.record();
  EV << "STAT: " << getFullPath() << " Flit Sources:" << endl << flitsSources.detailedInfo() << endl;
}

IBOutBuf::~IBOutBuf() {
  if (p_popMsg) cancelAndDelete(p_popMsg);
}
