#!/bin/bash
export __GL_SYNC_TO_VBLANK=0
export vblank_mode=0
export __GL_DEBUG_BYPASS_ASSERT=c 

if [[ -z $DISPLAY ]]; then
    if [[ -e /tmp/.X11-unix/X0 ]]; then 
        export DISPLAY=:0
    elif [[ -e /tmp/.X11-unix/X1 ]]; then 
        export DISPLAY=:1
    fi
fi

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

    if [[ $UID != "0" ]]; then
        if ! sudo grep -q "$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
            echo "Enable sudo without password"
            echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
        fi
    fi 

    if [[ -z $(grep "nsight-systems-internal/current/host-linux-x64" ~/.bashrc) && -d ~/nsight-systems-internal/current/host-linux-x64 ]]; then
        echo "Append Nsight systems to \$PATH"
        echo "export PATH=\"~/nsight-systems-internal/current/host-linux-x64:\$PATH\"" >> ~/.bashrc
    fi

    if [[ -z $(grep "nsight-graphics-internal/current/host/linux-desktop-nomad-x64" ~/.bashrc) && -d ~/nsight-graphics-internal/current/host/linux-desktop-nomad-x64 ]]; then
        echo "Append Nsight graphics to \$PATH"
        echo "export PATH=\"~/nsight-graphics-internal/current/host/linux-desktop-nomad-x64:\$PATH\"" >> ~/.bashrc
    fi

    if [[ -z $(grep "export XAUTHORITY=" ~/.bashrc) ]]; then
        if [[ $XDG_SESSION_TYPE == x11 ]]; then
            echo "Enable remote users to run GUI applications"
            echo "export XAUTHORITY=$XAUTHORITY" >> ~/.bashrc
            echo "xhost +si:localuser:\$USER >/dev/null" >> ~/.bashrc
        fi
    fi
fi

function zhu-reload {
    if [[ -e ~/zhutest/utils.sh ]]; then
        source ~/zhutest/utils.sh
        echo "~/zhutest/utils.sh sourced!"
    else
        echo "~/zhutest/utils.sh doesn't exist!"
    fi
}

function zhu-is-installed {
    if [[ -z $(apt list --installed 2>/dev/null | grep "$1" | grep 'installed') ]]; then
        return -1
    else
        return 0
    fi
}

