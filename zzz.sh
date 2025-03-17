source ~/zhutest/utils.sh
zhu-test-viewperf-maya-subtest5 &
sleep 1
rm -rf /tmp/cpu-utilization.log
zhu-cpu-utilization $(pidof viewperf)
cat /tmp/cpu-utilization.log