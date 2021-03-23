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
package ib_model;

module ISwitchPort
{
    parameters:
        int numSwitchPorts;
        int switchMaxVL = default(1);

        @display("bgb=249,215");
    gates:
        inout port;				// port to outside the switch
        inout sw_port[];		// inner switch port (between SwitchPorts)
        inout sw_sent_port[];	// inner sent msgs ports

    submodules:
        obuf: IBOutBuf {
            parameters:
                maxVL = switchMaxVL;
                @display("i=block/boundedqueue;p=76,80");
        }
        ibuf: IBInBuf {
            parameters:
                maxVL = switchMaxVL;
                isHcaIBuf = 0;
                numPorts = numSwitchPorts;
                @display("i=block/subqueue;p=191,80");
            gates:
                out[numSwitchPorts];
                sent[numSwitchPorts];
        }
        vlarb: IBVLArb {
            parameters:
                maxVL = switchMaxVL;
                isHcaArbiter = 0;
                numPorts = numSwitchPorts;
		        useFCFSRQArb = true;
                @display("p=191,156;i=block/dispatch");
            gates:
                in[numSwitchPorts];
                sent[numSwitchPorts];

        }
    connections:
        obuf.out --> port$o;
        port$i --> ibuf.in;
        for i=0..numSwitchPorts-1 {
            //vlarb.sent[i] --> sw_out_sent[i];
            vlarb.sent[i] --> sw_sent_port$o[i];
            //sw_in_sent[i] --> ibuf.sent[i];
            sw_sent_port$i[i] --> ibuf.sent[i];
            //ibuf.out[i] --> sw_out[i];
            ibuf.out[i] --> sw_port$o[i];
            //sw_in[i] --> vlarb.in[i];
            sw_port$i[i] --> vlarb.in[i];
        }

        ibuf.rxCred --> obuf.rxCred;
        ibuf.txCred --> vlarb.txCred;
        vlarb.out --> obuf.in;
        obuf.free --> vlarb.free;

}

module ISwitch
{
    parameters:
        int numSwitchPorts;     // Total num of switch ports
        int ISWDelay @unit(ns); // Delay brought by IBUF in SWitch
        int VSWDelay @unit(ns); // Delay in ns brought by IBUF in SWitch
		string pktFwdType;         // The type of the packet forwarding engine to use
        @display("i=abstract/router");
    gates:
        inout port[];

    submodules:
        pktfwd : < pktFwdType > like ib_model.PktFwd_Ifc {
            parameters:
                numPorts = numSwitchPorts;
        }
        ports[numSwitchPorts]: ISwitchPort {
            parameters:
                numSwitchPorts = numSwitchPorts;
                @display("p=90,44;b=48,32");
            gates:
                sw_port[numSwitchPorts];
                sw_sent_port[numSwitchPorts];

        }
    connections:
        for p=0..numSwitchPorts-1 {
            port[p] <--> ports[p].port;

            // Loopback for inner switch ports in according ports array.
            ports[p].sw_port$o[p] --> ports[p].sw_port$i[p];
            ports[p].sw_sent_port$o[p] --> ports[p].sw_sent_port$i[p];
        }
        for p=0..numSwitchPorts-1, for i=p+1..numSwitchPorts-1 {
            ports[p].sw_port[i] <--> ports[i].sw_port[p];
            //port[p].sw_out[i] --> port[i].sw_in[p];
            ports[p].sw_sent_port[i] <--> ports[i].sw_sent_port[p];
            //port[p].sw_out_sent[i] --> port[i].sw_in_sent[p];
        }
}
