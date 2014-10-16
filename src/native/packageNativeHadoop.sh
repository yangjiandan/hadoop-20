#!/bin/sh

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# packageNativeHadoop.sh - A simple script to help package native-hadoop libraries

#
# Note: 
# This script relies on the following environment variables to function correctly:
#  * BASE_NATIVE_LIB_DIR
#  * BUILD_NATIVE_DIR
#  * DIST_LIB_DIR
# All these are setup by build.xml.
#

TAR='tar cf -'
UNTAR='tar xfBp -'

# Copy the pre-built libraries in $BASE_NATIVE_LIB_DIR
if [ -d $BASE_NATIVE_LIB_DIR ]
then
  for platform in `ls $BASE_NATIVE_LIB_DIR`
  do
    if [ ! -d $DIST_LIB_DIR/$platform ]
    then
      mkdir -p $DIST_LIB_DIR/$platform
      echo "Created $DIST_LIB_DIR/$platform"
    fi
    echo "Copying libraries in $BASE_NATIVE_LIB_DIR/$platform to $DIST_LIB_DIR/$platform/"
    cd $BASE_NATIVE_LIB_DIR/$platform/
    $TAR *hadoop* | (cd $DIST_LIB_DIR/$platform/; $UNTAR)
  done
fi

# Copy the custom-built libraries in $BUILD_DIR
if [ -d $BUILD_NATIVE_DIR ]
then 
  for platform in `ls $BUILD_NATIVE_DIR`
  do
    if [ ! -d $DIST_LIB_DIR/$platform ]
    then
      mkdir -p $DIST_LIB_DIR/$platform
      echo "Created $DIST_LIB_DIR/$platform"
    fi
    echo "Copying libraries in $BUILD_NATIVE_DIR/$platform/lib to $DIST_LIB_DIR/$platform/"
    cd $BUILD_NATIVE_DIR/$platform/lib
    $TAR *hadoop* | (cd $DIST_LIB_DIR/$platform/; $UNTAR)
    $TAR *liblzma* | (cd $DIST_LIB_DIR/$platform/; $UNTAR)
    $TAR *liblz4* | (cd $DIST_LIB_DIR/$platform/; $UNTAR)
    cp libGetUserGroupInfo.so $DIST_LIB_DIR/$platform/
    mv $DIST_LIB_DIR/$platform/liblzma.so $DIST_LIB_DIR/$platform/liblzma.so.0
    mv $DIST_LIB_DIR/$platform/liblz4.so $DIST_LIB_DIR/$platform/liblz4.so.0
  done  
fi

if [ -d ${CGROUP_LIB_DIR} ]
then
    echo "Copying CGroup library in ${CGROUP_LIB_DIR} to $DIST_LIB_DIR/$platform/"
    cd ${CGROUP_LIB_DIR}
    cp libCGroupEventListener.so $DIST_LIB_DIR/$platform/
fi

if [ "${BUNDLE_SNAPPY_LIB}" == "true" ]
then
  if [ -d ${SNAPPY_LIB_DIR} ]
  then
    echo "Copying Snappy library in ${SNAPPY_LIB_DIR} to $DIST_LIB_DIR/$platform/"
    cd ${SNAPPY_LIB_DIR}
    $TAR . | (cd $DIST_LIB_DIR/$platform; $UNTAR)
  else
    echo "Snappy lib directory ${SNAPPY_LIB_DIR} does not exist"
    exit 1
  fi
else
  echo "Skipping Copying Snappy library, BUNDLE_SNAPPY_LIB=${BUNDLE_SNAPPY_LIB}"
fi

#vim: ts=2: sw=2: et
