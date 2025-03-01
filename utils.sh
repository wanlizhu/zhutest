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

function zhu-config-sudo {
    if ! sudo grep -q "$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
        echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
    fi
}

function zhu-config-path {
    for dir in "~/nsight-systems-internal/current/host-linux-x64" \
               "~/nsight-graphics-internal/current/host/linux-desktop-nomad-x64"; do 
        if ! grep "$dir" ~/.bashrc; then
            echo "PATH=\"$dir:\$PATH\"" >> ~/.bashrc
        fi 
    done
}

function zhu-is-installed {
    if [[ -z $(apt list --installed 2>/dev/null | grep "$1" | grep 'installed') ]]; then
        return -1
    else
        return 0
    fi
}

function zhu-config-nvidia-laptop {
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
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
        read -e -i yes -p "Send compressed archive? " ans
        if [[ $ans == yes ]]; then
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
        echo 0 | sudo tee /sys/kernel/tracing/events/irq/irq_handler_entry/filter
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

    cd /mnt/builds/daily/display/x86_64/dev/gpu_drv/bugfix_main
    echo TODO
}

function zhu-install-nvidia-driver {
    if [[ -e $1 ]]; then
        sudo systemctl stop display-manager 
        chmod +x $(realpath $1) 
        sudo $(realpath $1) && {
            echo "Nvidia driver is installed!"
            read -e -i yes -p "Do you want to start display manager? " ans
            [[ $ans == yes ]] && sudo systemctl start display-manager
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
    
    read -p "Upgrade to $latest_subver? " ans 
    if [[ $ans == yes ]]; then
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

function zhu-nvidia-gpu-utilization {
    if [[ ! -z $1 ]]; then
        "$@"
        target=$!
    fi

    freq=50
    file="/tmp/nvidia-gpu-utilization.log"
    echo "Recording gpu utilization data to $file at ${freq}Hz..."
    nvidia-smi --query-gpu=power.draw,temperature.gpu,utilization.gpu,utilization.memory,clocks.mem,clocks.gr --format=csv -lms $((1000/$freq)) > $file & 
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