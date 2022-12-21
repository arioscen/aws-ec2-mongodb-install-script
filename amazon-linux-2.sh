#!/bin/bash

export SCRIPT_LOG_PATH='/tmp/MongoDB_Install.log'

echo '=> Install the latest stable version of MongoDB' >> ${SCRIPT_LOG_PATH}
sudo sh -c "echo $'[mongodb-org-6.0]\nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/6.0/x86_64/\ngpgcheck=1\nenabled=1\ngpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc' > /etc/yum.repos.d/mongodb-org-6.0.repo"
# echo '=> Iinstall a specific release of MongoDB' >> ${SCRIPT_LOG_PATH}
# sudo yum install -y mongodb-org-6.0.3 mongodb-org-database-6.0.3 mongodb-org-server-6.0.3 mongodb-mongosh-6.0.3 mongodb-org-mongos-6.0.3 mongodb-org-tools-6.0.3
# sudo sh -c "echo exclude=mongodb-org,mongodb-org-database,mongodb-org-server,mongodb-mongosh,mongodb-org-mongos,mongodb-org-tools >> /etc/yum.conf"

echo '=> Adjust the readahead settings' >> ${SCRIPT_LOG_PATH}
sudo sh -c "echo '/sbin/blockdev --setra 0 /dev/nvme0n1p1' >> /etc/rc.d/rc.local"
sudo chmod a+x /etc/rc.d/rc.local
sudo systemctl enable rc-local
# check after reboot:
# sudo /sbin/blockdev --getra /dev/nvme0n1p1

echo '=> Turn off transparent hugepages' >> ${SCRIPT_LOG_PATH}
sudo sh -c "echo 'vm.nr_hugepages=0' >> /etc/sysctl.conf"
# check after reboot:
# sudo cat /proc/sys/vm/nr_hugepages

echo '=> Disable NUMA' >> ${SCRIPT_LOG_PATH}
echo 0 | sudo tee /proc/sys/vm/zone_reclaim_mode
sudo sysctl -w vm.zone_reclaim_mode=0
sudo yum -y install numactl
sudo sed -i 's/ExecStart=/ExecStart=\/usr\/bin\/numactl --interleave=all /' /usr/lib/systemd/system/mongod.service
sudo systemctl daemon-reload

echo '=> Done. Reboot System' >> ${SCRIPT_LOG_PATH}
sudo reboot