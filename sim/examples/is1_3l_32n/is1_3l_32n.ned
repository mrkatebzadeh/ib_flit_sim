package ib_model.examples.is1_3l_32n;

import ib_model.*;

network is1_3l_32n
{
    @display("bgb=1353,581");
    submodules:
        H_1_U1: HCA {
            parameters:
                srcLid = 1;
                @display("p=303,509");
        }
        H_10_U1: HCA {
            parameters:
                srcLid = 10;
                @display("p=644,512");
        }
        H_11_U1: HCA {
            parameters:
                srcLid = 11;
                @display("p=542,517");
        }
        H_12_U1: HCA {
            parameters:
                srcLid = 12;
                @display("p=571,517");
        }
        H_13_U1: HCA {
            parameters:
                srcLid = 13;
                @display("p=446,523");
        }
        H_14_U1: HCA {
            parameters:
                srcLid = 14;
                @display("p=392,501");
        }
        H_15_U1: HCA {
            parameters:
                srcLid = 15;
                @display("p=407,523");
        }
        H_16_U1: HCA {
            parameters:
                srcLid = 16;
                @display("p=480,512");
        }
        H_17_U1: HCA {
            parameters:
                srcLid = 17;
                @display("p=965,519");
        }
        H_18_U1: HCA {
            parameters:
                srcLid = 18;
                @display("p=936,523");
        }
        H_19_U1: HCA {
            parameters:
                srcLid = 19;
                @display("p=878,523");
        }
        H_2_U1: HCA {
            parameters:
                srcLid = 2;
                @display("p=275,516");
        }
        H_20_U1: HCA {
            parameters:
                srcLid = 20;
                @display("p=907,524");
        }
        H_21_U1: HCA {
            parameters:
                srcLid = 21;
                @display("p=708,519");
        }
        H_22_U1: HCA {
            parameters:
                srcLid = 22;
                @display("p=730,519");
        }
        H_23_U1: HCA {
            parameters:
                srcLid = 23;
                @display("p=800,519");
        }
        H_24_U1: HCA {
            parameters:
                srcLid = 24;
                @display("p=766,519");
        }
        H_25_U1: HCA {
            parameters:
                srcLid = 25;
                @display("p=1276,501");
        }
        H_26_U1: HCA {
            parameters:
                srcLid = 26;
                @display("p=1213,513");
        }
        H_27_U1: HCA {
            parameters:
                srcLid = 27;
                @display("p=1198,489");
        }
        H_28_U1: HCA {
            parameters:
                srcLid = 28;
                @display("p=1242,512");
        }
        H_29_U1: HCA {
            parameters:
                srcLid = 29;
                @display("p=1057,517");
        }
        H_3_U1: HCA {
            parameters:
                srcLid = 3;
                @display("p=332,516");
        }
        H_30_U1: HCA {
            parameters:
                srcLid = 30;
                @display("p=1110,525");
        }
        H_31_U1: HCA {
            parameters:
                srcLid = 31;
                @display("p=1081,525");
        }
        H_32_U1: HCA {
            parameters:
                srcLid = 32;
                @display("p=1129,525");
        }
        H_4_U1: HCA {
            parameters:
                srcLid = 4;
                @display("p=259,508");
        }
        H_5_U1: HCA {
            parameters:
                srcLid = 5;
                @display("p=164,500");
        }
        H_6_U1: HCA {
            parameters:
                srcLid = 6;
                @display("p=135,500");
        }
        H_7_U1: HCA {
            parameters:
                srcLid = 7;
                @display("p=117,509");
        }
        H_8_U1: HCA {
            parameters:
                srcLid = 8;
                @display("p=178,509");
        }
        H_9_U1: HCA {
            parameters:
                srcLid = 9;
                @display("p=610,531");
        }
        SW_L0_0_0_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=259,101");
            gates:
                port[8];
        }
        SW_L0_0_1_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=521,101");
            gates:
                port[8];
        }
        SW_L0_1_0_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=857,101");
            gates:
                port[8];
        }
        SW_L0_1_1_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=1134,101");
            gates:
                port[8];
        }
        SW_L1_0_0_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=151,307");
            gates:
                port[8];
        }
        SW_L1_0_1_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=304,307");
            gates:
                port[8];
        }
        SW_L1_1_0_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=508,307");
            gates:
                port[8];
        }
        SW_L1_1_1_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=644,307");
            gates:
                port[8];
        }
        SW_L1_2_0_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=818,307");
            gates:
                port[8];
        }
        SW_L1_2_1_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=951,307");
            gates:
                port[8];
        }
        SW_L1_3_0_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=1115,307");
            gates:
                port[8];
        }
        SW_L1_3_1_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=1262,307");
            gates:
                port[8];
        }
        SW_L2_0_0_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=304,478");
            gates:
                port[8];
        }
        SW_L2_0_1_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=151,478");
            gates:
                port[8];
        }
        SW_L2_1_0_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=586,470");
            gates:
                port[8];
        }
        SW_L2_1_1_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=446,465");
            gates:
                port[8];
        }
        SW_L2_2_0_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=912,478");
            gates:
                port[8];
        }
        SW_L2_2_1_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=735,465");
            gates:
                port[8];
        }
        SW_L2_3_0_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=1242,478");
            gates:
                port[8];
        }
        SW_L2_3_1_U1: Switch {
            parameters:
                numSwitchPorts = 8;
                @display("p=1095,478");
            gates:
                port[8];
        }
    connections:
        H_1_U1.port <--> IB4XQDRWire <--> SW_L2_0_0_U1.port[0];
        H_10_U1.port <--> IB4XQDRWire <--> SW_L2_1_0_U1.port[1];
        H_11_U1.port <--> IB4XQDRWire <--> SW_L2_1_0_U1.port[2];
        H_12_U1.port <--> IB4XQDRWire <--> SW_L2_1_0_U1.port[3];
        H_13_U1.port <--> IB4XQDRWire <--> SW_L2_1_1_U1.port[0];
        H_14_U1.port <--> IB4XQDRWire <--> SW_L2_1_1_U1.port[1];
        H_15_U1.port <--> IB4XQDRWire <--> SW_L2_1_1_U1.port[2];
        H_16_U1.port <--> IB4XQDRWire <--> SW_L2_1_1_U1.port[3];
        H_17_U1.port <--> IB4XQDRWire <--> SW_L2_2_0_U1.port[0];
        H_18_U1.port <--> IB4XQDRWire <--> SW_L2_2_0_U1.port[1];
        H_19_U1.port <--> IB4XQDRWire <--> SW_L2_2_0_U1.port[2];
        H_2_U1.port <--> IB4XQDRWire <--> SW_L2_0_0_U1.port[1];
        H_20_U1.port <--> IB4XQDRWire <--> SW_L2_2_0_U1.port[3];
        H_21_U1.port <--> IB4XQDRWire <--> SW_L2_2_1_U1.port[0];
        H_22_U1.port <--> IB4XQDRWire <--> SW_L2_2_1_U1.port[1];
        H_23_U1.port <--> IB4XQDRWire <--> SW_L2_2_1_U1.port[2];
        H_24_U1.port <--> IB4XQDRWire <--> SW_L2_2_1_U1.port[3];
        H_25_U1.port <--> IB4XQDRWire <--> SW_L2_3_0_U1.port[0];
        H_26_U1.port <--> IB4XQDRWire <--> SW_L2_3_0_U1.port[1];
        H_27_U1.port <--> IB4XQDRWire <--> SW_L2_3_0_U1.port[2];
        H_28_U1.port <--> IB4XQDRWire <--> SW_L2_3_0_U1.port[3];
        H_29_U1.port <--> IB4XQDRWire <--> SW_L2_3_1_U1.port[0];
        H_3_U1.port <--> IB4XQDRWire <--> SW_L2_0_0_U1.port[2];
        H_30_U1.port <--> IB4XQDRWire <--> SW_L2_3_1_U1.port[1];
        H_31_U1.port <--> IB4XQDRWire <--> SW_L2_3_1_U1.port[2];
        H_32_U1.port <--> IB4XQDRWire <--> SW_L2_3_1_U1.port[3];
        H_4_U1.port <--> IB4XQDRWire <--> SW_L2_0_0_U1.port[3];
        H_5_U1.port <--> IB4XQDRWire <--> SW_L2_0_1_U1.port[0];
        H_6_U1.port <--> IB4XQDRWire <--> SW_L2_0_1_U1.port[1];
        H_7_U1.port <--> IB4XQDRWire <--> SW_L2_0_1_U1.port[2];
        H_8_U1.port <--> IB4XQDRWire <--> SW_L2_0_1_U1.port[3];
        H_9_U1.port <--> IB4XQDRWire <--> SW_L2_1_0_U1.port[0];
        SW_L0_0_0_U1.port[0] <--> IB4XQDRWire <--> SW_L1_0_0_U1.port[4];
        SW_L0_0_0_U1.port[1] <--> IB4XQDRWire <--> SW_L1_0_0_U1.port[5];
        SW_L0_0_0_U1.port[2] <--> IB4XQDRWire <--> SW_L1_1_0_U1.port[4];
        SW_L0_0_0_U1.port[3] <--> IB4XQDRWire <--> SW_L1_1_0_U1.port[5];
        SW_L0_0_0_U1.port[4] <--> IB4XQDRWire <--> SW_L1_2_0_U1.port[4];
        SW_L0_0_0_U1.port[5] <--> IB4XQDRWire <--> SW_L1_2_0_U1.port[5];
        SW_L0_0_0_U1.port[6] <--> IB4XQDRWire <--> SW_L1_3_0_U1.port[4];
        SW_L0_0_0_U1.port[7] <--> IB4XQDRWire <--> SW_L1_3_0_U1.port[5];
        SW_L0_0_1_U1.port[0] <--> IB4XQDRWire <--> SW_L1_0_1_U1.port[4];
        SW_L0_0_1_U1.port[1] <--> IB4XQDRWire <--> SW_L1_0_1_U1.port[5];
        SW_L0_0_1_U1.port[2] <--> IB4XQDRWire <--> SW_L1_1_1_U1.port[4];
        SW_L0_0_1_U1.port[3] <--> IB4XQDRWire <--> SW_L1_1_1_U1.port[5];
        SW_L0_0_1_U1.port[4] <--> IB4XQDRWire <--> SW_L1_2_1_U1.port[4];
        SW_L0_0_1_U1.port[5] <--> IB4XQDRWire <--> SW_L1_2_1_U1.port[5];
        SW_L0_0_1_U1.port[6] <--> IB4XQDRWire <--> SW_L1_3_1_U1.port[4];
        SW_L0_0_1_U1.port[7] <--> IB4XQDRWire <--> SW_L1_3_1_U1.port[5];
        SW_L0_1_0_U1.port[0] <--> IB4XQDRWire <--> SW_L1_0_0_U1.port[6];
        SW_L0_1_0_U1.port[1] <--> IB4XQDRWire <--> SW_L1_0_0_U1.port[7];
        SW_L0_1_0_U1.port[2] <--> IB4XQDRWire <--> SW_L1_1_0_U1.port[6];
        SW_L0_1_0_U1.port[3] <--> IB4XQDRWire <--> SW_L1_1_0_U1.port[7];
        SW_L0_1_0_U1.port[4] <--> IB4XQDRWire <--> SW_L1_2_0_U1.port[6];
        SW_L0_1_0_U1.port[5] <--> IB4XQDRWire <--> SW_L1_2_0_U1.port[7];
        SW_L0_1_0_U1.port[6] <--> IB4XQDRWire <--> SW_L1_3_0_U1.port[6];
        SW_L0_1_0_U1.port[7] <--> IB4XQDRWire <--> SW_L1_3_0_U1.port[7];
        SW_L0_1_1_U1.port[0] <--> IB4XQDRWire <--> SW_L1_0_1_U1.port[6];
        SW_L0_1_1_U1.port[1] <--> IB4XQDRWire <--> SW_L1_0_1_U1.port[7];
        SW_L0_1_1_U1.port[2] <--> IB4XQDRWire <--> SW_L1_1_1_U1.port[6];
        SW_L0_1_1_U1.port[3] <--> IB4XQDRWire <--> SW_L1_1_1_U1.port[7];
        SW_L0_1_1_U1.port[4] <--> IB4XQDRWire <--> SW_L1_2_1_U1.port[6];
        SW_L0_1_1_U1.port[5] <--> IB4XQDRWire <--> SW_L1_2_1_U1.port[7];
        SW_L0_1_1_U1.port[6] <--> IB4XQDRWire <--> SW_L1_3_1_U1.port[6];
        SW_L0_1_1_U1.port[7] <--> IB4XQDRWire <--> SW_L1_3_1_U1.port[7];
        SW_L1_0_0_U1.port[0] <--> IB4XQDRWire <--> SW_L2_0_0_U1.port[4];
        SW_L1_0_0_U1.port[1] <--> IB4XQDRWire <--> SW_L2_0_0_U1.port[5];
        SW_L1_0_0_U1.port[2] <--> IB4XQDRWire <--> SW_L2_0_1_U1.port[4];
        SW_L1_0_0_U1.port[3] <--> IB4XQDRWire <--> SW_L2_0_1_U1.port[5];
        SW_L1_0_1_U1.port[0] <--> IB4XQDRWire <--> SW_L2_0_0_U1.port[6];
        SW_L1_0_1_U1.port[1] <--> IB4XQDRWire <--> SW_L2_0_0_U1.port[7];
        SW_L1_0_1_U1.port[2] <--> IB4XQDRWire <--> SW_L2_0_1_U1.port[6];
        SW_L1_0_1_U1.port[3] <--> IB4XQDRWire <--> SW_L2_0_1_U1.port[7];
        SW_L1_1_0_U1.port[0] <--> IB4XQDRWire <--> SW_L2_1_0_U1.port[4];
        SW_L1_1_0_U1.port[1] <--> IB4XQDRWire <--> SW_L2_1_0_U1.port[5];
        SW_L1_1_0_U1.port[2] <--> IB4XQDRWire <--> SW_L2_1_1_U1.port[4];
        SW_L1_1_0_U1.port[3] <--> IB4XQDRWire <--> SW_L2_1_1_U1.port[5];
        SW_L1_1_1_U1.port[0] <--> IB4XQDRWire <--> SW_L2_1_0_U1.port[6];
        SW_L1_1_1_U1.port[1] <--> IB4XQDRWire <--> SW_L2_1_0_U1.port[7];
        SW_L1_1_1_U1.port[2] <--> IB4XQDRWire <--> SW_L2_1_1_U1.port[6];
        SW_L1_1_1_U1.port[3] <--> IB4XQDRWire <--> SW_L2_1_1_U1.port[7];
        SW_L1_2_0_U1.port[0] <--> IB4XQDRWire <--> SW_L2_2_0_U1.port[4];
        SW_L1_2_0_U1.port[1] <--> IB4XQDRWire <--> SW_L2_2_0_U1.port[5];
        SW_L1_2_0_U1.port[2] <--> IB4XQDRWire <--> SW_L2_2_1_U1.port[4];
        SW_L1_2_0_U1.port[3] <--> IB4XQDRWire <--> SW_L2_2_1_U1.port[5];
        SW_L1_2_1_U1.port[0] <--> IB4XQDRWire <--> SW_L2_2_0_U1.port[6];
        SW_L1_2_1_U1.port[1] <--> IB4XQDRWire <--> SW_L2_2_0_U1.port[7];
        SW_L1_2_1_U1.port[2] <--> IB4XQDRWire <--> SW_L2_2_1_U1.port[6];
        SW_L1_2_1_U1.port[3] <--> IB4XQDRWire <--> SW_L2_2_1_U1.port[7];
        SW_L1_3_0_U1.port[0] <--> IB4XQDRWire <--> SW_L2_3_0_U1.port[4];
        SW_L1_3_0_U1.port[1] <--> IB4XQDRWire <--> SW_L2_3_0_U1.port[5];
        SW_L1_3_0_U1.port[2] <--> IB4XQDRWire <--> SW_L2_3_1_U1.port[4];
        SW_L1_3_0_U1.port[3] <--> IB4XQDRWire <--> SW_L2_3_1_U1.port[5];
        SW_L1_3_1_U1.port[0] <--> IB4XQDRWire <--> SW_L2_3_0_U1.port[6];
        SW_L1_3_1_U1.port[1] <--> IB4XQDRWire <--> SW_L2_3_0_U1.port[7];
        SW_L1_3_1_U1.port[2] <--> IB4XQDRWire <--> SW_L2_3_1_U1.port[6];
        SW_L1_3_1_U1.port[3] <--> IB4XQDRWire <--> SW_L2_3_1_U1.port[7];
}