function zhu-connect-nvidia-vpn {
    if [[ -z $(which openconnect) ]]; then
        sudo apt install -y openconnect
    fi

    if [[ ! -z $(pidof openconnect) ]]; then
        read -e -i yes -p "Kill previous openconnect process ($(pidof openconnect))? " kill_old_oc
        if [[ $kill_old_oc == yes ]]; then
            sudo kill -SIGINT $(pidof openconnect)
            echo "Wait for 3 seconds after killing openconnect"
            sleep 3
        fi
    fi

    if [[ $1 != "headless" ]]; then
        if [[ ! -z $(which google-chrome) ]]; then
            echo "[1] google-chrome"
            echo "[2] firefox"
            read -e -i 1 -p "Select a browser to complete SSO Auth: " selection
            if [[ $selection == 1 ]]; then
                browser=$(which googlr-chrome)
            elif [[ $selection == 2 ]]; then
                browser=$(which firefox)
            else
                echo "Invalid input!"
                return -1
            fi
        else
            browser=$(which firefox)
        fi
    fi

    if [[ $1 == "cookie" ]]; then
        openconnect --useragent="AnyConnect-compatible OpenConnect VPN Agent" --external-browser $browser --authenticate ngvpn02.vpn.nvidia.com/SAML-EXT
    else 
        if [[ $1 == "headless" ]]; then
            while IFS= read -r line; do 
                if [[ -z "$line" ]]; then
                    break 
                fi
                export ${line%%=*}=${line#*=}
            done
        else
            eval $(openconnect --useragent="AnyConnect-compatible OpenConnect VPN Agent" --external-browser $browser --authenticate ngvpn02.vpn.nvidia.com/SAML-EXT)
        fi 
        [ -n ["$COOKIE"] ] && echo -n "$COOKIE" | sudo openconnect --cookie-on-stdin $CONNECT_URL --servercert $FINGERPRINT --resolve $RESOLVE 
    fi
}

function zhu-send-files {
    if [[ -z $(which sshpass) ]]; then
        sudo apt install -y sshpass
    fi
    if [[ -z $(which fzf) ]]; then
        sudo apt install -y fzf 
    fi 

    if [[ ! -e ~/.zhutest.client ]]; then
        read -p "Client IP: " client
        read -e -i macos -p "Client OS: " clientos
        read -e -i wanliz -p " Username: " username
        read -s -p " Password: " password
        echo "$username@$client $password $clientos" > ~/.zhutest.client
    fi

    files=$(find . -maxdepth 1 -mindepth 1 ! -name ".*" | sort | fzf -m) 
    echo "$files" > /tmp/files
    if [[ $(cat /tmp/files | wc -l) -gt 2 ]]; then
        read -e -i yes -p "Send compressed archive? " compress
        if [[ $compress == yes ]]; then
            read -e -i untitled.tar.gz -p "Archive name: " name
            tar -zcvf $name ${files//$'\n'/ } && files="$(realpath $name)" || echo "Failed to compress!" 
        fi
    fi 

    echo "$files" > /tmp/files
    total_bytes=$(awk '{total += $1} END {print total}' < <(xargs -a /tmp/files du -b | awk '{print $1}'))
    echo "Transferring $(cat /tmp/files | wc -l) files of $(echo $total_bytes | numfmt --to=iec)..."

    password=$(cat ~/.zhutest.client | awk '{print $2}')
    username=$(cat ~/.zhutest.client | awk '{print $1}' | awk -F '@' '{print $1}')
    hostname=$(cat ~/.zhutest.client | awk '{print $1}' | awk -F '@' '{print $2}')
    clientos=$(cat ~/.zhutest.client | awk '{print $3}')
    sshpass -p $password scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r ${files//$'\n'/ } $username@$hostname:/$([[ $clientos == macos ]] && echo Users || echo home)/$username/Downloads/
}

function zhu-validate-display {
    if [[ $(ls /tmp/.X11-unix | wc -l) == 0 ]]; then
        echo TODO

        while [[ -z $(pidof Xorg) ]]; do 
            echo "Wait for Xorg to start..."
            sleep 1
        done
        while ! $(which glxgear) >/dev/null 2>&1; do 
            echo "Wait for glxgears to success..."
            sleep 1
        done
    fi

    if [[ $(ls /tmp/.X11-unix | wc -l) == 0 ]]; then
        echo "Failed to open a display!"
        return -1
    fi
}

function zhu-set-env {
    for kv in "$@"; do 
        k=$(echo "$kv" | awk -F'=' '{print $1}')
        v=$(echo "$kv" | awk -F'=' '{print $2}')
        export $k="$v" 
        echo "export $k=\"$v\""
    done
}

function zhu-install-pts {
    [[ -z $(which curl) ]] && sudo apt install -y curl 
    latest_url=$(curl -s -L -o /dev/null -w "%{url_effective}\n"  https://github.com/phoronix-test-suite/phoronix-test-suite/releases/latest/)
    latest_tag=$(echo "$latest_url" | awk -F'/' '{print $NF}')
    
    pushd ~/Downloads >/dev/null 
    wget --no-check-certificate  https://github.com/phoronix-test-suite/phoronix-test-suite/releases/download/$latest_tag/phoronix-test-suite-${latest_tag:1}.tar.gz || return -1
    tar -zxvf phoronix-test-suite-${latest_tag:1}.tar.gz
    cd phoronix-test-suite
    sudo ./install-sh
    sudo apt install -y php-cli php-xml
    popd >/dev/null 
}

function zhu-install-lsgpus {
    if [[ -z $(which lsgpus) ]]; then
        zhu-fetch-from-linuxqa /mnt/nvtest/bin/Linux_amd64/lsgpus /usr/local/bin/
    fi
}

function zhu-install-perf {
    if ! zhu-is-installed linux-tools-$(uname -r); then 
        sudo apt install -y linux-tools-$(uname -r) linux-tools-generic >/dev/null 2>&1
    fi 

    if ! zhu-is-installed libtraceevent-dev; then 
        sudo apt install -y libtraceevent-dev >/dev/null 2>&1
    fi 

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

function zhu-perf-diff {
    if [[ -d $1 ]]; then
        perfdir1=$(realpath $1)
        perfdir2=$(realpath $2)
        if [[ ! -d $perfdir1 || ! -d $perfdir2 ]]; then
            echo "2 valid perf dirs are required!"
            return -1
        fi
        data1=$perfdir1/perf.data.folded
        data2=$perfdir2/perf.data.folded
    else
        data1=$(realpath $1)
        data2=$(realpath $2)
    fi

    if [[ "$data1" != *".folded" || "$data2" != *".folded" ]]; then
        echo "Input file must end with .folded"
        return -1
    fi

    ~/flamegraph.git/difffolded.pl -n -s $data1 $data2 > $(basename $data1)_$(basename $data2).diff.txt &&
    echo "Generated $(basename $data1)_$(basename $data2).diff.txt" &&
    cat $(basename $data1)_$(basename $data2).diff.txt | ~/flamegraph.git/flamegraph.pl > $(basename $data1)_$(basename $data2).diff.svg && 
    echo "Generated $(basename $data1)_$(basename $data2).diff.svg"
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

function zhu-generate-flamegraph {
    pushd $(dirname $1) >/dev/null && pwd 
    sudo chmod 666 $(basename $1)
    sudo perf script --no-inline --force --input=$(basename $1) -F +pid > $(basename $1).threads && echo "Generated $(basename $1).threads" &&
    sudo perf script --no-inline --force --input=$(basename $1) > /tmp/$(basename $1).script &&
    sudo ~/flamegraph.git/stackcollapse-perf.pl /tmp/$(basename $1).script > /tmp/$(basename $1).script.collapse &&
    sudo ~/flamegraph.git/stackcollapse-recursive.pl /tmp/$(basename $1).script.collapse > $(basename $1).folded && echo "Generated $(basename $1).folded" &&
    sort -k2 -nr $(basename $1).folded | head -n 1000 > $(basename $1).folded.top1k && echo "Generated $(basename $1)a.folded.top1k" &&
    sudo ~/flamegraph.git/flamegraph.pl $(basename $1).folded > $(basename $1).svg  && echo "Generated $(basename $1).svg" &&
    sudo ~/flamegraph.git/flamegraph.pl --minwidth '1%' $(basename $1).folded > $(basename $1).mini.svg  && echo "Generated $(basename $1).mini.svg" &&
    echo "[optional] Generating a text-based graph (this may take time). Press [CTRL-C] to cancel." && sudo perf report --stdio --show-nr-samples --show-cpu-utilization --threads --input=$(basename $1) > /tmp/$(basename $1).graph.txt &&
    mv /tmp/$(basename $1).graph.txt $(basename $1).graph.txt &&
    echo "Generated $(basename $1).graph.txt"
    popd >/dev/null 
}

function zhu-generate-perf-and-flamegraph {
    if [[ ! -e ~/flamegraph.git/flamegraph.pl ]]; then
        git clone --depth 1 https://github.com/brendangregg/FlameGraph.git ~/flamegraph.git || return -1
    fi

    output_dir=$1 
    if [[ -z $output_dir ]]; then
        output_dir=$(zhu-get-unused-filename systemperf)
    else
        output_dir=$(zhu-get-unused-filename $output_dir)
    fi
    mkdir -p $output_dir || return -1

    data_path=$output_dir/perf.data
    echo "perf is recording system-wide counters into $output_dir/perf.data for 5 seconds"
    sudo perf record -a -s -g --call-graph dwarf --freq=2000 --output=$data_path -- sleep 5 || return -1

    if [[ -e $data_path ]]; then
        zhu-generate-flamegraph $output_dir/perf.data
    fi 
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
        [[ -e /etc/X11/xorg.conf && -z $(grep '"DPMS" "false"' /etc/X11/xorg.conf) ]] && sudo sed -i 's/"DPMS"/"DPMS" "false"/g' /etc/X11/xorg.conf
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
    #zhu-record-interrupt-event
    wait $mayapid

    echo
    cat /tmp/fps.log 
    cat /tmp/xxx.log
}

function zhu-disable-nvidia-interrupt-handler {
    echo "options nvidia NVreg_EnableMSI=0" | sudo tee /etc/modprobe.d/nvidia-disable-interrupt-handler.conf
    sudo update-initramfs -u
    echo "[Action Required] Reboot system to activate changes!"
}

function zhu-enable-nvidia-interrupt-handler {
    sudo rm -rf /etc/modprobe.d/nvidia-disable-interrupt-handler.conf
    sudo update-initramfs -u
    echo "[Action Required] Reboot system to activate changes!"
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

    showmount -e linuxqa.nvidia.com >/dev/null || {
        echo "No access to linuxqa"
        return -1
    }

    sudo mkdir -p /mnt/linuxqa /mnt/data /mnt/builds /mnt/dvsbuilds
    
    if ! mountpoint -q /mnt/linuxqa; then
        sudo mount linuxqa.nvidia.com:/storage/people /mnt/linuxqa && echo "Mounted /mnt/linuxqa" 
    fi 
    if ! mountpoint -q /mnt/data; then
        sudo mount linuxqa.nvidia.com:/storage/data /mnt/data && echo "Mounted /mnt/data" 
    fi 
    if ! mountpoint -q /mnt/builds; then
        sudo mount linuxqa.nvidia.com:/storage3/builds /mnt/builds && echo "Mounted /mnt/builds" 
    fi 
    if ! mountpoint -q /mnt/dvsbuilds; then
        sudo mount linuxqa.nvidia.com:/storage5/dvsbuilds /mnt/dvsbuilds && echo "Mounted /mnt/dvsbuilds" 
    fi 
}

function zhu-fetch-from-linuxqa {
    [[ -z $(which curl) ]] && sudo apt install -y curl

    zhu-mount-linuxqa 

    if [[ -z $(ls /mnt/linuxqa) && -d "$2" ]]; then
        pushd "$2" >/dev/null 
        curl -k -# -O "${1//\/mnt\/linuxqa/http://linuxqa/people}" 
        popd >/dev/null 
    else
        rsync -ah --progress "$1" "$2" 
    fi
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

    #builds/daily/display/x86_64/dev/gpu_drv/bugfix_main ~/Downloads 
    echo TODO
}

function zhu-install-nvidia-driver {
    if [[ -e $1 ]]; then
        sudo systemctl stop display-manager 
        chmod +x $(realpath $1) 
        sudo $(realpath $1) && {
            echo "Nvidia driver is installed!"
            read -e -i yes -p "Do you want to start display manager? " start_dm
            [[ $start_dm == yes ]] && sudo systemctl start display-manager
        } || cat /var/log/nvidia-installer.log
    else
        mapfile -t files < <(find $P4ROOT/_out ~/Downloads -type f -name 'NVIDIA-*.run')
        ((${#files[@]})) || { echo "No nvidia .run found"; return -1; }
        select file in "${files[@]}"; do 
            [[ $file ]] && { 
                zhu-install-nvidia-driver $file 
                return 
            }
            echo "Invalid choice, try again"
        done
    fi
}

function zhu-build-nvidia-driver {
    read -e -i amd64    -p "[1/3] Target architecture: " arch
    read -e -i release  -p "[2/3] Build type: " build_type
    read -e -i $(nproc) -p "[3/3] Number of build threads: " threads

    if [[ ! -d $P4ROOT ]]; then
        read -e -i "yes" -p "Pull the latest revision of $P4CLIENT? " pull_p4client
        if [[ $pull_p4client == yes ]]; then
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

function zhu-list-functions {
    declare -f | grep 'zhu-' | grep -v declare | grep '()'
}

function zhu-check-nvidia-gsp {
    nvidia-smi -q | grep GSP
}

function zhu-disable-nvidia-gsp {
    sudo su -c 'echo options nvidia NVreg_EnableGpuFirmware=0 > /etc/modprobe.d/nvidia-disable-gsp.conf'
    sudo update-initramfs -u 
    echo "GSP can only be disabled in nvidia's closed RM"
    echo "[Action Required] Reboot system to activate changes!"
}

function zhu-enable-nvidia-gsp {
    sudo rm -rf /etc/modprobe.d/nvidia-disable-gsp.conf
    sudo update-initramfs -u 
    echo "[Action Required] Reboot system to activate changes!"
}

function zhu-opengl-gpufps {
    if [[ ! -d ~/zhutest ]]; then
        git clone --depth 1 https://github.com/wanlizhu/zhutest ~/zhutest
    fi

    rm -rf /tmp/zhu-opengl-gpufps.so
    gcc -c ~/zhutest/src/glad.c -fPIC -o /tmp/glad.a &&
    g++ -shared -fPIC -o /tmp/zhu-opengl-gpufps.so ~/zhutest/src/zhu-opengl-gpufps.cpp -ldl -lGL -lX11 /tmp/glad.a &&
    echo "Generated /tmp/zhu-opengl-gpufps.so" || return -1

    __GL_SYNC_TO_VBLANK=0 vblank_mode=0 LD_PRELOAD=/tmp/zhu-opengl-gpufps.so "$@"
}

function zhu-encrypt {
    read -s -p "Password: " passwd 
    echo -n "$1" | openssl enc -aes-256-cbc -pbkdf2 -iter 10000 -salt -base64 -A -pass "pass:${passwd}" 
}

function zhu-decrypt {
    read -s -p "Password: " passwd 
    echo -n "$1" | openssl enc -d -aes-256-cbc -pbkdf2 -iter 10000 -salt -base64 -A -pass "pass:${passwd}" 
}

function zhu-upgrade-nsight-systems {
    if [[ ! -e ~/.zhutest.artifactory.apikey ]]; then
        echo $(zhu-decrypt 'U2FsdGVkX18elI7G2zmszU2FUxbRUHvvE8I+ZRUBdyZVdczSVW59b/Klyq8fgihi2oIXR6P1zDVjptpwVemHV71PgHm6exawmqpqxpS6UuJfBTxiW60s4VR6JJVlWYVt') > ~/.zhutest.artifactory.apikey
    fi  

    ARTIFACTORY_API_KEY=$(cat ~/.zhutest.artifactory.apikey)
    latest_version=$(curl -s -H "X-JFrog-Art-Api: $ARTIFACTORY_API_KEY" https://urm.nvidia.com/artifactory/api/storage/swdt-nsys-generic/ctk/ \
        | jq -r '.children[] | .uri | select(test("^/[0-9]") and (test("^/202") | not))' \
        | sed 's/^\///' \
        | sort -Vr \
        | head -n1)
    latest_subver=$(curl -s -H "X-JFrog-Art-Api: $ARTIFACTORY_API_KEY" https://urm.nvidia.com/artifactory/api/storage/swdt-nsys-generic/ctk/$latest_version/ \
        | jq -r '.children[] | .uri | select(test("^/[0-9]"))' \
        | sed 's/^\///' \
        | sort -V \
        | tail -n1)

    if [[ -e ~/nsight-systems-internal/current ]]; then
        current=$(basename $(readlink ~/nsight-systems-internal/current))
        echo "Installed version is $current"
        if [[ $current == $latest_subver ]]; then
            echo "No need to upgrade"
            return 
        fi
    else
        echo "Installed version is NULL"
    fi
    
    read -p "Upgrade to $latest_subver? " upgrade_nsys 
    if [[ $upgrade_nsys == yes ]]; then
        pushd ~/Downloads >/dev/null
        wget --no-check-certificate --header="X-JFrog-Art-Api: $ARTIFACTORY_API_KEY" https://urm.nvidia.com/artifactory/swdt-nsys-generic/ctk/$latest_version/$latest_subver/nsight_systems-linux-x86_64-$latest_subver.tar.gz &&
        tar -zxvf nsight_systems-linux-x86_64-$latest_subver.tar.gz &&
        mkdir -p ~/nsight-systems-internal && 
        mv nsight_systems ~/nsight-systems-internal/$latest_subver &&
        pushd ~/nsight-systems-internal >/dev/null &&
        ln -sf $latest_subver current 
        popd >/dev/null 
        popd >/dev/null 
    fi
}

function zhu-find-package-by-libs {
    find /usr/lib -type f -name $1* | tee /tmp/so.list
    while IFS= read -r line; do
        dpkg -S $(realpath $line)
    done < /tmp/so.list
}

function zhu-find-libs-by-build-id {
    target=$("$1" | tr -d '/')
    find /usr/lib /usr/bin /lib /bin -type f | while read -r file; do
        build_id=$(readelf -n "$file" 2>/dev/null | grep 'Build ID')
        if [[ $build_id == *$target* ]]; then
            echo "File: $file"
            echo "$build_id"
        fi
    done
}

function zhu-find-debug-symbols-by-libs {
    if ! zhu-is-installed debian-goodies; then
        sudo apt install -y debian-goodies
    fi

    find /usr/lib -type f -name $1* | tee /tmp/so.list
    while IFS= read -r line; do
        find-dbgsym-packages $(realpath $line)
    done < /tmp/so.list
}

function zhu-install-amd-driver-with-symbols {
    echo "[1] Install debuginfod service to fetch debug symbols on demand (recommend)"
    echo "[2] Install traditional *-dbgsym packages for debug symbols"
    echo "[3] Install both"
    read -p "Select: " method
    
    if [[ $method == 1 || $method == 3 ]]; then
        sudo apt install -y debuginfod
        sudo apt install -y elfutils
        if ! grep "DEBUGINFOD_URLS" ~/.bashrc; then
            echo "export DEBUGINFOD_URLS=\"https://debuginfod.ubuntu.com/\"" >> ~/.bashrc
            source ~/.bashrc
        fi
        echo "The debuginfod service is installed!"
    fi 

    if [[ $method == 2 || $method == 3 ]]; then
        # The AMDGPU driver (amdgpu) is part of the Linux kernel
        if [[ ! -e /etc/apt/sources.list.d/ddebs.list ]]; then
            mkdir -p /etc/apt/sources.list.d
            sudo tee /etc/apt/sources.list.d/ddebs.list << EOF
deb http://ddebs.ubuntu.com/ $(lsb_release -cs) main restricted universe multiverse
deb http://ddebs.ubuntu.com/ $(lsb_release -cs)-updates main restricted universe multiverse
EOF
        fi

        sudo apt install -y ubuntu-dbgsym-keyring  # Import the debug symbol archive key
        sudo apt update | tee /tmp/apt-update.log
        if [[ -z $(cat /tmp/apt-update.log | grep "http://ddebs.ubuntu.com/ $(lsb_release -cs)" | grep "does not have a Release file") ]]; then
            sudo apt install -y linux-image-$(uname -r)-dbgsym  # This installs symbols for the kernel and its modules (including amdgpu)
            sudo apt install -y libdrm2-dbgsym libdrm-amdgpu1-dbgsym #mesa-dbgsym
            sudo apt install -y mesa-opencl-icd-dbgsym libgl1-mesa-dri-dbgsym libglapi-mesa-dbgsym  # Install debug symbols for OpenGL/OpenCL
            sudo apt install -y mesa-vulkan-drivers-dbgsym  # Install debug symbols for Mesa and Vulkan drivers
            sudo apt install -y xserver-xorg-video-amdgpu-dbgsym  # Install the Xorg AMDGPU display driver
            sudo apt install -y libglx-mesa0-dbgsym  # Install debug symbols for libGLX_mesa.so
            sudo apt install -y mesa-libgallium-dbgsym  # Install debug symbols for mesa-libgallium
            #sudo apt install -y mesa-va-drivers-dbgsym mesa-vdpau-drivers-dbgsym  # Install debug symbols for video decode/encode
            
            if [[ ! -e /usr/lib/debug/lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amd/amdgpu/amdgpu.ko && ! -e /usr/lib/debug/lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amd/amdgpu/amdgpu.ko.zst ]]; then
                echo "Debug symbols for the AMDGPU kernel driver are missing: /usr/lib/debug/lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amd/amdgpu/amdgpu.ko"
                return -1
            fi
            echo "Debug symbols for AMD GPU driver are installed!"
        else
            echo "The ddebs.ubuntu.com repo does not have debug symbols for your Ubuntu release ($(lsb_release -cs))"
        fi
    fi 
}

function zhu-record-cpu-utilization {
    if [[ -z $1 ]]; then
        echo "Usage 1: zhu-record-cpu-utilization <PID>"
        echo "Usage 2: zhu-record-cpu-utilization <program> [args...]"
        return -1
    else
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            target=$1
        else
            "$@" &
            target=$!
        fi 
    fi

    if [[ ! -d /proc/$target ]]; then
        echo "Target process $target is not running!"
        return -1
    fi

    if [[ -z $(which bc) ]]; then
        sudo apt install -y bc 
    fi

    file="/tmp/cpu-utilization.log"
    echo "Recording cpu utilization data to $file every second..."
    pidstat -t -u -p $target --human 1 | tee $file 

    if [[ ! -e ~/zhutest/src/visualize-csv-data.py ]]; then
        git clone --depth 1 https://github.com/wanlizhu/zhutest ~/zhutest
    fi
    python3 ~/zhutest/src/visualize-csv-data.py $file 
}

function zhu-record-gpu-utilization {
    if [[ -z $1 ]]; then
        echo "Manual termination mode is ON"
    else
        "$@" &
        target=$!
    fi

    if [[ -z $(which bc) ]]; then
        sudo apt install -y bc
    fi

    freq=20  # Can be less than 1
    file="/tmp/nvidia-gpu-utilization.log"
    echo "Recording gpu utilization data to $file at ${freq} Hz..."
    nvidia-smi --query-gpu=power.draw,temperature.gpu,utilization.gpu,utilization.memory,clocks.mem,clocks.gr --format=csv -lms $(bc -l <<< "x=1000/$freq; scale=0; x/1") > $file & 
    smipid=$!

    if [[ ! -z $1 ]]; then
        wait $target 
    else
        read -p "Press [ENTER] to stop recording: " _
    fi

    kill -SIGINT $smipid 
    sleep 1

    if [[ ! -e ~/zhutest/src/visualize-csv-data.py ]]; then
        git clone --depth 1 https://github.com/wanlizhu/zhutest ~/zhutest
    fi
    python3 ~/zhutest/src/visualize-csv-data.py $file 
}

function zhu-disable-nvidia-gpu {
    # Get a list of NVIDIA GPUs
    IFS=$'\n' read -d '' -r -a gpu_list < <(nvidia-smi --query-gpu=index,name,uuid --format=csv,noheader | nl -v0 -w1 -s': ')
    if [[ ${#gpu_list[@]} -eq 0 ]]; then
        echo "No NVIDIA GPU found!"
        return -1
    fi

    echo "Available NVIDIA GPUs:"
    printf '\t%s\n' "${gpu_list[@]}"
    echo "The physical monitor is connected to GPU-$(nvidia-smi --query-gpu=index,display_active --format=csv,noheader | grep Enabled | awk -F', ' '{print $1}') which must be enabled"

    # Ask for user selection
    while true; do 
        read -p "Enter GPU index to disable (0-$(( ${#gpu_list[@]} - 1 ))): " selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 0 ] && [ "$selection" -lt ${#gpu_list[@]} ]; then
            break
        fi
        echo "Invalid selection. Please enter a number between 0 and $(( ${#gpu_list[@]} - 1 ))"
    done

    is_driving_display=$(nvidia-smi --query-gpu=index,display_active --format=csv,noheader | awk -F', ' "\$1 == $selection {print \$2}")
    if [[ $is_driving_display == Enabled ]]; then
        echo "If you disable GPU-$selection, the display signal will be cut off, connect monitor to a second GPU now!"
        echo "Aborting..."
        return -1
    fi

    bus_id=$(nvidia-smi --query-gpu=index,pci.bus_id --format=csv,noheader | awk -F', ' "\$1 == $selection {print \$2}")
    vendor_id=$(lspci -nn -s $bus_id | awk -F'[][]' '{print $6}' | awk -F':' '{print $1}')
    dev_id=$(lspci -nn -s $bus_id | awk -F'[][]' '{print $6}' | awk -F':' '{print $2}')

    sudo mkdir -p /etc/udev/rules.d
    echo "ACTION==\"add\", SUBSYSTEM==\"pci\", ATTR{vendor}==\"0x$vendor_id\", ATTR{device}==\"0x$dev_id\", ATTR{enable}=\"0\"" | sudo tee /etc/udev/rules.d/99-disable-gpu.rules 
    sudo bash -c "sudo udevadm control --reload-rules; sudo udevadm trigger --action=add" &
    disown 
    echo "[Action Required] Reboot system to activate changes!"
}

function zhu-enable-nvidia-gpu-all {
    if [[ -e /etc/udev/rules.d/99-disable-gpu.rules ]]; then
        sudo rm -rf /etc/udev/rules.d/99-disable-gpu.rules
        sudo bash -c "sudo udevadm control --reload-rules; sudo udevadm trigger" &
        disown   
        echo "[Action Required] Reboot system to activate changes!"
    fi
}

function zhu-lscpu {
    bold='\033[1m'
    dim='\033[2m'
    reset='\033[0m'
    header_style='\033[1;37;44m'
    text_color='\033[38;5;250m'
    red_text_color='\033[38;5;196m'
    bg_colors=('\033[48;5;234m' '\033[48;5;239m')
    strike='\033[9m'  

    echo "Available CPU cores ($(lscpu -e=modelname | head -2 | tail -1)):"

    # Find P-cores (cores with multiple CPUs)
    declare -A core_counts
    while IFS=' ' read -r cpu core; do 
        ((core_counts[$core]++))
    done < <(lscpu -e=cpu,core | tail -n +2)

    # Show header
    echo -e "${header_style}CPU  CORE MAXMHZ    SCLMHZ%  ONLINE${reset}"

    # Show cpu data
    local color_idx=0 last_core=-1
    lscpu -e=cpu,core,maxmhz,scalmhz%,online | tail -n +2 | \
    while IFS=' ' read -r cpu core maxmhz scalmhz online; do 
        # Choose background color
        if [[ "$core" != "$last_core" ]]; then
            color_idx=$(( (color_idx + 1) % ${#bg_colors[@]} ))
            last_core=$core 
        fi

        # Finalize style
        if [[ $online == "yes" ]]; then
            if [[ ${core_counts[$core]} -gt 1 ]]; then
                style="${bg_colors[$color_idx]}${red_text_color}${bold}"
            else
                style="${bg_colors[$color_idx]}${text_color}"
            fi
        else
            style="${bg_colors[$color_idx]}${text_color}${dim}${strike}"
        fi

        # Print out
        printf "${style}%-4s %-4s %-7s %-8s %-6s${reset}\n" \
               "$cpu" "$core" "$maxmhz" "$scalmhz" "$online"
    done
}

function zhu-disable-cpu-cores {
    if [[ -z $1 ]]; then 
        zhu-lscpu 
        read -p "Enter cores to disable (e.g. 2,3,5-7): " cores
        if [[ ! "$cores" =~ ^[0-9,-]+$ ]]; then
            echo "Invalid input!"
            return -1
        fi
    else 
        cores="$1"
    fi

    expanded=($(echo "$cores" | tr ',' '\n' | \
        while read part; do
            if [[ "$part" =~ - ]]; then
                seq -s ' ' ${part%-*} ${part#*-} 
            else
                echo $part
            fi 
        done | tr '\n' ' '))
    
    count=0
    for core in "${expanded[@]}"; do 
        sysfile="/sys/devices/system/cpu/cpu$core/online"
        if [[ ! -f $sysfile ]]; then
            echo "Core $core doesn't exist" 
            continue 
        fi
        if [[ $core -eq 0 ]]; then
            echo "Can't disable CPU0 (system required)"
            continue 
        fi

        current=$(cat $sysfile)
        if [[ $current -eq 1 ]]; then
            echo "0" | sudo tee $sysfile >/dev/null  
            ((count++))
        fi
    done

    zhu-lscpu 
    echo "Put $count cpu cores OFFLINE!"
}

function zhu-enable-cpu-cores-all {
    present=$(cat /sys/devices/system/cpu/present)
    IFS=',' read -ra ranges <<< "$present"
    cores=() 
    for range in "${ranges[@]}"; do 
        if [[ $range == *-* ]]; then
            start=${range%-*}
            end=${range#*-}
            for ((core=start; core<=end; core++)); do
                cores+=("$core")
            done
        else
            cores+=("$range")
        fi
    done

    count=0
    for core in "${cores[@]}"; do 
        [[ $core -eq 0 ]] && continue 
        sysfile="/sys/devices/system/cpu/cpu$core/online"
        if [[ -f $sysfile ]]; then
            if [[ $(cat $sysfile) == "0" ]]; then
                echo "1" | sudo tee $sysfile >/dev/null 
                ((count++))
            fi 
        fi
    done

    zhu-lscpu 
    echo "Put $count cpu cores back ONLINE!"
}

function zhu-install-fex {
    if [[ -z $(which FEXInterpreter) ]]; then
        sudo apt update
        sudo apt install -y python3 python3-venv ninja-build \
            libepoxy-dev libsdl2-dev libssl-dev libglib2.0-dev \
            libpixman-1-dev libslirp-dev debootstrap git
        git clone --depth 1 https://github.com/FEX-Emu/FEX.git ~/FEX.git
        pushd ~/FEX.git >/dev/null 
        ./Scripts/InstallFEX.py 
        popd >/dev/null 
    fi
}

function zhu-disable-wayland {
    if [[ $XDG_SESSION_TYPE == "tty" ]]; then
        # Config gdm3
        sudo cp /etc/gdm3/custom.conf /etc/gdm3/custom.conf.backup
        sudo sed -i 's/^#WaylandEnable=.*/WaylandEnable=false/' /etc/gdm3/custom.conf || {
            echo -e "\n[daemon]\nWaylandEnable=false" | tee -a /etc/gdm3/custom.conf >/dev/null
        }

        read -e -i yes -p "Restart display-manager to activate changes? " restart_dm
        if [[ $restart_dm == yes ]]; then
            if [[ $XDG_SESSION_TYPE == tty ]]; then
                sudo systemctl restart display-manager
            else
                echo "Run via SSH or TTY!"
                return -1
            fi
        fi
    fi
}

function zhu-cursor-location-to-active-window {
    if [[ -z $(which xdotool) ]]; then
        sudo apt install -y xdotool || return -1
    fi 

    while true; do
        eval $(xdotool getmouselocation --shell)
        cursor_x=$X 
        cursor_y=$Y 

        window_id=$(xdotool getactivewindow)
        eval $(xdotool getwindowgeometry --shell $window_id)
        window_x=$X 
        window_y=$Y 
        window_w=$WIDTH 
        window_h=$HEIGHT 

        client_x=$window_x 
        client_y=$(xwininfo -id $window_id | grep -oP "(?<=Absolute upper-left Y:).*")

        cursor_x_to_client=$((cursor_x - client_x))
        cursor_y_to_client=$((cursor_y - client_y))

        echo 
        echo "Window ID: $window_id"
        echo "Window name: $(xdotool getwindowname $window_id)"
        echo "Cursor offset to client area TL: [$cursor_x_to_client, $cursor_y_to_client]"
        sleep 1
    done
}

function zhu-activate-window {
    rm -rf /tmp/zhu-activate-window
    while [[ $(xdotool getwindowname $(xdotool getactivewindow) 2>/dev/null) != "$1" ]]; do 
        echo "Activate window \"$1\"..."
        sleep 1
    done 
    echo "$(xdotool getactivewindow)" > /tmp/zhu-activate-window
}

function zhu-cursor-click-on-window {
    if [[ -z $3 ]]; then
        echo "Usage: zhu-cursor-click-on-window <window name> <relative x> <relative y>"
        return -1
    fi

    zhu-activate-window "$1"
    window_id=$(cat /tmp/zhu-activate-window)
    xdotool mousemove --window $window_id $2 $3 click 1
}

function zhu-test-3dmark-attan-wildlife {
    zhu-validate-display || return -1

    if [[ ! -e ~/zhutest-workload.d/3dmark-attan-wildlife-1.1.2.1 ]]; then
        which rsync >/dev/null || sudo apt install -y rsync
        zhu-fetch-from-linuxqa /mnt/linuxqa/nvtest/pynv_files/3DMark/3DMark_Attan_Wild_Life/3dmark-attan-extreme-1.1.2.1-workload-bin.zip ~/Downloads/ || return -1

        which unzip >/dev/null || sudo apt install -y unzip 
        mkdir -p ~/zhutest-workload.d/3dmark-attan-wildlife-1.1.2.1 
        pushd ~/zhutest-workload.d/3dmark-attan-wildlife-1.1.2.1 >/dev/null || return -1
        unzip ~/Downloads/3dmark-attan-extreme-1.1.2.1-workload-bin.zip || return -1
        popd >/dev/null 
    fi

    if [[ $(uname -m) == "aarch64" ]]; then
        zhu-install-fex || return -1
    fi

    pushd ~/zhutest-workload.d/3dmark-attan-wildlife-1.1.2.1 >/dev/null 
    rm -rf result.json
    chmod +x run_linux_x64.sh 
    ./run_linux_x64.sh || return -1

    which jq >/dev/null || sudo apt install -y jq 
    result=$(jq -r '.outputs[] | select(.outputType == "TYPED_RESULT") | .value' result.json)
    echo "3DMark - Wildlife - Vulkan rasterization"
    echo "Typed result: $result FPS"
    popd >/dev/null 
}

function zhu-test-3dmark-disco-steelnomad {
    zhu-validate-display || return -1

    if [[ ! -e ~/zhutest-workload.d/3dmark-disco-steelnomad-1.0.0 ]]; then
        which rsync >/dev/null || sudo apt install -y rsync
        zhu-fetch-from-linuxqa /mnt/linuxqa/nvtest/pynv_files/3DMark/3DMark_Disco_Steel_Nomad/3dmark-disco-1.0.0-bin.zip ~/Downloads/ || return -1

        which unzip >/dev/null || sudo apt install -y unzip 
        mkdir -p ~/zhutest-workload.d/3dmark-disco-steelnomad-1.0.0 
        pushd ~/zhutest-workload.d/3dmark-disco-steelnomad-1.0.0 >/dev/null || return -1
        unzip ~/Downloads/3dmark-disco-1.0.0-bin.zip || return -1
        popd >/dev/null 
    fi

    if [[ $(uname -m) == "aarch64" ]]; then
        zhu-install-fex || return -1
    fi

    pushd ~/zhutest-workload.d/3dmark-disco-steelnomad-1.0.0 >/dev/null 
    rm -rf result_vulkan.json
    chmod +x run_workload_linux_vulkan.sh
    ./run_workload_linux_vulkan.sh || return -1

    which jq >/dev/null || sudo apt install -y jq 
    result=$(jq -r '.outputs[] | select(.outputType == "TYPED_RESULT") | .value' result_vulkan.json)
    echo "3DMark - Steel Nomad - Modern Vulkan rasterization"
    echo "Typed result: $result FPS"
    popd >/dev/null 
}

function zhu-test-3dmark-pogo-solarbay {
    zhu-validate-display || return -1

    if [[ ! -e ~/zhutest-workload.d/3dmark-pogo-solarbay-1.0.5.3 ]]; then
        which rsync >/dev/null || sudo apt install -y rsync
        zhu-fetch-from-linuxqa /mnt/linuxqa/nvtest/pynv_files/3DMark/3DMark_Pogo_Solar_Bay/3dmark-pogo-1.0.5.3-bin.zip ~/Downloads/ || return -1

        which unzip >/dev/null || sudo apt install -y unzip 
        mkdir -p ~/zhutest-workload.d/3dmark-pogo-solarbay-1.0.5.3
        pushd ~/zhutest-workload.d/3dmark-pogo-solarbay-1.0.5.3 >/dev/null || return -1
        unzip ~/Downloads/3dmark-pogo-1.0.5.3-bin.zip || return -1
        popd >/dev/null 
    fi

    if [[ $(uname -m) == "aarch64" ]]; then
        zhu-install-fex || return -1
    fi

    pushd ~/zhutest-workload.d/3dmark-pogo-solarbay-1.0.5.3 >/dev/null 
    rm -rf result.json
    chmod +x run_dev_player_linux_x64.sh
    ./run_dev_player_linux_x64.sh || return -1

    which jq >/dev/null || sudo apt install -y jq 
    result=$(jq -r '.outputs[] | select(.outputType == "TYPED_RESULT" and .resultType == "") | .value' result.json)
    echo "3DMark - Solar Bay - Vulkan raytracing"
    echo "Typed result: $result FPS"
    popd >/dev/null 
}

function zhu-fetch-from-data-server {
    if [[ -z $(which sshpass) ]]; then
        sudo apt install -y sshpass
    fi

    if [[ ! -e ~/.zhurc.data.server ]]; then
        read -p "Data server IP: " ip
        read -e -i wanliz -p "Data server username: " user
        read -s -p "Data server password: " passwd
        echo "$user@$ip $passwd" > ~/.zhurc.data.server
    fi

    remote=$(cat ~/.zhurc.data.server | awk '{print $1}')
    passwd=$(cat ~/.zhurc.data.server | awk '{print $2}')

    sshpass -p "$passwd" rsync -ah --progress $remote:"$1" "$2"
}

function zhu-rebuild-dpkg-database {
    sudo rm -rf /var/lib/dpkg/*
    sudo apt-get install --reinstall dpkg
    sudo apt update && sudo apt upgrade -y
}

function zhu-fex-run {
    [[ -z $(which jq) ]] && sudo apt install -y jq 
    rootfs="$HOME/.fex-emu/RootFS/$(jq -r '.Config.RootFS' $HOME/.fex-emu/Config.json)"
    if [[ -d $rootfs ]]; then 
        sudo chroot $rootfs /usr/bin/bash -c "$@"
    fi 
}

function zhu-fex-fetch-packages {
    [[ -z $(which jq) ]] && sudo apt install -y jq 
    rootfs="~/.fex-emu/$(jq -r '.Config.RootFS' ~/.fex-emu/Config.json)"

    if [[ ! -e ~/.zhurc.data.server ]]; then
        read -p "Data server IP: " ip
        read -e -i wanliz -p "Data server username: " user
        read -s -p "Data server password: " passwd
        echo "$user@$ip $passwd" > ~/.zhurc.data.server
    fi

    remote=$(cat ~/.zhurc.data.server | awk '{print $1}')
    passwd=$(cat ~/.zhurc.data.server | awk '{print $2}')

    sshpass -p "$passwd" ssh $remote "dpkg -L $1" >/tmp/dpkg.log || return -1
    count=0
    while IFS= read -r line; do
        if [[ ! -d $line ]]; then
            echo "$line"
            $((count++))
        fi 
    done < /tmp/dpkg.log
    read -e -i yes -p "Fetch these $count files into $rootfs? (yes/no): " ans
    if [[ $ans != yes ]]; then
        return -1
    fi 

    while IFS= read -r line; do
        if [[ ! -d $line ]]; then
            sshpass -p "$passwd" rsync -ah --progress $remote:$line $rootfs$line 
        fi 
    done < /tmp/dpkg.log 
}

function zhu-test-unigine-heaven {
    zhu-validate-display || return -1

    if [[ ! -e ~/zhutest-workload.d/unigine-heaven-1.6.5 ]]; then
        phoronix-test-suite install pts/unigine-heaven-1.6.5 
        pushd ~/.phoronix-test-suite/installed-tests/pts/unigine-heaven-1.6.5 >/dev/null && {
            mkdir -p ~/zhutest-workload.d/unigine-heaven-1.6.5
            rsync -ah --progress ./Unigine_Heaven-4.0/ ~/zhutest-workload.d/unigine-heaven-1.6.5 || return -1
            popd >/dev/null
        } || {
            zhu-fetch-from-data-server /home/wanliz/.phoronix-test-suite/installed-tests/pts/unigine-heaven-1.6.5/Unigine_Heaven-4.0/ ~/zhutest-workload.d/unigine-heaven-1.6.5 || return -1
        }
    fi

    if [[ $(uname -m) == "aarch64" ]]; then
        zhu-install-fex || return -1
    fi

    pushd ~/zhutest-workload.d/unigine-heaven-1.6.5 >/dev/null 
    LD_LIBRARY_PATH=bin/:bin/x64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH} ./bin/heaven_x64 -data_path ../ -sound_app null -engine_config ../data/heaven_4.0.cfg -system_script heaven/unigine.cpp -video_mode -1 -extern_define PHORONIX,RELEASE -video_width 1920 -video_height 1080 -video_fullscreen 1 -video_app opengl > /tmp/unigine-heaven.log  || return -1
    cat /tmp/unigine-heaven.log | grep "FPS:"
    popd >/dev/null 
}

function zhu-test-unigine-vally {
    zhu-validate-display || return -1

    if [[ ! -e ~/zhutest-workload.d/unigine-valley-1.1.8 ]]; then
        phoronix-test-suite install pts/unigine-valley-1.1.8
        pushd ~/.phoronix-test-suite/installed-tests/pts/unigine-valley-1.1.8 >/dev/null && { 
            mkdir -p ~/zhutest-workload.d/unigine-valley-1.1.8
            rsync -ah --progress ./Unigine_Valley-1.0/ ~/zhutest-workload.d/unigine-valley-1.1.8 || return -1
            popd >/dev/null
        } || {
            zhu-fetch-from-data-server /home/wanliz/.phoronix-test-suite/installed-tests/pts/unigine-valley-1.1.8/Unigine_Valley-1.0/ ~/zhutest-workload.d/unigine-valley-1.1.8 || return -1
        }
    fi 

    if [[ $(uname -m) == "aarch64" ]]; then
        zhu-install-fex || return -1
    fi

    pushd ~/zhutest-workload.d/unigine-valley-1.1.8  >/dev/null 
    LD_LIBRARY_PATH=bin/:bin/x64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH} ./bin/valley_x64 -data_path ../ -sound_app null -engine_config ../data/valley_1.0.cfg -system_script valley/unigine.cpp -video_mode -1 -extern_define PHORONIX,RELEASE -video_width 1920 -video_height 1080 -video_fullscreen 1 -video_app opengl > /tmp/unigine-valley.log 
    cat /tmp/unigine-valley.log | grep "FPS:"  || return -1
    popd >/dev/null 
}

function zhu-test-unigine-superposition {
    zhu-validate-display || return -1

    if [[ ! -e ~/zhutest-workload.d/unigine-super-1.0.7 ]]; then
        phoronix-test-suite install pts/unigine-super-1.0.7 
        pushd ~/.phoronix-test-suite/installed-tests/pts/unigine-super-1.0.7 >/dev/null && { 
            mkdir -p ~/zhutest-workload.d/unigine-super-1.0.7
            rsync -ah --progress ./Unigine_Superposition-1.0/ ~/zhutest-workload.d/unigine-super-1.0.7 || return -1
            popd >/dev/null
        } || {
            zhu-fetch-from-data-server /home/wanliz/.phoronix-test-suite/installed-tests/pts/unigine-super-1.0.7/Unigine_Superposition-1.0/ ~/zhutest-workload.d/unigine-super-1.0.7 || return -1
        }
    fi 

    if [[ $(uname -m) == "aarch64" ]]; then
        zhu-install-fex || return -1
    fi

    pushd ~/zhutest-workload.d/unigine-super-1.0.7  >/dev/null 
    ./bin/superposition -sound_app openal  -system_script superposition/system_script.cpp  -data_path ../ -engine_config ../data/superposition/unigine.cfg  -video_mode -1 -project_name Superposition  -video_resizable 1  -console_command "config_readonly 1 && world_load superposition/superposition" -mode 2 -preset 0 -video_width 1920 -video_height 1080 -video_fullscreen 1 -shaders_quality 2 -textures_quality 2 -video_app opengl 
    cat ~/.Superposition/automation/log*.txt > /tmp/unigine-super.log 
    cat /tmp/unigine-super.log | grep "^FPS:"  || return -1
    popd >/dev/null 
}

function zhu-install-viewperf {
    if [[ $(uname -m) != "x86_64" ]]; then
        read -p "Install amd64 based viewperf on $(uname -m) host? (ctrl-c to cancel): " _
    fi

    if [[ ! -e ~/zhutest-workload.d/viewperf2020/viewperf/bin/viewperf ]]; then
        which rsync >/dev/null || sudo apt install -y rsync 
        zhu-fetch-from-linuxqa /mnt/linuxqa/nvtest/pynv_files/viewperf2020v3/viewperf2020v3.tar.gz ~/Downloads/ || return -1
        
        pushd ~/Downloads >/dev/null
        tar -zxvf viewperf2020v3.tar.gz
        mkdir -p ~/zhutest-workload.d
        mv viewperf2020 ~/zhutest-workload.d/viewperf2020
        popd >/dev/null
    fi

    if [[ -z $(which xmllint) ]]; then
        sudo apt install -y libxml2 libxml2-utils
    fi
}

function zhu-install-viewperf-aarch64 {
    if [[ $(uname -m) != "aarch64" ]]; then
        read -p "Install aarch64 based viewperf on $(uname -m) host? (ctrl-c to cancel): " _
    fi
    echo 
}

function zhu-test-viewperf {
    zhu-validate-display || return -1

    if [[ $(uname -m) == x86_64 ]]; then
        zhu-install-viewperf || return -1
    elif [[ $(uname -m) == aarch64 ]]; then
        zhu-install-viewperf-aarch64 || return -1
    else
        return -1
    fi

    pushd ~/zhutest-workload.d/viewperf2020 >/dev/null 
    if [[ -z "$1" || "$1" == *"catia"* ]]; then
        mkdir -p results/catia-06 
        ./viewperf/bin/viewperf viewsets/catia/config/catia.xml -resolution 1920x1080 && cat results/catia-06/results.xml || echo "Failed to run viewsets/catia"
    fi 

    if [[ -z "$1" || "$1" == *"creo"* ]]; then
        mkdir -p results/creo-03
        ./viewperf/bin/viewperf viewsets/creo/config/creo.xml -resolution 1920x1080 && cat results/creo-03/results.xml || echo "Failed to run viewsets/creo"
    fi 

    if [[ -z "$1" || "$1" == *"energy"* ]]; then
        mkdir -p results/energy-03
        ./viewperf/bin/viewperf viewsets/energy/config/energy.xml -resolution 1920x1080 && cat results/energy-03/results.xml || echo "Failed to run viewsets/energy"
    fi 

    if [[ -z "$1" || "$1" == *"maya"* ]]; then
        mkdir -p results/maya-06 
        ./viewperf/bin/viewperf viewsets/maya/config/maya.xml -resolution 1920x1080 && cat results/maya-06/results.xml || echo "Failed to run viewsets/maya"
    fi 

    if [[ -z "$1" || "$1" == *"medical"* ]]; then
        mkdir -p results/medical-03
        ./viewperf/bin/viewperf viewsets/medical/config/medical.xml -resolution 1920x1080 && cat results/medical-03/results.xml || echo "Failed to run viewsets/medical"
    fi 

    if [[ -z "$1" || "$1" == *"snx"* ]]; then
        mkdir -p results/snx-04
        ./viewperf/bin/viewperf viewsets/snx/config/snx.xml -resolution 1920x1080 && cat results/snx-04/results.xml || echo "Failed to run viewsets/snx"
    fi 

    if [[ -z "$1" || "$1" == *"sw"* ]]; then
        mkdir -p results/solidworks-07
        ./viewperf/bin/viewperf viewsets/sw/config/sw.xml -resolution 1920x1080 && cat results/solidworks-07/results.xml || echo "Failed to run viewsets/sw"
    fi 
    popd >/dev/null 
}

function zhu-test-viewperf-in-gui {
    zhu-validate-display || return -1
   
    if [[ $(uname -m) == x86_64 ]]; then
        zhu-install-viewperf || return -1
    elif [[ $(uname -m) == aarch64 ]]; then
        zhu-install-viewperf-aarch64 || return -1
    else
        return -1
    fi

    # Start all viewsets in viewperf GUI
    ~/zhutest-workload.d/viewperf2020/RunViewperf 
    zhu-cursor-click-on-window "SPECviewperf 2020 v3.0" 441 550
    window_id=$(cat /tmp/zhu-activate-window)

    # Wait all viewsets to complete
    while [[ ! -z $(pidof viewperf) ]]; do
        sleep 5
    done 

    # Close the configuration window
    xdotool mousemove --window $window_id 620 21 click 1

    # Find the result directory 
    result_dir=$(find ~/Documents/SPECresults/SPECviewperf2020 -mindepth 1 -maxdepth 1 -type d -printf "%T@ %p\n" | sort -n | tail -n 1 | awk '{print $2}')
    sed -i '1s/^.*$/Compositor,FPS/' "$result_dir/resultCSV.csv"
    mapfile -d '' csv_parts < <(awk 'BEGIN {RS="(\n\n|\n[[:space:]]*\n)"; ORS="\0"} {print}' "$result_dir/resultCSV.csv")
    for i in "${!csv_parts[@]}"; do 
        echo "${csv_parts[i]}" | column -s, -t
        echo 
    done
}

function zhu-test-viewperf-maya-subtest5 {
    zhu-validate-display || return -1
    
    if [[ $(uname -m) == x86_64 ]]; then
        zhu-install-viewperf || return -1
    elif [[ $(uname -m) == aarch64 ]]; then
        zhu-install-viewperf-aarch64 || return -1
    else
        return -1
    fi

    pushd ~/zhutest-workload.d/viewperf2020 >/dev/null
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

function zhu-list-steam-games {
    steam_root="$HOME/.steam"
    steam_root=$(readlink -f "$steam_root")

    libfile="$steam_root/steam/steamapps/libraryfolders.vdf"
    if [[ ! -e "$libfile" ]]; then
        echo "$libfile doesn't exist!"
        return -1
    fi

    rm -rf /tmp/steam-games.list
    libpaths=$(grep -Eo '"path"[[:space:]]+".+"' "$libfile" | awk -F'"' '{print $4}')
    echo "App ID,Game Name,Installation Path" > /tmp/steam-games.list

    for libpath in $libpaths; do 
        find "$libpath/steamapps" -maxdepth 1 -name 'appmanifest_*.acf' -print0 | \
        while IFS= read -r -d '' manifest; do 
            app_id=$(basename "$manifest" | cut -d_ -f2 | cut -d. -f1)
            name=$(grep -Eo '"name"[[:space:]]+".+"' "$manifest" | awk -F'"' '{print $4}')
            dir=$(grep -Eo '"installdir"[[:space:]]+".+"' "$manifest" | awk -F'"' '{print $4}')
            fulldir="$libpath/steamapps/common/$dir"
            echo "$app_id,$name,$fulldir" >> /tmp/steam-games.list
        done
    done 

    column -s, -t /tmp/steam-games.list
}

function zhu-fex-install-nvidia-dso {
    amd64_libs="$HOME/.fex-emu/RootFS/Ubuntu_24_04/lib/x86_64-linux-gnu"
    for dso in *.so.575.25; do 
        cp -vf ./$dso $amd64_libs/$dso 
        pushd $amd64_libs >/dev/null 
        ln -sf $dso $(echo $dso | cut -d'.' -f1-2).0
        ln -sf $dso $(echo $dso | cut -d'.' -f1-2).1
        ln -sf $dso $(echo $dso | cut -d'.' -f1-2).2
        popd >/dev/null 
    done

    pushd 32 >/dev/null 
    i386_libs="$HOME/.fex-emu/RootFS/Ubuntu_24_04/lib/i386-linux-gnu"
    for dso in *.so.575.25; do 
        cp -vf ./$dso $i386_libs/$dso 
        pushd $i386_libs >/dev/null 
        ln -sf $dso $(echo $dso | cut -d'.' -f1-2).0
        ln -sf $dso $(echo $dso | cut -d'.' -f1-2).1
        ln -sf $dso $(echo $dso | cut -d'.' -f1-2).2
        popd >/dev/null 
    done
    popd >/dev/null 

    cp -vf ./nvidia_icd.json "$HOME/.fex-emu/RootFS/Ubuntu_24_04/etc/vulkan/icd.d/nvidia_icd.json"
}

function zhu-check-xauthority {
    if [[ -z $(pidof Xorg) ]]; then
        echo "X server is not running"
        return -1
    fi

    if [[ ! -e ~/.Xauthority ]]; then  
        active_auth=$(ps aux | grep '[X]org' | grep -oP '(?<=-auth )[^ ]+')
        if [[ -z $active_auth ]]; then
            echo "\"ps aux | grep '[X]org'\" returns no auth path"
        else
            sudo cp $active_auth ~/.Xauthority
            sudo chown $USER:$(id -gn) ~/.Xauthority
            chmod 666 ~/.Xauthority
        fi 
    fi

    if [[ -z $XAUTHORITY && -e ~/.Xauthority ]]; then
        export XAUTHORITY=~/.Xauthority
    fi

    if [[ -z $(which glxgears) ]]; then
        sudo apt install -y mesa-utils 
    fi

    glxgears & 
    sleep 1
    if [[ -z $(pidof glxgears) ]]; then
        echo "$XAUTHORITY is invalid!"
        return -1
    fi
    kill -INT $(pidof glxgears)
}

function zhu-startx-with-openbox {
    if [[ ! -z $(pidof Xorg) ]]; then
        read -p "Kill running X server ($(pidof Xorg))? (yes/no): " ans
        if [[ $ans == yes ]]; then
            sudo kill -INT $(pidof Xorg)
            sleep 2
        else
            return -1
        fi
    fi

    sudo apt install -y xorg openbox 
    if [[ -z $(which screen) ]]; then
        sudo apt install -y screen 
    fi

    if [[ -e ~/.xinitrc ]]; then
        read -p "Remove existing ~/.xinitrc? (yes/no): " ans
        if [[ $ans == yes ]]; then
            sudo rm -rf ~/.xinitrc
        fi
    fi

    if [[ ! -e ~/.xinitrc ]]; then
        echo "exec openbox-session" > ~/.xinitrc 
        chmod +x ~/.xinitrc
    fi

    sudo sed -i 's/console/anybody/g' /etc/X11/Xwrapper.config

    read -e -i yes -p "Start X in detached screen? (yes/no): " ans
    if [[ $ans == yes ]]; then
        screen -dmS xsession startx
    else
        startx &
    fi
    sleep 3

    if [[ -z $(pidof Xorg) ]]; then
        sleep 5
        echo "Failed to start Xorg with openbox!"
        return -1
    else
        echo "Xorg ($(pidof Xorg)) is running with openbox"
    fi
}

function zhu-check-vncserver {
    sudo ss -tulpn | grep -E "5900|5901|5902"
}

function zhu-start-vnc-server-for-headless-system {
    if [[ ! -z $(zhu-check-vncserver) ]]; then
        zhu-check-vncserver
        echo "VNC server is already running..."
        return 
    fi  

    if [[ -z $(which screen) ]]; then
        sudo apt install -y screen 
    fi

    if [[ -z $(dpkg -l | grep tigervnc-standalone-server) ]]; then
        sudo apt install -y tigervnc-standalone-server
        sudo apt install -y tigervnc-common
    fi 

    echo "[1] xfce4"
    read -e -i 1 -p "What session to start in virtual desktop: " ans

    if [[ $ans == 1 ]]; then
        desktop_session=/usr/bin/xfce4-session
        if [[ -z $(dpkg -l | grep xfce4-session) ]]; then
            sudo apt install -y xfce4-session
        fi 
    else
        echo "Invalid input!"
        return -1
    fi 

    mkdir -p ~/.vnc
    tigervncpasswd
    
    echo "#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec $desktop_session
" > ~/.vnc/xstartup
    chmod +x ~/.vnc/xstartup

    read -p "Start virtual desktop on display 0 or 1: " dp
    vncserver_args="-localhost no :$dp -geometry 3840x2160 -depth 24"

    read -e -i no -p "Autostart on boot? (yes/no): " autostart
    if [[ $autostart == yes ]]; then
        echo "[Unit]
Description=TigerVNC server
After=syslog.target network.target

[Service]
Type=forking
User=$USER
WorkingDirectory=$HOME
ExecStartPre=-/usr/bin/tigervncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/tigervncserver $vncserver_args :%i
ExecStop=/usr/bin/tigervncserver -kill :%i

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/tigervncserver@.service
        sudo systemctl daemon-reload
        sudo systemctl enable tigervncserver@$dp.service
        sudo systemctl start tigervncserver@$dp.service
    else
        #zhu-check-xauthority || return -1
        export DISPLAY=:$dp 
        /usr/bin/tigervncserver -kill :$dp >/dev/null 2>&1
        screen -dmS tigervncserver /usr/bin/tigervncserver $vncserver_args :$dp 
        sleep 1
        /usr/bin/tigervncserver -list 
    fi
}

function zhu-start-vnc-server-for-physical-display {
    if [[ ! -z $(zhu-check-vncserver) ]]; then
        zhu-check-vncserver
        echo "VNC server is already running..."
        return 
    fi  

    if [[ -z $(pidof Xorg) ]]; then
        echo "Xorg is not running, a running X server is required for x11vnc!"
        echo "[1] Start Xorg without a session"
        echo "[2] Start Xorg with openbox"
        echo "[3] Start Xorg with display-manager"
        read -p "Select: " selection

        if [[ -z $(which screen) ]]; then
            sudo apt install -y screen 
        fi

        if [[ $selection == 1 ]]; then
            if [[ $UID == 0 ]]; then
                screen -dmS xsession X :0
            else
                sudo screen -dmS xsession X :0
            fi
        elif [[ $selection == 2 ]]; then
            zhu-startx-with-openbox || return -1
        elif [[ $selection == 3 ]]; then
            sudo systemctl start display-manager || return -1
        else
            return -1
        fi
    fi

    while [[ -z $(pidof Xorg) ]]; do 
        sleep 3
        if [[ -z $(pidof Xorg) ]]; then
            echo "[$(date)] Wait for Xorg to start up..."
        fi 
    done

    if [[ -z $(dpkg -l | grep x11vnc) ]]; then
        sudo apt install -y x11vnc
    fi 

    x11vnc -storepasswd
    x11vnc_args="-auth guess -forever --loop -noxdamage -repeat -rfbauth $HOME/.vnc/passwd -rfbport 5900 -display :0 -shared"

    read -e -i no -p "Autostart on boot? (yes/no): " autostart
    if [[ $autostart == yes ]]; then
        echo "[Unit]
Description=x11vnc service
After=display-manager.service

[Service]
ExecStart=/usr/bin/x11vnc $x11vnc_args 
User=$USER
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/x11vnc.service
        sudo systemctl enable x11vnc.service 
        sudo systemctl start x11vnc.service 
        echo "x11vnc.service is running and scheduled as auto-start!"
    else
        zhu-check-xauthority || return -1
        screen -dmS x11vncserver /usr/bin/x11vnc $x11vnc_args
    fi
}

function zhu-start-vnc-server {
    echo "[1] Tiger VNC (virtual desktop for headless system, rendering in llvmpipe, not using GPU, not running Xorg)"
    echo "[2] X11 VNC (mirrors physical display)"
    read -p "Which VNC server to start? : " selection

    if [[ $selection == 1 ]]; then
        zhu-start-vnc-server-for-headless-system
    elif [[ $selection == 2 ]]; then
        zhu-start-vnc-server-for-physical-display
    fi
}

function zhu-enable-x11-forwarding {
    if sudo grep -Eq "^X11Forwarding\s+yes" /etc/ssh/sshd_config; then
        echo "X11 forwarding is already enabled!"
        return
    fi

    if ! dpkg -l | grep -q xauth; then
        sudo apt install -y xauth 
    fi

    sudo sed -i '/^#*X11Forwarding[[:space:]]/cX11Forwarding yes' /etc/ssh/sshd_config
    sudo systemctl restart ssh
    echo "X11 forwarding enabled!"
}

function zhu-ssh-regen-xauthority {
    if [[ -z $DISPLAY ]]; then
        echo "\$DISPLAY is NULL!"
        return -1
    fi

    rm ~/.Xauthority
    xauth generate $DISPLAY . trusted || return -1
    export XAUTHORITY=~/.Xauthority
}