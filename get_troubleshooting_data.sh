#!/bin/bash

access_key=''
secret_key=''
gateway='objects.dreamhost.com'

result_path=`pwd`"/troubleshooting_data";
mkdir -p ${result_path};
rm -rf ${result_path}/*

PS3="What type of problem are you having? "
options="general monitor object_storage_daemon meta_data_server placement_groups exit"

function dump_data {
  command=$1
  filename=${1// /_}
  filename=${filename}".txt"
  echo "Command: $1";
  eval "$1" > $result_path/$filename;
}

function dump_osdmap {
  echo "Command: ceph osd getmap -o ./troubleshooting_data/osd_map"
  ceph osd getmap -o ./troubleshooting_data/osd_map
}

function build_archive {
  echo;
  echo "Building archive of troubleshooting data."
  tar zcvf troubleshooting_data.tar.gz ./troubleshooting_data && echo "Archive has been built \"troubleshooting_data.tar.gz\" in current directory."
}

function upload_archive {
  echo;
  if [[ ! -z $access_key && ! -z $secret_key ]]; then
    echo "Uploading archive."
    eval "./troubleshooting_uploader.py --filename troubleshooting_data.tar.gz --access_key ${access_key} --secret_key ${secret_key} --gateway ${gateway}"
  fi
}

select option in $options;
do
  case $option in
    "exit")
      echo "Bye.";
      break
      ;;
    "monitor")
      echo "You selected monitor problems.";
      echo ""
      echo "We are now dumping copies of the following items to: ${result_path}";
      echo ""
      dump_data "ceph status"
      dump_data "ceph auth list"
      dump_data "ceph mon dump"
      build_archive
      upload_archive
      break
      ;;
    "object_storage_daemon")
      echo "You selected OSD problems.";
      echo ""
      echo "We are now dumping copies of the following items to: ${result_path}";
      echo ""
      dump_data "ceph status"
      dump_data "ceph auth list"
      dump_data "ceph osd dump"
      dump_data "ceph osd tree"
      dump_data "ceph pg dump"
      dump_data "dmesg"
      dump_osdmap
      build_archive
      upload_archive
      break
      ;;
    "meta_data_server")
      echo "You selected MDS problems.";
      echo ""
      echo "We are now dumping copies of the following items to: ${result_path}";
      echo ""
      dump_data "ceph status"
      dump_data "ceph auth list"
      dump_data "ceph mds dump"
      dump_data "ceph pg dump"
      dump_data "dmesg"
      dump_osdmap
      build_archive
      upload_archive
      break
      ;;
    "placement_groups")
      echo "You selected pg problems.";
      echo ""
      echo "We are now dumping copies of the following items to: ${result_path}";
      echo ""
      dump_data "ceph status"
      dump_data "ceph auth list"
      dump_data "ceph pg dump"
      dump_data "ceph osd tree"
      dump_data "dmesg"
      dump_osdmap
      build_archive
      upload_archive
      break
      ;;
    "general")
      echo "You selected general problems.";
      echo ""
      echo "We are now dumping copies of the following items to: ${result_path}";
      echo ""
      dump_data "ceph status"
      dump_data "ceph auth list"
      dump_data "ceph mon dump"
      dump_data "ceph osd dump"
      dump_data "ceph mds dump"
      dump_data "ceph pg dump"
      dump_data "ceph osd tree"
      dump_data "ceph quorum_status"
      dump_data "rbd list"
      dump_data "dmesg"
      dump_osdmap
      build_archive
      upload_archive
      break
      ;;
    *)
      echo "$option is an unknown options.";
  esac
done;
