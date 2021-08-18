#!/bin/bash
#
# Utility to find a list of pip3 installed libraries based on
# the required libraries in the current project. If the current
# instance is brand new, the list can be empty.
#
# Standard "pipreqs" shows the latest version of python libraries can
# be installed in the current project; however, it wouldn't produce the
# actual libraries version used in your project. Since we may not
# always use the latest, so we need to produce a list of libraries
# currently used.
#

params=()
while (( "$#" )); do
  case "$1" in
    -r|--required) _required=1; shift 1;;
    -i|--installed) _installed=1; shift 1;;
    -n|--notinstalled) _notinstalled=1; shift 1;;

    -h|--help) _help=1; shift 1;;
    -v|--verbose) _verbose=1; shift 1;;
    --) shift; break;;
    -*|--*=) echo "Error: unknown option $1" >&2; exit 1;;
    *) params+=("$1"); shift;;
  esac
done
eval set -- "${params[@]}"
if [ ! -z "$_verbose" ]; then set -x; fi

# functions
if [ ! -z "$_required" ]; then
  echo "#Required python libraries for this project"
  pipreqs --print 2>/dev/null | sort
  exit
fi

if [ ! -z "$_installed" ]; then
  echo "#Required python libraries already installed for this project"
  pip3 freeze | sed "s/\(^.*==\).*/\1/" | sed "s/-/_/g" | grep -f - <(pipreqs --print 2>/dev/null)
  exit
fi

if [ ! -z "$_notinstalled" ]; then
  echo "#Required python libraries not yet installed for this project"
  pip3 freeze | sed "s/\(^.*==\).*/\1/" | sed "s/-/_/g" | grep -v -f - <(pipreqs --print 2>/dev/null)
  exit
fi

# help message go here
echo "Usage: $(basename $0)
  Find a list of pip3 installed libraries based on the required libraries in the current project. If the current instance is brand new, the list can be empty.

  -r --required:     Required latest python libraries for this project.
  -i --installed:    Required python libraries already installed for this project.
                     Installed version may be different from the latest.
  -n --notinstalled: Required latest python libraries not yet installed for this project.
                     If different version is needed, use this 'pip3 install xxx==x.x.x'

  -h --help
  -v --verbose
"

