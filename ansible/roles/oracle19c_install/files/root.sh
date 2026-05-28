#!/bin/sh
unset WAS_ROOTMACRO_CALL_MADE
. /app/oracle/db19/install/utl/rootmacro.sh "$@"
. /app/oracle/db19/install/utl/rootinstall.sh
/app/oracle/db19/install/root_schagent.sh

#
# Root Actions related to network
#
/app/oracle/db19/network/install/sqlnet/setowner.sh

#
# Invoke standalone rootadd_rdbms.sh
#
/app/oracle/db19/rdbms/install/rootadd_rdbms.sh

/app/oracle/db19/rdbms/install/rootadd_filemap.sh