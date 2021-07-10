#!/bin/bash
/usr/local/bin/start-notebook.sh > ~/notebook.log 2>&1 &
tail -f  ~/notebook.log | sed -n '/^ .* or \(http:\/\/127.0.0.1.*\)/ q'
cat ~/notebook.log | sed -n 's/^ .* or \(http:\/\/127.0.0.1.*\)/\1/p'
