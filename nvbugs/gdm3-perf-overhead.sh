function zhu-test-gdm3-perf-overhead {
    zhu-test-viewperf-maya-subtest5 | tee /tmp/maya.gdm3.log || return -1
    zhu-xserver || return -1
    zhu-test-viewperf-maya-subtest5 | tee /tmp/maya.xserver.log || return -1
    zhu-gdm3 || return -1
    sleep 3

    fps1=$(cat /tmp/maya.gdm3.log | grep 'result FPS' | awk '{print $5}')
    fps2=$(cat /tmp/maya.xserver.log | grep 'result FPS' | awk '{print $5}')
    ratio=$(echo "scale=4; $fps2/$fps1" | bc)
    echo 
    echo "FPS on GDM3: $fps1"
    echo "FPS on Xserver: $fps2 ($ratio)"
}