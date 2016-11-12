FROM ubuntu:latest
MAINTAINER betaflight

# If you want to tinker with this Dockerfile on your machine do as follows:
# - docker build -t betaflight
# - cd <your betaflight source dir>
# - docker run --rm -ti -v `pwd`:/opt/betaflight betaflight-build
RUN apt-get update -y
RUN apt-get install -y git make ccache curl bzip2 python lib32ncurses5

RUN mkdir /opt/betaflight-requirements
COPY . /opt/betaflight-requirements/
WORKDIR /opt/betaflight-requirements

RUN make arm_sdk_install

RUN mkdir /opt/betaflight
WORKDIR /opt/betaflight

RUN cp -R /opt/betaflight-requirements/tools /opt/betaflight-tools/
RUN rm -r /opt/betaflight-requirements
ENV PATH /opt/betaflight-tools/gcc-arm-none-eabi-5_4-2016q3/bin/:$PATH

RUN echo $PATH

# Config options you may pass via Docker like so 'docker run -e "<option>=<value>"':
# - PLATFORM=<name>, specify target platform to build for
#   Specify 'ALL' to build for all supported platforms. (default: NAZE)
#
# What the commands do:
CMD if [ -z ${PLATFORM} ]; then \
      PLATFORM="NAZE"; \
    fi && \
    if [ ${PLATFORM} = ALL ]; then \
        make clean_all && \
        make all; \
    else \
        make clean TARGET=${PLATFORM} && \
        make TARGET=${PLATFORM}; \
    fi