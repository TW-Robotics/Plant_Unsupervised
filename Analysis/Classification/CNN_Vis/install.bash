# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Wöber 2020 <wilfried.woeber@technikum-wien.at>
#/bin/bash
virtualenv --no-site-packages ./Python/VE_CNN
./Python/VE_CNN/bin/pip install -r requirements_CNN.txt
