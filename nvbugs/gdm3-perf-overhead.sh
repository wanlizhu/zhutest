function zhu-test-gdm3-perf-overhead {
    zhu-test-viewperf-maya-subtest5 | tee /tmp/maya.gdm3.log || return -1 &
    sleep 3
    zhu-stat-gpu-interrupts $(pidof viewperf) | tee /tmp/maya.gdm3.int

    zhu-test-unigine-heaven | tee /tmp/heaven.gdm3.log || return -1 &
    sleep 6
    zhu-stat-gpu-interrupts $(pidof heaven_x64) | tee /tmp/heaven.gdm3.int

    zhu-xserver 

    zhu-test-viewperf-maya-subtest5 | tee /tmp/maya.xserver.log || return -1 &
    sleep 3
    zhu-stat-gpu-interrupts $(pidof viewperf) | tee /tmp/maya.xserver.int

    zhu-test-unigine-heaven | tee /tmp/heaven.xserver.log || return -1 &
    sleep 6
    zhu-stat-gpu-interrupts $(pidof heaven_x64) | tee /tmp/heaven.xserver.int

    zhu-gdm3 

    fps1=$(cat /tmp/maya.gdm3.log | grep 'result FPS' | awk '{print $5}')
    fps2=$(cat /tmp/maya.xserver.log | grep 'result FPS' | awk '{print $5}')
    fps3=$(cat /tmp/heaven.gdm3.log | grep 'FPS' | awk '{print $2}')
    fps4=$(cat /tmp/heaven.xserver.log | grep 'FPS' | awk '{print $2}')
    fps_ratio_21=$(echo "scale=4; $fps2/$fps1" | bc)
    fps_ratio_43=$(echo "scale=4; $fps4/$fps3" | bc)

    echo 
    echo "FPS Result:"
    echo -e "VP-Maya's FPS on GDM3: \t$fps1"
    echo -e "VP-Maya's FPS on Xserver: \t$fps2 ($fps_ratio_21 * gdm3)"
    echo -e " Heaven's FPS on GDM3: \t$fps3"
    echo -e " Heaven's FPS on Xserver: \t$fps4 ($fps_ratio_43 * gdm3)"

    int1=$(cat /tmp/maya.gdm3.int | grep 'Interrupts #1' | awk '{print $4}')
    int2=$(cat /tmp/maya.xserver.int | grep 'Interrupts #1' | awk '{print $4}')
    int3=$(cat /tmp/heaven.gdm3.int | grep 'Interrupts #1' | awk '{print $4}')
    int4=$(cat /tmp/heaven.xserver.int | grep 'Interrupts #1' | awk '{print $4}')
    int_ratio_21=$(echo "scale=4; $int2/$int1" | bc)
    int_ratio_43=$(echo "scale=4; $int4/$int3" | bc)

    echo 
    echo "INT#1 (reading /proc/interrupts) Result:"
    echo -e "VP-Maya's INT#1 on GDM3: \t$int1"
    echo -e "VP-Maya's INT#1 on Xserver: \t$int2 ($int_ratio_21 * gdm3)"
    echo -e " Heaven's INT#1 on GDM3: \t$int3"
    echo -e " Heaven's INT#1 on Xserver: \t$int4 ($int_ratio_43 * gdm3)"

    int1_2=$(cat /tmp/maya.gdm3.int | grep 'Interrupts #2' | awk '{print $4}')
    int2_2=$(cat /tmp/maya.xserver.int | grep 'Interrupts #2' | awk '{print $4}')
    int3_2=$(cat /tmp/heaven.gdm3.int | grep 'Interrupts #2' | awk '{print $4}')
    int4_2=$(cat /tmp/heaven.xserver.int | grep 'Interrupts #2' | awk '{print $4}')
    int_ratio_21_2=$(echo "scale=4; $int2_2/$int1_2" | bc)
    int_ratio_43_2=$(echo "scale=4; $int4_2/$int3_2" | bc)

    echo 
    echo "INT#2 (reading ftrace) Result:"
    echo -e "VP-Maya's INT#1 on GDM3: \t$int1_2"
    echo -e "VP-Maya's INT#1 on Xserver: \t$int2_2 ($int_ratio_21_2 * gdm3)"
    echo -e " Heaven's INT#1 on GDM3: \t$int3_2"
    echo -e " Heaven's INT#1 on Xserver: \t$int4_2 ($int_ratio_43_2 * gdm3)"
}