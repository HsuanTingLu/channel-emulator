#!/bin/bash
source ce_run.inc
INPUT_FILE="floating-leaves.jpg"
OUTPUT_FILE="floating-leaves.rebuilt-from-M_PDUs.jpg"
CHANNEL=mpdu_encode_decode

# External stuctures
ce_run channel.addChannel ${CHANNEL}

ce_run file.manage file0 $INPUT_FILE
ce_run file.openForReading file0

ce_run file.manage file1 $OUTPUT_FILE
ce_run file.openForWriting file1

ce_run dll.load modFdReceiver
ce_run dll.load modFdTransmitter
ce_run dll.load modUDP_Add
ce_run dll.load modUDP_Remove
ce_run dll.load modEncapPkt_Add
ce_run dll.load modEncapPkt_Remove
ce_run dll.load modAOS_M_PDU_Add
ce_run dll.load modAOS_M_PDU_Remove
ce_run dll.load modAOS_VC_Gen
ce_run dll.load modAOS_VC_Rcv

# file0 -> file1 configuration
echo "Setting up modFdTransmitter/file1tx"
ce_run modFdTransmitter.add ${CHANNEL} file1tx
ce_run modFdTransmitter.connectDevice ${CHANNEL} file1tx file1
ce_run modFdTransmitter.startup ${CHANNEL} file1tx
sleep 2

echo "Setting up modUDP_Remove/udpdel0"
ce_run modUDP_Remove.add ${CHANNEL} udpdel0
ce_run modUDP_Remove.connectOutput ${CHANNEL} udpdel0 file1tx
ce_run modUDP_Remove.startup ${CHANNEL} udpdel0
sleep 2

echo "Setting up modEncapPkt_Remove/encapdel0"
ce_run modEncapPkt_Remove.add ${CHANNEL} encapdel0
ce_run modEncapPkt_Remove.connectOutput ${CHANNEL} encapdel0 udpdel0
ce_run modEncapPkt_Remove.startup ${CHANNEL} encapdel0
sleep 2

echo "Setting up modAOS_M_PDU_Remove/mpdudel0"
ce_run modAOS_M_PDU_Remove.add ${CHANNEL} mpdudel0
ce_run modAOS_M_PDU_Remove.connectOutput ${CHANNEL} mpdudel0 encapdel0
ce_run modAOS_M_PDU_Remove.startup ${CHANNEL} mpdudel0
sleep 2

echo "Setting up modAOS_VC_Rcv/vcdel0"
ce_run modAOS_VC_Rcv.add ${CHANNEL} vcdel0
ce_run modAOS_VC_Rcv.setFrameSize ${CHANNEL} vcdel0 i/128
ce_run modAOS_VC_Rcv.setSCID ${CHANNEL} vcdel0 i/171
ce_run modAOS_VC_Rcv.setVCID ${CHANNEL} vcdel0 i/1
ce_run modAOS_VC_Rcv.setServiceType ${CHANNEL} vcdel0 Multiplexing
ce_run modAOS_VC_Rcv.connectOutput ${CHANNEL} vcdel0 mpdudel0
ce_run modAOS_VC_Rcv.startup ${CHANNEL} vcdel0
sleep 2

echo "Setting up modAOS_VC_Gen/vcadd0"
ce_run modAOS_VC_Gen.add ${CHANNEL} vcadd0
ce_run modAOS_VC_Gen.setFrameSize ${CHANNEL} vcadd0 i/128
ce_run modAOS_VC_Gen.setSCID ${CHANNEL} vcadd0 i/171
ce_run modAOS_VC_Gen.setVCID ${CHANNEL} vcadd0 i/1
ce_run modAOS_VC_Gen.connectOutput ${CHANNEL} vcadd0 vcdel0
ce_run modAOS_VC_Gen.startup ${CHANNEL} vcadd0
sleep 2

echo "Setting up modAOS_M_PDU_Remove/mpduadd0"
ce_run modAOS_M_PDU_Add.add ${CHANNEL} mpduadd0
ce_run modAOS_M_PDU_Add.connectOutput ${CHANNEL} mpduadd0 vcadd0
ce_run modAOS_M_PDU_Add.setLength ${CHANNEL} mpduadd0 i/122
ce_run modAOS_M_PDU_Add.startup ${CHANNEL} mpduadd0
sleep 2

echo "Setting up modEncapPkt_Add/encapadd0"
ce_run modEncapPkt_Add.add ${CHANNEL} encapadd0
ce_run modEncapPkt_Add.connectOutput ${CHANNEL} encapadd0 mpduadd0
ce_run modEncapPkt_Add.startup ${CHANNEL} encapadd0
sleep 2

echo "Setting up modUDP_Add/udpadd0"
ce_run modUDP_Add.add ${CHANNEL} udpadd0
ce_run modUDP_Add.setSrcAddr ${CHANNEL} udpadd0 10.10.1.1
ce_run modUDP_Add.setSrcPort ${CHANNEL} udpadd0 i/12345
ce_run modUDP_Add.setDstAddr ${CHANNEL} udpadd0 10.10.1.2
ce_run modUDP_Add.setDstPort ${CHANNEL} udpadd0 i/54321
ce_run modUDP_Add.setUDPCRC ${CHANNEL} udpadd0 b/true
ce_run modUDP_Add.connectOutput ${CHANNEL} udpadd0 encapadd0
ce_run modUDP_Add.startup ${CHANNEL} udpadd0
sleep 2

echo "Setting up modFdReceiver/file0rx"
ce_run modFdReceiver.add ${CHANNEL} file0rx
ce_run modFdReceiver.connectDevice ${CHANNEL} file0rx file0
ce_run modFdReceiver.setMaxRead ${CHANNEL} file0rx i/1024
ce_run modFdReceiver.connectOutput ${CHANNEL} file0rx udpadd0
ce_run modFdReceiver.startup ${CHANNEL} file0rx
sleep 2
