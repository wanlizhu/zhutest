function zhu-test-gdm3-perf-overhead {
    zhu-test-viewperf-maya-subtest5 | tee /tmp/maya.gdm3.log || return -1
    zhu-xserver || return -1
    zhu-test-viewperf-maya-subtest5 | tee /tmp/maya.xserver.log || return -1
    zhu-gdm3 || return -1
    sleep 3
    echo 
    echo "FPS on GDM3: $(cat /tmp/maya.gdm3.log | grep 'result FPS' | awk '{print $5}')"
    echo "FPS on Xserver: $(cat /tmp/maya.xserver.log | grep 'result FPS' | awk '{print $5}')"
}