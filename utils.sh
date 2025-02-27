#!/bin/bash
export __GL_SYNC_TO_VBLANK=0
export vblank_mode=0
export __GL_DEBUG_BYPASS_ASSERT=c 
[[ -z $DISPLAY ]] && export DISPLAY=:0
if [[ $USER == wanliz ]]; then
    export P4CLIENT=wanliz-p4sw-bugfix_main
    export P4ROOT=$HOME/$P4CLIENT
    export P4IGNORE=$HOME/.p4ignore 
    export P4PORT=p4proxy-sc.nvidia.com:2006
    export P4USER=wanliz 
    if [[ ! -e $P4IGNORE ]]; then
        echo "_out" > $P4IGNORE
        echo ".git" >> $P4IGNORE
        echo ".vscode" >> $P4IGNORE
    fi
fi

function zhu-reload {
    if [[ -e ~/zhutest/utils.sh ]]; then
        source ~/zhutest/utils.sh
    else
        echo "~/zhutest/utils.sh doesn't exist!"
    fi
}

function zhu-connect-nvidia-vpn {
    if [[ -z $(which openconnect) ]]; then
        sudo apt install -y openconnect
    fi

    if [[ ! -z $(pidof openconnect) ]]; then
        read -e -i yes -p "Kill previous openconnect process ($(pidof openconnect))? " ans
        if [[ $ans == yes ]]; then
            sudo kill -SIGINT $(pidof openconnect)
            echo "Wait for 3 seconds after killing openconnect"
            sleep 3
        fi
    fi

    if [[ $1 == "headless" ]]; then
        while IFS= read -r line; do 
            if [[ -z "$line" ]]; then
                break 
            fi
            export ${line%%=*}=${line#*=}
        done
    elif [[ $1 == "cookie" ]]; then
        openconnect --useragent="AnyConnect-compatible OpenConnect VPN Agent" --external-browser $(which google-chrome) --authenticate ngvpn02.vpn.nvidia.com/SAML-EXT
        return 
    else 
        eval $(openconnect --useragent="AnyConnect-compatible OpenConnect VPN Agent" --external-browser $(which google-chrome) --authenticate ngvpn02.vpn.nvidia.com/SAML-EXT)
    fi

    [ -n ["$COOKIE"] ] && echo -n "$COOKIE" | sudo openconnect --cookie-on-stdin $CONNECT_URL --servercert $FINGERPRINT --resolve $RESOLVE 
}

function zhu-send-files {
    if [[ -z $(which sshpass) ]]; then
        sudo apt install -y sshpass
    fi
    if [[ -z $(which fzf) ]]; then
        sudo apt install -y fzf 
    fi 
    if [[ ! -e ~/.zhurc.client ]]; then
        read -p "Client IP: " client
        read -e -i macos -p "Client OS: " clientos
        read -e -i $USER -p " Username: " username
        read -s -p " Password: " password
        echo "$username@$client $password $clientos" > ~/.zhurc.client
    fi
    if ! sshpass -p $(cat ~/.zhurc.client | awk '{print $2}') ssh -o StrictHostKeyChecking=no $(cat ~/.zhurc.client | awk '{print $1}') exit; then 
        rm -rf ~/.zshrc.client
    fi
    if [[ ! -e ~/.zhurc.client ]]; then
        echo "Invalid ~/.zhurc.client has been removed, run again"
        return -1
    fi

    files=$(ls * | fzf -m) 
    password=$(cat ~/.zhurc.client | awk '{print $2}')
    username=$(cat ~/.zhurc.client | awk '{print $1}' | awk -F '@' '{print $1}')
    hostname=$(cat ~/.zhurc.client | awk '{print $1}' | awk -F '@' '{print $2}')
    clientos=$(cat ~/.zhurc.client | awk '{print $3}')
    sshpass -p $password scp -r ${files//$'\n'/ } $username@$hostname:/$([[ $clientos == macos ]] && echo Users || echo home)/$username/Downloads/
}

function zhu-viewperf-install {
    if [[ ! -e ~/viewperf2020/viewperf/bin/viewperf ]]; then
        if ! mountpoint -q /mnt/linuxqa; then
            mount-linuxqa 
        fi

        which rsync >/dev/null || sudo apt install -y rsync 
        rsync -ah --progress /mnt/linuxqa/nvtest/pynv_files/viewperf2020v3/viewperf2020v3.tar.gz ~/Downloads/ || return -1
        
        pushd ~/Downloads >/dev/null
        tar -zxvf viewperf2020v3.tar.gz
        mv viewperf2020 ~/viewperf2020
        popd >/dev/null
    fi

    if [[ -z $(which xmllint) ]]; then
        sudo apt install -y libxml2 libxml2-utils
    fi
}

function zhu-viewperf-maya-subtest5 {
    [[ -z $DISPLAY ]] && export DISPLAY=:0 
    zhu-viewperf-install
    pushd ~/viewperf2020 >/dev/null
    mkdir -p results/maya-06

    if [[ ! -e viewsets/maya/config/subtest5.xml ]]; then
        cat <<EOF > viewsets/maya/config/subtest5.xml
<?xml version="1.0" standalone="yes"?>
<!DOCTYPE SPECGWPG>
<SPECGWPG Name="SPECviewperf" Version="v2.0" Results="results.xml" Log="log.txt">
    <Viewset Name="maya-06" Library="maya" Directory="maya" Threads="1" Options="" Version="2.0">
        <Window Resolution="3840x2160" Height="2120" Width="3800" X="10" Y="20"/>
        <Window Resolution="1920x1080" Height="1060" Width="1900" X="10" Y="20"/>
        <Test Name="Maya_05" Index="5" Weight="12.5" Seconds="15" Options="" Description="Sven space, smooth-shaded with hardware texture mode">
            <Grab Name="SvenSpace_ShadedTex.png" Frames="1" X="0" Y="0"   />
        </Test>
    </Viewset>
</SPECGWPG>
EOF
    fi

    ./viewperf/bin/viewperf viewsets/maya/config/subtest5.xml -resolution 1920x1080 && {
        cat results/maya-06/results.xml | grep FPS | xmllint --xpath 'string(//Test/@FPS)' - >> /tmp/fps.log 
        echo "Viewperf Maya-06/subtest5 result FPS: $(cat /tmp/fps.log | tail -1)"
    }

    popd >/dev/null
}

function zhu-perf-install {
    sudo apt install -y linux-tools-$(uname -r) linux-tools-generic >/dev/null 2>&1
    sudo apt install -y libtraceevent-dev >/dev/null 2>&1

    # Rebuild tools/perf to link against libtraceevent
    sudo perf stat -e irq:irq_handler_entry sleep 1 >/dev/null 2>&1 || {
        sudo apt install -y libtraceevent-dev libtracefs-dev
        sudo apt install -y flex bison libelf-dev libdw-dev libiberty-dev libslang2-dev libunwind-dev
        git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git ~/linux-kernel-torvalds.git || return -1
        pushd ~/linux-kernel-torvalds.git/tools/perf >/dev/null 
        make clean && make && sudo cp -vf perf $(which perf)
        popd >/dev/null
    }
}

function zhu-get-unused-filename {
    if [[ -e "$1" ]]; then
        filename="$1"
        counter=1
        # Name contains an extension
        if [[ "$filename" == *.* && "$filename" != .* ]]; then
            base="${filename%.*}"
            ext="${filename##*.}"
            while [[ -e "${base}-${counter}.${ext}" ]]; do 
                ((counter++))
            done
            echo "${base}-${counter}.${ext}"
        else # No extension
            while [[ -e "${filename}-${counter}" ]]; do
                ((counter++))
            done
            echo "${filename}-${counter}"
        fi
    else
        echo "$1"
    fi
}

function zhu-perf-generate-flamegraph {
    if [[ ! -e ~/flamegraph.git/flamegraph.pl ]]; then
        git clone --depth 1 https://github.com/brendangregg/FlameGraph.git ~/flamegraph.git || return -1
    fi

    perfdata=$1 
    if [[ -z $perfdata ]]; then
        perfdata=$(zhu-get-unused-filename system.perfdata)
        echo "perf is recording system-wide counters into $perfdata for 5 seconds"
        sudo perf record -a -g --call-graph dwarf --freq=2000 --output=$perfdata -- sleep 5 || return -1
    else
        perfdata=$(zhu-get-unused-filename $perfdata)
    fi

    if [[ -e $perfdata ]]; then
        sudo chmod 666 $perfdata
        sudo perf script --no-inline --force --input=$perfdata -F +pid > $perfdata.withpid && echo "Generated $perfdata.withpid" &&
        sudo perf script --no-inline --force --input=$perfdata > /tmp/$perfdata.script &&
        sudo ~/flamegraph.git/stackcollapse-perf.pl /tmp/$perfdata.script > /tmp/$perfdata.script.collapse &&
        sudo ~/flamegraph.git/stackcollapse-recursive.pl /tmp/$perfdata.script.collapse > $perfdata.folded && echo "Generated $perfdata.folded" &&
        sort -k2 -nr $perfdata.folded | head -n 1000 > $perfdata.folded.top1k && echo "Generated $perfdata.folded.top1k" &&
        sudo ~/flamegraph.git/flamegraph.pl $perfdata.folded > $perfdata.svg  && echo "Generated $perfdata.svg" &&
        sudo ~/flamegraph.git/flamegraph.pl --minwidth '1%' $perfdata.folded > $perfdata.mini.svg  && echo "Generated $perfdata.mini.svg" 
    fi 
}

function zhu-flamegraph-diff {
    if [[ -z $2 ]]; then
        echo "Usage: zhu-flamegraph-diff perf1.data.folded perf2.data.folded"
        return -1
    fi

    ~/flamegraph.git/difffolded.pl -n -s $1 $2 | ~/flamegraph.git/flamegraph.pl > $(basename $1)_$(basename $2).diff.svg 
}

function zhu-start-gdm3 {
    if [[ $XDG_SESSION_TYPE == tty ]]; then
        sudo kill -15 $(pidof Xorg)
        sleep 1
        sudo systemctl start gdm3
    fi
}

function zhu-start-bare-x {
    if [[ $XDG_SESSION_TYPE == tty ]]; then
        xset -dpms
        xset s off 

        sudo sed -i 's/console/anybody/g' /etc/X11/Xwrapper.config
        [[ -z $(grep '"DPMS" "false"' /etc/X11/xorg.conf) ]] && sudo sed -i 's/"DPMS"/"DPMS" "false"/g' /etc/X11/xorg.conf
        [[ ! -z $(pidof Xorg) ]] && pkill Xorg

        sudo systemctl stop display-manager
        sudo X :0 & 
    fi
}

function zhu-start-openbox {
    if [[ $XDG_SESSION_TYPE == tty ]]; then
        [[ -z $DISPLAY ]] && export DISPLAY=:0 
        [[ -z $(dpkg -l | grep "^ii  openbox ") ]] && sudo apt install -y openbox
        [[ $(systemctl is-active gdm3) == "active" ]] && sudo systemctl stop gdm3
        sudo sed -i 's/console/anybody/g' /etc/X11/Xwrapper.config

        sudo X -retro &
        sleep 2
        openbox --replace &
    fi
}

function zhu-test-maya-high-interrupt-count-on-gdm3 {
    zhu-perf-install 
    rm -rf /tmp/fps.log 

    if [[ -z $(which trace-cmd) ]]; then
        sudo apt install -y trace-cmd
    fi

    # Round 1 for the number of interrupts
    zhu-viewperf-maya-subtest5 &
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
        echo "" | sudo tee /sys/kernel/tracing/events/irq/irq_handler_entry/filter
        amdgpu_irq=$(grep 'amdgpu' /proc/interrupts | awk '{print $1}' | cut -d: -f1 | head -1)
        count=$(trace-cmd report | grep -i amdgpu | grep "irq=$amdgpu_irq" | wc -l)
        echo "The number of interrupts is $count" > /tmp/xxx.log
    fi

    # Round 2 for the time cost of interrupt handler (nvidia_isr/amdgpu_irq_handler)
    zhu-viewperf-maya-subtest5 &
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
    
    zhu-viewperf-maya-subtest5 & 
    mayapid=$!
    sleep 2

    zhu-perf-generate-flamegraph
    #zhu-record-interrupt-event
    wait $mayapid

    echo
    cat /tmp/fps.log 
    cat /tmp/xxx.log
}

function zhu-disable-nvidia-interrupt-handler {
    echo "options nvidia NVreg_EnableMSI=0" | sudo tee /etc/modprobe.d/nvidia-disable-interrupt-handler.conf
    sudo update-initramfs -u
    echo "A reboot is pending"
}

function zhu-enable-nvidia-interrupt-handler {
    sudo rm -rf /etc/modprobe.d/nvidia-disable-interrupt-handler.conf
    sudo update-initramfs -u
    echo "A reboot is pending"
}

function zhu-watch-interrupt-count {
    sudo perf stat -e irq:irq_handler_entry -I 1000 -a
}

function zhu-record-interrupt-event {
    sudo perf record -g -e irq:irq_handler_entry -a sleep 5
    sudo perf report --no-children --sort comm,dso
}

function zhu-mount-linuxqa {
    if [[ -z $(which showmount) ]]; then
        sudo apt install -y nfs-common
    fi
    if [[ -z $(which python) ]]; then
        sudo apt install -y python-is-python3
    fi

    showmount -e linuxqa
    sudo mkdir -p /mnt/linuxqa /mnt/data /mnt/builds /mnt/dvsbuilds
    sudo mount linuxqa:/storage/people     /mnt/linuxqa 
    sudo mount linuxqa:/storage/data       /mnt/data
    sudo mount linuxqa:/storage3/builds    /mnt/builds
    sudo mount linuxqa:/storage5/dvsbuilds /mnt/dvsbuilds
}

function zhu-sync {
    pushd ~/zhutest >/dev/null
    if git diff --quiet && git diff --cached --quiet; then # No local changes
        git pull
    else
        git add .
        git commit -m "$(date)"
        git pull
        git push
    fi
    popd >/dev/null 
    zhu-reload 
}

function zhu-download-nvidia-driver {
    if [[ -z $(apt list --installed 2>/dev/null | grep python3-pymysql) ]]; then 
        sudo apt install -y python3-pymysql axel 
    fi

    if ! mountpoint -q /mnt/linuxqa; then
        zhu-mount-linuxqa || return -1
    fi

    echo TODO
}

function zhu-install-nvidia-driver {
    mapfile -t files < <(find $P4ROOT/_out ~/Downloads -type f -name 'NVIDIA-*.run')
    ((${#files[@]})) || { echo "No nvidia .run found"; return -1; }
    select file in "${files[@]}"; do 
        [[ $file ]] && { 
            sudo systemctl stop display-manager 
            chmod +x $file 
            sudo $file  && {
                echo "Nvidia driver is installed!"
                read -e -i yes -p "Do you want to start display manager? " ans
                [[ $ans == yes ]] && sudo systemctl start display-manager
            } || cat /var/log/nvidia-installer.log
            return 
        }
        echo "Invalid choice, try again"
    done
}

function zhu-build-nvidia-driver {
    read -e -i amd64    -p "[1/3] Target architecture: " arch
    read -e -i release  -p "[2/3] Build type: " build_type
    read -e -i $(nproc) -p "[3/3] Number of build threads: " threads

    if [[ ! -d $P4ROOT ]]; then
        read -e -i "yes" -p "Pull the latest revision of $P4CLIENT? " ans
        if [[ $ans == yes ]]; then
            p4 sync -f //sw/...
        fi
    fi
    
    if [[ ! -e $HOME/wanliz-p4sw-common ]]; then
        P4CLIENT=wanliz-p4sw-common P4ROOT=$HOME/wanliz-p4sw-common p4 sync -f //sw/...
    fi

    if [[ -d drivers ]]; then
        time $HOME/wanliz-p4sw-common/misc/linux/unix-build \
            --tools  $HOME/wanliz-p4sw-common/tools \
            --devrel $HOME/wanliz-p4sw-common/devrel/SDK/inc/GL \
            --unshare-namespaces \
            nvmake \
            NV_COLOR_OUTPUT=1 \
            NV_GUARDWORD= \
            NV_COMPRESS_THREADS=$(nproc) \
            NV_FAST_PACKAGE_COMPRESSION=zstd drivers dist linux $arch $build_type -j$threads "$@"
    else
        time $HOME/wanliz-p4sw-common/misc/linux/unix-build \
            --tools  $HOME/wanliz-p4sw-common/tools \
            --devrel $HOME/wanliz-p4sw-common/devrel/SDK/inc/GL \
            --unshare-namespaces \
            nvmake \
            NV_COLOR_OUTPUT=1 \
            NV_GUARDWORD= \
            NV_COMPRESS_THREADS=$(nproc) \
            NV_FAST_PACKAGE_COMPRESSION=zstd linux $arch $build_type -j$threads "$@"
    fi
}

function zhu-lsfunc {
    declare -f | grep 'zhu-' | grep -v declare | grep '()'
}

function zhu-check-nvidia-gsp {
    nvidia-smi -q | grep GSP
}

function zhu-disable-nvidia-gsp {
    sudo su -c 'echo options nvidia NVreg_EnableGpuFirmware=0 > /etc/modprobe.d/nvidia-disable-gsp.conf'
    sudo update-initramfs -u 
    echo "GSP can only be disabled in nvidia's closed RM"
    echo "A reboot is pending"
}

function zhu-enable-nvidia-gsp {
    sudo rm -rf /etc/modprobe.d/nvidia-disable-gsp.conf
    sudo update-initramfs -u 
    echo "A reboot is pending"
}

function zhu-opengl-gpufps {
    if [[ ! -e /tmp/zhu-opengl-gpufps.so ]]; then
        gcc -c ~/zhutest/src/glad.c -fPIC -o /tmp/glad.a &&
        g++ -shared -fPIC -o /tmp/zhu-opengl-gpufps.so ~/zhutest/src/zhu-opengl-gpufps.cpp -ldl -lGL -lX11 /tmp/glad.a &&
        echo "Generated /tmp/zhu-opengl-gpufps.so" || return -1
    fi

    __GL_SYNC_TO_VBLANK=0 vblank_mode=0 LD_PRELOAD=/tmp/zhu-opengl-gpufps.so "$@"
}

function zhu-opengl-gpufps-rebuild {
    rm -rf /tmp/zhu-opengl-gpufps.so
    zhu-opengl-gpufps "$@"
}
