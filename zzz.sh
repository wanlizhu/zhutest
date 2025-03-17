source ~/zhutest/utils.sh
zhu-test-viewperf-maya-subtest5 &
sleep 1
zhu-cpu-utilization
cat /tmp/cpu-utilization.log