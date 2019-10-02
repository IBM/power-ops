# Main Project Documentation
(work in progress)

This document describes the global deployment variables that can be configured at [main.yml](../vars/main.yml).

In addition we keep here an index to other documentation to confure either environmental variables or component bulding/deployment options.

Environment documentation:
- [main](main.md) this document
- [aix](aix.md) deployment options for AIX nodes
- [debian](debian.md) deployment options for nodes running the Debian family of operating systems (includes Ubuntu)
- [redhat](redhat.md) deployment options for nodes running the RedHat family of operating systems (includes CentOS)
- [nutanix](nutanix.md) deployment options for creating virtual nodes on a Nutanix cluster (both Power and x86 variants)

Component documentation:
- [beats](beats.md) options to build and deploy beats (filebeat and metricbeat supported for now) on endpoint nodes
- [crassd](crassd.md) options to build and deploy crassd to controller nodes and configure it to collect Power Firmware data from Power endpoint nodes
- [elasticsearch](elasticsearch.md) options to deploy elasticsearch to controller nodes
- [go](go.md) options to build the go daemon on Power nodes
- [kibana](kibana.md) options to deploy kibana to controller nodes
- [logstash](logstash.md) options to deploy logstash to controller nodes
- [netdata](netdata.md) options to deploy netdata to controller nodes


