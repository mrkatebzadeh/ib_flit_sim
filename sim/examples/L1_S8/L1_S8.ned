package ib_model.examples.L1_S8;

import ib_model.*;

network L1_S8
{
    @display("bgb=592,287");
    submodules:
        H_1_U1: HCA {
            parameters:
                srcLid = 1;
                @display("p=470,140");
        }
        H_2_U1: HCA {
            parameters:
                srcLid = 2;
                @display("p=258,249");
        }
        H_3_U1: HCA {
            parameters:
                srcLid = 3;
                @display("p=152,249");
        }
        H_4_U1: HCA {
            parameters:
                srcLid = 4;
                @display("p=72,210");
        }
        H_5_U1: HCA {
            parameters:
                srcLid = 5;
                @display("p=72,136");
        }
        H_6_U1: HCA {
            parameters:
                srcLid = 6;
                @display("p=110,48");
        }
        H_7_U1: HCA {
            parameters:
                srcLid = 7;
                @display("p=198,31");
        }
        H_8_U1: HCA {
            parameters:
                srcLid = 8;
                @display("p=277,39");
        }
        SW_L0_0_0_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=232,136");
            gates:
                port[8];
        }

    connections:
        H_1_U1.port <--> IB4XSDRWire <--> SW_L0_0_0_U1.port[0];
        H_2_U1.port <--> IB4XSDRWire <--> SW_L0_0_0_U1.port[1];
        H_3_U1.port <--> IB4XSDRWire <--> SW_L0_0_0_U1.port[2];
        H_4_U1.port <--> IB4XSDRWire <--> SW_L0_0_0_U1.port[3];
        H_5_U1.port <--> IB4XSDRWire <--> SW_L0_0_0_U1.port[4];
        H_6_U1.port <--> IB4XSDRWire <--> SW_L0_0_0_U1.port[5];
        H_7_U1.port <--> IB4XSDRWire <--> SW_L0_0_0_U1.port[6];
        H_8_U1.port <--> IB4XSDRWire <--> SW_L0_0_0_U1.port[7];

}
