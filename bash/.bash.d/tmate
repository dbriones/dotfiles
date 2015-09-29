#!/usr/bin/env bash

# Work around a misconfigured FQDN on the `tmate-slave` machine
# Usage: `tm_connect <complete tmate connection string>`
tm_connect () {
  # Extract the hostname/IP address from the tmate config file
  ip=$(grep host ~/.tmate.conf | sed -E 's/.*"(.*)"/\1/')
  cmd=""
  while (( "$#" ))
  do
    # Substitute the address into the params supplied to this function
    cmd=${cmd}' '$(echo $1 | sed -E "s/(.*@).*/\1${ip}/")
    shift
  done

  eval ${cmd}
}

# Automatically replace the unresolvable hostname out of the tmate
# connect string and replace with the IP address of the machine
# designated in ~/.tmate.conf. Put the result onto the clipboard.
tm_connect_string () {
  # Extract the hostname/IP address from the tmate config file
  ip=$(grep host ~/.tmate.conf | sed -E 's/.*"(.*)"/\1/')
  cmd=""
  while (( "$#" ))
  do
    # Substitute the address into the params supplied to this function
    cmd=${cmd}' '$(echo $1 | sed -E "s/(.*@).*/\1${ip}/")
    shift
  done

  printf "${cmd}" | pbcopy
}
