function zhu-test-maya-high-interrupt-count-on-gdm3 {
    zhu-validate-display || return -1
    zhu-install-perf  || return -1
    rm -rf /tmp/fps.log 

    if [[ -z $(which trace-cmd) ]]; then
        sudo apt install -y trace-cmd
    fi

    # Round 1 for the number of interrupts
    zhu-test-viewperf-maya-subtest5 &
    mayapid=$!
    sleep 2

    rm -rf trace.dat 
    if lsmod | grep -q nvidia; then
        nvidia_irq=$(grep 'nvidia' /proc/interrupts | awk '{print $1}' | cut -d: -f1 | head -1)
        echo "irq == $nvidia_irq" | sudo tee /sys/kernel/tracing/events/irq/irq_handler_entry/filter
        sudo trace-cmd record -p function -l nvidia_isr -e irq_handler_entry &
        tracecmd_pid=$!
    else
        amdgpu_irq=$(grep 'amdgpu' /proc/interrupts | awk '{print $1}' | cut -d: -f1 | head -1)
        echo "irq == $amdgpu_irq" | sudo tee /sys/kernel/tracing/events/irq/irq_handler_entry/filter
        sudo trace-cmd record -p function -l amdgpu_irq_handler -e irq_handler_entry &
        tracecmd_pid=$!
    fi

    wait $mayapid 
    sudo kill -SIGINT $tracecmd_pid 
    sleep 2

    if lsmod | grep -q nvidia; then
        nvidia_irq=$(grep 'nvidia' /proc/interrupts | awk '{print $1}' | cut -d: -f1 | head -1)
        count=$(trace-cmd report | grep -i nvidia | grep "irq=$nvidia_irq" | wc -l)
        echo "The number of interrupts is $count" > /tmp/xxx.log
    else
        echo 0 | sudo tee /sys/kernel/tracing/events/irq/irq_handler_entry/filter
        amdgpu_irq=$(grep 'amdgpu' /proc/interrupts | awk '{print $1}' | cut -d: -f1 | head -1)
        count=$(trace-cmd report | grep -i amdgpu | grep "irq=$amdgpu_irq" | wc -l)
        echo "The number of interrupts is $count" > /tmp/xxx.log
    fi

    # Round 2 for the time cost of interrupt handler (nvidia_isr/amdgpu_irq_handler)
    zhu-test-viewperf-maya-subtest5 &
    mayapid=$!
    sleep 2

    rm -rf latency.log
    if lsmod | grep -q nvidia; then
        irq_handler=nvidia_isr
    else
        irq_handler=amdgpu_irq_handler
    fi

    echo function | sudo tee /sys/kernel/debug/tracing/current_tracer
    echo $irq_handler | sudo tee /sys/kernel/debug/tracing/set_ftrace_filter
    echo 1 | sudo tee /sys/kernel/debug/tracing/tracing_on
    sudo cat /sys/kernel/debug/tracing/trace_pipe > latency.log &
    tracepipe_pid=$!
    wait $mayapid
    echo 0 | sudo tee /sys/kernel/debug/tracing/tracing_on
    sudo kill -SIGINT $tracepipe_pid
    sleep 2

    if lsmod | grep -q nvidia; then
        cputime_ns=$(awk '/nvidia_isr/ {gsub(/[^0-9]/,"",$3); sum+=$3} END {print sum}' latency.log)
    else
        cputime_ns=$(awk '/amdgpu_irq_handler/ {gsub(/[^0-9]/,"",$3); sum+=$3} END {print sum}' latency.log)
    fi
    cputime_ms=$((cputime_ns / 1000000))
    cputime_us=$((cputime_ns / 1000))
    echo "Total CPU time in $irq_handler is ${cputime_ms}ms (${cputime_us}us) (${cputime_ns}ns)" >> /tmp/xxx.log
    
    zhu-test-viewperf-maya-subtest5 & 
    mayapid=$!
    sleep 2

    zhu-generate-perf-and-flamegraph
    #zhu-interrupt-event
    wait $mayapid

    echo
    cat /tmp/fps.log 
    cat /tmp/xxx.log
}