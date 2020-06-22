#!/bin/bash
# Script name:  firemotd-explore-host-ip.sh
# Version:      v0.02.200620
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_host_ip () {
  host_ip_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  ip_path="$(command -v ip 2>/dev/null)"
  if [ -z "$ip_path" ] ; then
    if [ -f /usr/sbin/ip ] ; then
      ip_path="/usr/sbin/ip"
    elif [ -f /sbin/ip ] ; then
      ip_path="/sbin/ip"
    else
      WriteLog Verbose Warning "No ip tool found"
    fi
  fi
  if [[ -n $ip_path ]] ; then
    host_ip_value="$(${ip_path} route get 8.8.8.8 | head -1 | grep -Po '(?<=src )(\d{1,3}.){4}' | xargs)"
    if [[ ! $host_ip_value =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      host_ip_value="Unable to parse ip \"$host_ip_value\". Please debug."
    fi
  else
    host_ip_value="Unable to use ip route. Please debug."
  fi
  host_ip_result=$(jq --arg host_ip_value "$host_ip_value" --arg host_ip_lastrun "$host_ip_lastrun" \
    '.host.properties.ip.properties.value = $host_ip_value | .host.properties.ip.properties.lastrun = $host_ip_lastrun' \
    data/firemotd-data.json)
  echo "${host_ip_result}" > data/firemotd-data.json
}

write_log debug info "Exploring host ip"
explore_host_ip