#!/bin/csh -f

if ( -e log/$1.log ) then
        egrep 'ERROR' log/$1.log | egrep -v 'FLEXnet' > $1.err
        if ( -z $1.err ) then
                /bin/rm -f $1.err
                egrep 'Ending' log/$1.log | egrep  'First Encounter' | tail -1 | sed -e 's/Ending \"First Encounter\" (//' | sed -e 's/)//' > $1
        else
                echo ""
                echo ""
                echo "ERROR found in log file: $1.log"
                echo ""
                echo ""
        endif
else
        echo "File log/$1.log not found"
endif
