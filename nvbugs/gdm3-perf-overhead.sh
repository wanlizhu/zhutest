function zhu-test-gdm3-perf-overhead {
    zhu-test-viewperf-maya-subtest5 | tee /tmp/maya.gdm3.log || return -1
    zhu-test-unigine-heaven | tee /tmp/heaven.gdm3.log || return -1
    zhu-xserver 
    zhu-test-viewperf-maya-subtest5 | tee /tmp/maya.xserver.log || return -1
    zhu-test-unigine-heaven | tee /tmp/heaven.xserver.log || return -1
    zhu-gdm3 

    fps1=$(cat /tmp/maya.gdm3.log | grep 'result FPS' | awk '{print $5}')
    fps2=$(cat /tmp/maya.xserver.log | grep 'result FPS' | awk '{print $5}')
    ratio1=$(echo "scale=4; $fps2/$fps1" | bc)
    fps3=$(cat /tmp/heaven.gdm3.log | grep 'FPS' | awk '{print $2}')
    fps4=$(cat /tmp/heaven.xserver.log | grep 'FPS' | awk '{print $2}')
    ratio2=$(echo "scale=4; $fps4/$fps3" | bc)

    echo 
    echo "VP-Maya's FPS on GDM3: $fps1"
    echo "VP-Maya's FPS on Xserver: $fps2 ($ratio1)"
    echo " Heaven's FPS on GDM3: $fps3"
    echo " Heaven's FPS on Xserver: $fps4 ($ratio2)"
}