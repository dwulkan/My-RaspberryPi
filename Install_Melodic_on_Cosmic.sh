#!/bin/bash -e

# 20190419  Dave Wulkan A.S., B.S.I.T., M.B.A., COBOL
# When you MUST compile from source
# Based on:  http://wiki.ros.org/melodic/Installation/Source

# Script to save output to a text file for a post mortum.
# Run:  rosinstall.sh step-name   (LC ex. step03)
#                     step01 thru step14  <- for restarts
#
# 
# 20190608 dw Addeds some tests to see if step had already succeeded.
#             Ros Version is Melodic Morenia
#             Ubuntu 18.04 but says Cosmic?
#
step=$1
#rosdir=~/ros
rosdir=/opt/ros/melodic
outfile=~/rosinstalllog.txt

printf "******************************************************\n" 2>&1 | tee >>$outfile
printf "******************************************************\n" 2>&1 | tee >>$outfile
printf "******************************************************\n" 2>&1 | tee >>$outfile
RIGHT_NOW=$(date +"%x %r %Z")
echo "ROSINSTALL.sh BEGIN: $RIGHT_NOW \n"    2>&1 | tee >>$outfile


if [ -z $step ]; then 
   printf "NEED  A STEPNAME... $step \n"     2>&1 | tee >>$outfile
   exit 1
fi


#-----------------------------------
#STEP01
if [ "$step" == "step01" ]; then 
    printf "$step \n"                        2>&1 | tee >>$outfile
    printf "    STEP01: 1.1      Installing bootstrap dependencies\n"     2>&1 | tee >>$outfile
    cd $rosdir
    sudo apt-get install python-rosdep python-rosinstall-generator python-wstool python-rosinstall build-essential                   2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 01:  " $?           2>&1 | tee >>$outfile
       exit 1
    fi
    step="step02"
