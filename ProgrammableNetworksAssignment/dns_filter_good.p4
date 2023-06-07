#include <core.p4>
#include <v1model.p4>

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
};

header ipv4_t {
    bit<4> version;
    bit<4> ihl;
    bit<8> diffServ;
    bit<16> totalLen;
    bit<16> identification;
    bit<3> flags;
    bit<13> fragOffset;
    bit<8> ttl;
    bit<8> protocol;
    bit<16> pktChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
};

header udp_t {
        bit<16> srcPort;
        bit<16> dstPort;
        bit<16> length;
        bit<16> checksum;
};

header dns_t {
    bit<16> id;
    bit<16> flags;
    bit<16> qdCount;
    bit<16> anCount;
    bit<16> nsCount;
    bit<16> arCount;
};

header dns_question_t {
    bit<256> qname;
    bit<16> qtype;
    bit<16> qclass;
};

struct dns_header_and_question_t {
    dns_t dns_header;
    dns_question_t dns_question;
};

struct metadata {
    /* empty */
};

struct headers {
    ethernet_t ethernet;
    ipv4_t ipv4;
    udp_t udp;
    dns_header_and_question_t dns;
};

parser MyParser(packet_in packet,
                out headers pkt,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(pkt.ethernet);
        transition select(pkt.ethernet.etherType) {
            0x0800: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(pkt.ipv4);
        transition select(pkt.ipv4.protocol) {
            17: parse_udp;
            default: accept;
        }
    }

    state parse_udp {
        packet.extract(pkt.udp);
        transition select(pkt.udp.dstPort) {
            53: parse_dns;
            default: accept;
        }
    }

    state parse_dns {
        packet.extract(pkt.dns.dns_header);
        packet.extract(pkt.dns.dns_question);
        transition accept;
    }

}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers pkt, inout metadata meta) {
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers pkt,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    action drop() {
        mark_to_drop(standard_metadata);
    }

    action dns_forward() {
        // TODO
        standard_metadata.egress_spec = 1;


    }



    table dns_filter {
        key = {
            pkt.dns.dns_question.qname: exact;
        }
        actions = {
            dns_forward;
            drop;
        }
        size = 1024;
        default_action = drop;
    }



    apply {
        if (pkt.dns.dns_question.qname ==  0b00000001011000010000001101100011011011110110110100000000)
        {
            drop();
        }
        else
        {
            dns_filter.apply();
        }

    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers pkt,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  pkt, inout metadata meta) {
     apply {
     }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers pkt) {
    apply {
        packet.emit(pkt.ethernet);
        packet.emit(pkt.ipv4);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
