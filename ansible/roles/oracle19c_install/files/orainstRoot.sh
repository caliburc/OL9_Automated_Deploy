#!/bin/sh
AWK=/bin/awk
CHMOD=/bin/chmod
CHGRP=/bin/chgrp
CP=/bin/cp
ECHO=/bin/echo
MKDIR=/bin/mkdir
RUID=`/usr/bin/id|$AWK -F\( '{print $1}'|$AWK -F\= '{print $2}'`
if [ ${RUID} != "0" ];then
   $ECHO "This script must be executed as root"
   exit 1
fi
if [ ! -d "/etc" ]; then
$MKDIR -p /etc;
fi
$CHMOD 755 /etc;
if [ -f "/app/oracle/db19/oraInventory/oraInst.loc" ]; then
$CP /app/oracle/db19/oraInventory/oraInst.loc /etc/oraInst.loc;
$CHMOD 644 /etc/oraInst.loc
else
INVPTR=/etc/oraInst.loc
INVLOC=/app/oracle/db19/oraInventory
GRP=oinstall
PTRDIR="`dirname $INVPTR`";
# Create the software inventory location pointer file
if [ ! -d "$PTRDIR" ]; then
 $MKDIR -p $PTRDIR;
fi
$ECHO "Creating the Oracle inventory pointer file ($INVPTR)";
$ECHO    inventory_loc=$INVLOC > $INVPTR
$ECHO    inst_group=$GRP >> $INVPTR
chmod 644 $INVPTR
# Create the inventory directory if it doesn't exist
if [ ! -d "$INVLOC" ];then
 $ECHO "Creating the Oracle inventory directory ($INVLOC)";
 $MKDIR -p $INVLOC;
fi
fi
$ECHO "Changing permissions of /app/oracle/db19/oraInventory.
Adding read,write permissions for group.
Removing read,write,execute permissions for world.
";
$CHMOD -R g+rw,o-rwx /app/oracle/db19/oraInventory;
if [ $? != 0 ]; then
 $ECHO "OUI-35086:WARNING: chmod of /app/oracle/db19/oraInventory
Adding read,write permissions for group.
,Removing read,write,execute permissions for world.
 failed!";
fi
$ECHO "Changing groupname of /app/oracle/db19/oraInventory to oinstall.";
$CHGRP -R oinstall /app/oracle/db19/oraInventory;
if [ $? != 0 ]; then
 $ECHO "OUI-10057:WARNING: chgrp of /app/oracle/db19/oraInventory to oinstall failed!";
fi
$ECHO "The execution of the script is complete."