fi
#-----------------------------------
#STEP02
if [ "$step" == "step02" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP02: 1.2a      Initializing rosdep\n"    2>&1 | tee >>$outfile
    cd $rosdir
    sudo rosdep init                        2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 02:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    step="step03"
fi
#-----------------------------------
#STEP03
if [ "$step" == "step03" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP03: 1.2b      rosdep update\n"  2>&1 | tee >>$outfile
    cd $rosdir
    rosdep update                           2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 03:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    step="step04"
fi
#-----------------------------------
#STEP04
if [ "$step" == "step04" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP04: 2.1      Create a catkin Workspace\n"    2>&1 | tee >>$outfile
    if [ ! -d "$rosdir/ros_catkin_ws " ]; then
       mkdir $rosdir/ros_catkin_ws          2>&1 | tee >>$outfile
    fi
    if [ $? -ne 0 ]; then
       printf "       ERROR 04.1:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    cd $rosdir/ros_catkin_ws
    if [ $? -ne 0 ]; then
       printf "       ERROR 04.2:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    step="step05"
fi
#-----------------------------------
#STEP05
if [ "$step" == "step05" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP05: Desktop Install 1 (recommended):\n"   2>&1 | tee >>$outfile
    cd $rosdir
    rosinstall_generator desktop --rosdistro melodic --deps --tar > melodic-desktop.rosinstall   2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 05.1:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    printf "    STEP05: Desktop Install 2 (recommended):\n"   2>&1 | tee >>$outfile
    cd $rosdir

    printf "       wstool 1 step:\n"               2>&1 | tee >>$outfile
    wstool init -j8 src melodic-desktop.rosinstall     2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 05.2:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    step="step06"
fi
#-----------------------------------
#STEP06
if [ "$step" == "step06" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP06: Robot Install A of B\n"  2>&1 | tee >>$outfile
    cd $rosdir
    rosinstall_generator robot --rosdistro melodic --deps --tar > melodic-robot.rosinstall  2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 06.1:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    printf "    STEP06: Robot Install B of B\n"  2>&1 | tee >>$outfile
    cd $rosdir

    printf "       wstool 2 step:\n"               2>&1 | tee >>$outfile
    wstool init -j8 src melodic-robot.rosinstall   2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 06.2:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    step="step07"
fi
#-----------------------------------
#STEP07
# This step takes the most time
#https://stackoverflow.com/questions/53266574/installing-ros-melodic-on-ubuntu-18-10
# Override the [os] distro, using bionic instead of cosmic:
# rosdep install --from-paths src --ignore-src --os=ubuntu:bionic --rosdistro melodic -y
if [ "$step" == "step07" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP07: 2.1.1   Resolving Dependencies\n"  2>&1 | tee >>$outfile
    cd $rosdir
    sudo rosdep install --from-paths src --ignore-src --rosdistro melodic -y --os=ubuntu:bionic  2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 07:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    step="step08"
fi
#-----------------------------------
#STEP08
if [ "$step" == "step08" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP08: 2.1.2a   Building the Local catkin Workspace\n" 2>&1 | tee >>$outfile
    if [ ! -d "~/rosdir" ]; then
       mkdir ~/rosdir
    fi
#    cd ~/rosdir  20190602 dw
    cd ~/ros/rosdir
    $rosdir/src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release 2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 08.1:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    printf "    STEP08: 2.1.2b   Building the Public catkin Workspace\n"2>&1 | tee >>$outfile
    cd $rosdir
    ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/melodic  2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 08.2:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    step="step09"
fi
#-----------------------------------
#STEP09
if [ "$step" == "step09" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP09: Run setup.bash\n"        2>&1 | tee >>$outfile
    cd $rosdir
    source ./install_isolated/setup.bash    2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 09:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    step="step10"
fi
#STEP09 errors were from pacakges already installed!
#  source ./install_isolated/setup.bash    2>&1 | tee >>~/rosinstall.txt

#-----------------------------------
#STEP10
if [ "$step" == "step10" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP10: 3.      Maintain a Source Checkout\n" 2>&1 | tee >>$outfile
    printf "            3.1     Backup the workspace\n"       2>&1 | tee >>$outfile
    cd $rosdir
#    mv -i melodic-desktop-full.rosinstall melodic-desktop.rosinstall.old 2>&1 | tee >>$outfile
    mv -f melodic-desktop.rosinstall melodic-desktop.rosinstall.old 2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 10.1:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    printf "    STEP10: 3.1.a     Update the workspace\n" 2>&1 | tee >>$outfile
    cd $rosdir
#    rosinstall_generator desktop_full --rosdistro melodic --deps --tar > melodic-desktop.rosinstall 2>&1 | tee >>$outfile
    rosinstall_generator desktop --rosdistro melodic --deps --tar > melodic-desktop.rosinstall 2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 10.2:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    step="step11"
fi
#   
#    mv -i melodic-desktop.rosinstall melodic-desktop.rosinstall.old 2>&1 | tee >>~/rosinstall.txt
#    rosinstall_generator desktop --rosdistro melodic --deps --tar > melodic-desktop.rosinstall 2>&1 | tee >>~/rosinstall.txt
#  Asks for a Y to overwrite 

#-----------------------------------
#STEP11
if [ "$step" == "step11" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP11:  Diff from older version\n" 2>&1 | tee >>$outfile
    cd $rosdir
    diff -u melodic-desktop.rosinstall melodic-desktop.rosinstall.old 2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 11:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    step="step12"
fi
#-----------------------------------
#STEP12
if [ "$step" == "step12" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP12:  incorporate the new rosinstall file into the workspace\n" 2>&1 | tee >>$outfile
    cd $rosdir
    wstool merge -t src melodic-desktop.rosinstall 2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 12.1:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    printf "    STEP12:  incorporate the new rosinstall file into the workspace\n" 2>&1 | tee >>$outfile
    cd $rosdir
    wstool update -t src                    2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 12.2:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    step="step13"
fi
#-----------------------------------
#STEP13
if [ "$step" == "step13" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP13: 3.2     Rebuild your workspace\n" 2>&1 | tee >>$outfile
    cd $rosdir
    ./src/catkin/bin/catkin_make_isolated --install 2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 13:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
    step="step14"
fi
#-----------------------------------
#STEP14
if [ "$step" == "step14" ]; then 
    printf "$step \n"                       2>&1 | tee >>$outfile
    printf "    STEP14:  Now, source the setup files again:\n" 2>&1 | tee >>$outfile
#    source $rosdir/ros_catkin_ws/install_isolated/setup.bash 2>&1 | tee >>$outfile
    source $rosdir/install_isolated/setup.bash 2>&1 | tee >>$outfile
    if [ $? -ne 0 ]; then
       printf "       ERROR 14:  " $?          2>&1 | tee >>$outfile
       exit 1
    fi
fi
#-----------------------------------

RIGHT_NOW=$(date +"%x %r %Z")
printf "ROSINSTALL.sh END: $RIGHT_NOW \n"   2>&1 | tee >>$outfile

