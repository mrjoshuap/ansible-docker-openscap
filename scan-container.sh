#!/usr/bin/env bash

SCAP_PROFILE=${1:?You must specify a scap profile as the first argument}
DOCKER_IMAGE=${2:?You must specify a docker image as the second argument}
PROFILE=${3}

DOCKER_IMAGE_CLEANED=$(echo ${DOCKER_IMAGE} | sed -e 's/\//_/g' -e 's/://g')

# Warn if non root user has run our script
if [ "$(id -u)" != "0" ]; then
   echo "WARNING: This script should probably be run as root." 1>&2
fi

pushd $(dirname ${0})

if [ -z "${PROFILE}" ]; then
    PROFILE_CMD="--profile=${PROFILE}"
else
    PROFILE_CMD=""
fi

oscap-docker image-cve "${DOCKER_IMAGE}" \
	--report "reports/report-${DOCKER_IMAGE_CLEANED}-cve.html"

oscap-docker image "${DOCKER_IMAGE}" \
	oval eval \
	--results "reports/results-${DOCKER_IMAGE_CLEANED}-oval.xml" \
	--report "reports/report-${DOCKER_IMAGE_CLEANED}-oval.html" \
	/usr/share/xml/scap/ssg/content/ssg-${SCAP_PROFILE}-ds.xml

oscap-docker image "${DOCKER_IMAGE}" \
    xccdf eval \
    --results "reports/results-${DOCKER_IMAGE_CLEANED}-xccdf.xml" \
    --report "reports/report-${DOCKER_IMAGE_CLEANED}-xccdf.html" \
    --fetch-remote-resources ${PROFILE_CMD} \
    /usr/share/xml/scap/ssg/content/ssg-${SCAP_PROFILE}-xccdf.xml

popd
