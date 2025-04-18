#!/bin/bash
export __GL_SYNC_TO_VBLANK=0
export vblank_mode=0
export __GL_DEBUG_BYPASS_ASSERT=c 
export NVM_GTLAPI_USER=wanliz 

if [[ $(ulimit -c) == 0 ]]; then
    ulimit -c unlimited
fi

if [[ -z $DISPLAY ]]; then
    if [[ -z $(ls /tmp/.X11-unix 2>/dev/null) ]]; then
        export DISPLAY=:0
    elif [[ -e /tmp/.X11-unix/X0 ]]; then 
        export DISPLAY=:0
    elif [[ -e /tmp/.X11-unix/X1 ]]; then 
        export DISPLAY=:1
    elif [[ -e /tmp/.X11-unix/X2 ]]; then 
        export DISPLAY=:2
    fi
fi

function zhu-uname-m2 {
    if [[ $(uname -m) == x86_64 ]]; then
        echo "x64"
    elif [[ $(uname -m) == aarch64 ]]; then
        echo "arm64"
    fi
}

function zhu-enable-coredump {
    sudo apt install -y systemd-coredump
    sudo snap set system system.coredump.enable=true
}

function zhu-update-path {
    if ! echo "$PATH" | tr ':' '\n' | grep -q "dvs/dvsbuild"; then
        export PATH="$P4ROOT_BFM/automation/dvs/dvsbuild:$PATH" 
    fi

    if ! echo "$PATH" | tr ':' '\n' | grep -q "nsight-systems-internal"; then
        export PATH="~/nsight-systems-internal/current/bin:$PATH"
    fi

    if ! echo "$PATH" | tr ':' '\n' | grep -q "nsight-graphics-internal"; then
        export PATH="~/nsight-graphics-internal/current/host/linux-desktop-nomad-x64:$PATH"
    fi

    if ! echo "$PATH" | tr ':' '\n' | grep -q "gfxreconstruct.git"; then
        export PATH="~/gfxreconstruct.git/build/linux/x64/output/bin:$PATH"
    fi

    if ! echo "$PATH" | tr ':' '\n' | grep -q "apitrace.$(uname -m)"; then
        export PATH="~/apitrace.$(uname -m)/bin:$PATH"
    fi
}

function zhu-setup-nopasswd-sudo {
    if [[ $UID != "0" ]]; then
        if ! sudo grep -q "$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
            echo "Enable sudo without password"
            echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
        fi
    fi 
}

function zhu-set-p4client {
    if [[ $1 == bugfix_main ]]; then
        export P4CLIENT=wanliz-p4sw-bugfix_main
    elif [[ $1 == r575 ]]; then
        export P4CLIENT=wanliz-p4sw-r575_00
    else
        echo "Unknown client name: $1"
        return -1
    fi 
    export P4ROOT=/media/wanliz/wzhu-ssd-ext4-4t/$P4CLIENT
}

if [[ $USER == wanliz ]]; then
    export P4CLIENT=wanliz-p4sw-bugfix_main
    export P4ROOT=/media/wanliz/wzhu-ssd-ext4-4t/$P4CLIENT
    export P4ROOT_BFM=/media/wanliz/wzhu-ssd-ext4-4t/wanliz-p4sw-bugfix_main
    export P4IGNORE=/home/wanliz/.p4ignore 
    export P4PORT=p4proxy-sc.nvidia.com:2006
    export P4USER=wanliz 

    if [[ ! -e $P4IGNORE && -d $(dirname $P4IGNORE) ]]; then
        echo "_out" > $P4IGNORE
        echo ".git" >> $P4IGNORE
        echo ".vscode" >> $P4IGNORE
    fi

    zhu-setup-nopasswd-sudo
    zhu-update-path

    if [[ $(uname -m) == aarch64 ]]; then
        if [[ -e $HOME/.fex-emu/Config.json ]]; then
            which jq >/dev/null || sudo apt install -y jq 
            export rootfs="$HOME/.fex-emu/RootFS/$(jq -r '.Config.RootFS' $HOME/.fex-emu/Config.json)"
        fi 
    fi

    if [[ $DISPLAY == *"localhost"* ]]; then
        # When X11 forwarding is enabled
        export XAUTHORITY=~/.Xauthority
    fi 

    if [[ -z $XAUTHORITY ]]; then
        if [[ -e ~/.zhurc.xauth ]]; then
            source ~/.zhurc.xauth
        fi
    fi

    if [[ $XDG_SESSION_TYPE == x11 ]]; then
        xhost + >/dev/null 2>&1
    fi
fi

if [[ -d $HOME/zhutest/nvbugs ]]; then
    for file in $HOME/zhutest/nvbugs/*.sh; do 
        source $file 
    done 
fi

function zhu-reload {
    if [[ -e ~/zhutest/env.sh ]]; then
        source ~/zhutest/env.sh
        echo "~/zhutest/env.sh sourced!"
    else
        echo "~/zhutest/env.sh doesn't exist!"
    fi
}

function zhu-enable-no-password-sudo {
    if [[ $UID != "0" ]]; then
        if ! sudo grep -q "$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
            echo "Enable no-password sudo for $USER"
            echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
        fi
    fi 
}

function zhu-setup-nvidia-ddns {
    sudo mkdir -p /etc/dhcp/dhclient-exit-hooks.d
    sudo cp ~/zhutest/etc/ddns-for-dhcp /etc/dhcp/dhclient-exit-hooks.d/ddns
    sudo chmod 755 /etc/dhcp/dhclient-exit-hooks.d/ddns

    sudo mkdir -p /etc/NetworkManager/dispatcher.d
    sudo cp ~/zhutest/etc/ddns-for-networkmanager /etc/NetworkManager/dispatcher.d/ddns
    sudo chmod 755 /etc/NetworkManager/dispatcher.d/ddns

    echo "Todo: reboot your system to apply changes!"
}

function zhu-is-installed {
    if [[ -z $(apt list --installed 2>/dev/null | grep "$1" | grep 'installed') ]]; then
        return -1
    else
        return 0
    fi
}

function zhu-nvidia-vpn {
    if [[ -z $(which openconnect) ]]; then
        sudo apt install -y openconnect  || return -1
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
            read -p "Select a browser to complete SSO Auth: " selection
            if [[ $selection == 1 ]]; then
                browser=$(which google-chrome)
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
        sudo apt install -y sshpass  || return -1
    fi
    if [[ -z $(which fzf) ]]; then
        sudo apt install -y fzf  || return -1
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
    if [[ ! -d /tmp/.X11-unix ]]; then
        return 
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
    sudo apt install -y php-cli php-xml || return -1
    popd >/dev/null 
}

function zhu-build-perf {
    read -e -i yes -p "Rebuild perf to link against libtraceevent? (yes/no): " rebuildperf
    if [[ $rebuildperf == yes ]]; then 
        sudo apt install -y systemtap-sdt-dev libperl-dev libbabeltrace-dev libcapstone-dev openjdk-8-jdk libpfm4-dev || return -1
        sudo apt install -y libunwind-dev binutils-dev || return -1
        sudo apt install -y libtraceevent-dev libtracefs-dev || return -1
        sudo apt install -y flex bison libelf-dev libdw-dev libiberty-dev libslang2-dev libunwind-dev || return -1
        git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git ~/linux-kernel-torvalds.git || return -1
        pushd ~/linux-kernel-torvalds.git/tools/perf >/dev/null 
        make clean && make && sudo cp -vf perf /usr/bin/perf 
        popd >/dev/null
    fi 
}

function zhu-install-perf {
    if [[ -z $(which perf) || "$1" == -f ]]; then
        if ! zhu-is-installed linux-tools-$(uname -r); then 
            sudo apt install -y linux-tools-$(uname -r) linux-tools-generic >/tmp/apt.log 2>&1 || {
                cat /tmp/apt.log
                zhu-build-perf
                return 
            }
        fi 

        if ! zhu-is-installed libtraceevent-dev; then 
            sudo apt install -y libtraceevent-dev >/dev/null 2>&1
        fi 

        sudo perf stat -e irq:irq_handler_entry sleep 1 >/dev/null 2>&1 || zhu-build-perf 
    fi 
}

function zhu-perftop {
    zhu-install-perf || return -1
    if [[ -z $1 ]]; then
        read -p "CPU id to monitor: " cpu
        read -p "Pin a running process to CPU $cpu (ProcName or blank to skip): " proc_name
        if [[ ! -z "$proc_name" && ! -z $(pidof $proc_name) ]]; then
            taskset -pc $cpu $(pidof $proc_name)
        fi 
    else
        cpu=$1
    fi
    sudo perf top -C $cpu --sort comm,dso
}

function zhu-install-ubuntu-desktop {
    sudo apt install -y ubuntu-desktop || return -1
    sudo apt install -y gdm3 || return -1
    sudo systemctl set-default graphical.target || return -1
    sudo systemctl start gdm3 || return -1
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
    sort -k2 -nr $(basename $1).folded | head -n 1000 > $(basename $1).head1000.folded && echo "Generated $(basename $1).head1000.folded" &&
    sudo ~/flamegraph.git/flamegraph.pl $(basename $1).folded > $(basename $1).svg  && echo "Generated $(basename $1).svg" &&
    sudo ~/flamegraph.git/flamegraph.pl --minwidth '1%' $(basename $1).folded > $(basename $1).minwidth1.svg  && echo "Generated $(basename $1).minwidth1.svg" 
    if [[ -e $(basename $1).svg ]]; then
        read -e -i no -p "Generate a text-based graph (this may take time)? (yes/no): " ans
        if [[ $ans == yes ]]; then
            sudo perf report --stdio --show-nr-samples --show-cpu-utilization --threads --input=$(basename $1) > /tmp/$(basename $1).graph.txt &&
            mv /tmp/$(basename $1).graph.txt $(basename $1).graph.txt &&
            echo "Generated $(basename $1).graph.txt"
        fi 
    fi 
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

    if [[ -z $duration ]]; then
        duration=5
    fi

    if [[ -z $frequency ]]; then
        frequency=5000
    fi

    data_path=$output_dir/perf.data
    echo "perf is recording system-wide counters into $output_dir/perf.data in $frequency Hz for $duration seconds"
    sudo perf record -a -s -g --call-graph dwarf --freq=$frequency --output=$data_path -- sleep $duration || return -1

    if [[ -e $data_path ]]; then
        zhu-generate-flamegraph $output_dir/perf.data
    fi 
}

function zhu-gdm3 {
    if [[ $XDG_SESSION_TYPE == tty ]]; then
        sudo kill -15 $(pidof Xorg)
        sleep 1
        sudo systemctl start gdm3
    fi
}

function zhu-virtual-desktop-with-vnc {
    zhu-vnc-server-for-headless-system || return -1
    echo "DISPLAY=$DISPLAY"
    xrandr | grep current
    ip a | grep 'inet '
}

function zhu-share-desktop {
   zhu-xserver-with-vnc
}

function zhu-disable-xhost-access-control {
    if [[ -z $DISPLAY ]]; then
        export DISPLAY=:0
    fi
    xhost +
}

function zhu-xserver-with-vnc {
    if [[ -z $(pidof Xorg) ]]; then
        zhu-xserver || return -1
    fi
    zhu-vnc-server-for-physical-display || return -1
    echo "DISPLAY=$DISPLAY"
    xrandr | grep current
    ip a | grep 'inet '
}

function zhu-xserver {
    # When run via SSH/TTY session
    if [[ ! -z $(who am i) ]]; then 
        if [[ $EUID == 0 ]]; then
            SUDO=""
        else
            SUDO="sudo"
        fi
        #xset -dpms
        #xset s off 
        #[[ -e /etc/X11/xorg.conf && -z $(grep '"DPMS" "false"' /etc/X11/xorg.conf) ]] && sudo sed -i 's/"DPMS"/"DPMS" "false"/g' /etc/X11/xorg.conf

        $SUDO sed -i 's/console/anybody/g' /etc/X11/Xwrapper.config
        if [[ $(systemctl is-active display-manager) == active ]]; then
            $SUDO systemctl stop display-manager
            sleep 1
        fi 
        if [[ ! -z $(pidof Xorg) ]]; then
            $SUDO kill -15 $(pidof Xorg)
            sleep 1
        fi 

        if [[ $1 == -i ]]; then
            read -e -i yes -p "Run X server and detach? (yes/no): " ans
        else
            ans=yes 
            echo "Run X server and detach"
        fi 

        if [[ $ans == yes ]]; then
            if [[ -z $(which screen) ]]; then
                sudo apt install -y screen 
            fi
            XAUTHORITY_backup=$XAUTHORITY
            export XAUTHORITY=""
            $SUDO screen -dmS xserver X :0 +iglx
            export DISPLAY=:0
            export XAUTHORITY=$XAUTHORITY_backup 
            sleep 1
            if [[ -z $(pidof Xorg) ]]; then
                echo "Failed to start up a new Xorg session!"; return -1
            else
                echo "Xorg $(pidof Xorg) has started!"
            fi
        else
            XAUTHORITY_backup=$XAUTHORITY
            export XAUTHORITY=""
            $SUDO X :0 +iglx
            export XAUTHORITY=$XAUTHORITY_backup 
        fi 
    else
        echo "Please run via SSH/TTY session!"
        return -1
    fi
}

function zhu-replace-with-openbox {
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

function zhu-perf-interrupt-watch {
    sudo perf stat -e irq:irq_handler_entry -I 1000 -a
}

function zhu-perf-interrupt-event {
    sudo perf record -g -e irq:irq_handler_entry -a sleep 5
    sudo perf report --no-children --sort comm,dso
}

function zhu-mount-linuxqa {
    if [[ -z $(which showmount) ]]; then
        sudo apt install -y nfs-common || return -1
    fi
    if [[ -z $(which python) ]]; then
        sudo apt install -y python-is-python3 || return -1
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

function zhu-sync {
    pushd ~/zhutest >/dev/null
    if [[ -z $(git config --global user.email) ]]; then
        git config --global user.email $(zhu-decrypt 'U2FsdGVkX19KUswOw0hyRRQtNQ6m7bcXF3aactpxMAXPGCn773g12rgFZ1BH6EIm')
    fi
    if [[ -z $(git config --global user.name) ]]; then
        git config --global user.name 'Wanli Zhu'
    fi
    if [[ -z $(git config --global pull.rebase) ]]; then
        git config --global pull.rebase false # merge
    fi

    if grep -q '://github.com/wanlizhu' .git/config; then
        github_token=$(zhu-decrypt 'U2FsdGVkX19LlJjrMCdfxGhU6d+rsxF4IhqaohiteKeVwM0WHGsCPL1z3kHo/xoH07+Qgf5yi9genmTamuF01g==')
        if [[ $(uname -o) == Darwin ]]; then
            # macOS uses BSD sed
            sed -i "" "s|://github.com/wanlizhu|://wanlizhu:$github_token@github.com/wanlizhu|g" .git/config
        else # Linux uses GNU sed
            sed -i "s|://github.com/wanlizhu|://wanlizhu:$github_token@github.com/wanlizhu|g" .git/config
        fi 
    fi

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
        sudo apt install -y python3-pymysql axel  || return -1
    fi

    #builds/daily/display/x86_64/dev/gpu_drv/bugfix_main ~/Downloads 
    echo TODO
}

function zhu-kill-xorg {
    sudo kill -15 $(pidof Xorg)
}

function zhu-unload-nvidia-modules {
    count=3
    killproc=
    while [[ $count != "0" ]]; do 
        if [[ -z $(sudo fuser -v /dev/nvidia*) ]]; then
            break
        fi
        
        if [[ -z $killproc ]]; then 
            sudo fuser -v /dev/nvidia*
            read -e -i yes -p "Kill above process? (yes/no): " killproc
        fi 

        if [[ $killproc == yes ]]; then
            for pid in $(sudo fuser -v /dev/nvidia* | grep -v 'COMMAND' | awk '{print $3}' | sort  | uniq); do 
                sudo kill -9 $pid 
            done
        else
            break 
        fi

        sleep 1
        count=$((count - 1))
    done 
}

function zhu-install-nvidia-driver-wanliz-build {
    read -e -i wanliz-test.client.nvidia.com -p "Rsync driver from host: " host
    read -e -i r575_00 -p "Branch: " branch
    read -e -i $(uname -m) -p "Arch (x86_64/aarch64): " arch
    read -e -i release -p "Config: " config
    read -e -i $(ls /usr/lib/*-linux-gnu/libnvidia-glcore.so.*  | awk -F '.so.' '{print $2}' | head -1) -p "Version: " version
    
    rsync -ah --progress wanliz@$host:/media/wanliz/wzhu-ssd-ext4-4t/wanliz-p4sw-$branch/_out/Linux_${arch/x86_64/amd64}_${config}/NVIDIA-Linux-${arch}-${version}-internal.run /tmp/NVIDIA-Linux-${arch}-${version}-internal.run || return -1
    zhu-install-nvidia-driver-localbuild /tmp/NVIDIA-Linux-${arch}-${version}-internal.run
}

function zhu-install-nvidia-driver-localbuild {
    if [[ ! -e $1 ]]; then
        echo "Error: $1 doesn't exist!"
        return -1
    fi 

    if [[ -z $(which pkg-config) ]]; then
        sudo apt install -y pkg-config libglvnd-dev
    fi

    if [[ $(systemctl is-active display-manager) == active ]]; then
        was_dm_active=yes
        sudo systemctl stop display-manager 
    else
        was_dm_active=no
    fi

    if [[ ! -z $(pidof Xorg) ]]; then
        echo "Xorg $(pidof Xorg) is still running..."
        read -e -i yes -p "Kill this Xorg process? (yes/no): " killXorg
        if [[ $killXorg == yes ]]; then
            sudo kill -15 $(pidof Xorg)
            sleep 1
        else
            return -1
        fi
    fi

    zhu-unload-nvidia-modules 

    if [[ "$(realpath $1)" != "/mnt/linuxqa/"* ]]; then
        chmod +x $(realpath $1) 
    fi 

    sudo rm -rf /var/log/nvidia-installer.log
    sudo $(realpath $1) \
        && echo "Nvidia driver is installed!" \
        || cat /var/log/nvidia-installer.log

    if [[ $was_dm_active == yes ]]; then 
        read -e -i yes -p "Do you want to start display manager? " start_dm
        if [[ $start_dm == yes ]]; then 
            sudo systemctl start display-manager
        fi 
    fi 

    if [[ $(uname -m) == aarch64 ]]; then
        read -e -i yes -p "Enable max clocks? (yes/no): " maxclocks 
        if [[ $maxclocks == yes ]]; then
            zhu-digits-max-clocks 
        fi
    fi
}

function zhu-install-nvidia-driver-prebuilt {
    zhu-install-nvidia-driver-dvsbuild
}

function zhu-install-nvidia-driver-dvsbuild {
    zhu-mount-linuxqa || return -1
    path="/mnt"
    echo "[1] release build"
    echo "[2] daily bugfix_main build"
    echo "[3] daily r123_00 build"
    echo "[4] dvs build"
    read -p "Select: " type

    if [[ $type == 1 ]]; then
        path="$path/builds/release/display/$(uname -m)"
        read -e -i release -p "Configure (release/debug/develop): " config
        subdir=$([[ $config == release ]] && echo "" || echo "/$config")
        if [[ ! -d $path$subdir ]]; then
            echo "$config build is not available under $path!"
            return -1
        fi
        read -p "Release version: " drv_version
        path="$path$subdir/$drv_version/NVIDIA-Linux-$(uname -m)-$drv_version.run"
    elif [[ $type == 2 ]]; then
        path="$path/builds/daily/display/$(uname -m)/dev/gpu_drv/bugfix_main"
        read -e -i release -p "Configure (release/debug/develop): " config
        subdir=$([[ $config == release ]] && echo "" || echo "/$config")
        if [[ ! -d $path$subdir ]]; then
            echo "$config build is not available under $path!"
            return -1
        fi
        read -p "Build date (yyyymmdd): " drv_date
        path="$path$subdir/${drv_date}_*/NVIDIA-Linux-$(uname -m)-dev_gpu_drv_bugfix_main-${drv_date}_*.run"
    elif [[ $type == 3 ]]; then
        path="$path/builds/daily/display/$(uname -m)/rel/gpu_drv"
        read -p "Major version: " major
        path="$path/r$major/r${major}_00"
        read -e -i release -p "Configure (release/debug/develop): " config
        subdir=$([[ $config == release ]] && echo "" || echo "/$config")
        read -e -i current -p "Build date (yyyymmdd): " drv_date
        if [[ $drv_date == current ]]; then
            path="$path$subdir/current/NVIDIA-Linux-$(uname -m)-rel_gpu_drv_r${major}_r${major}_00-*.run"
        else
            path="$path$subdir/${drv_date}_*/NVIDIA-Linux-$(uname -m)-rel_gpu_drv_r${major}_r${major}_00-${drv_date}_*.run"
        fi 
    elif [[ $type == 4 ]]; then
        path="$path/dvsbuilds/gpu_drv_bugfix_main_Release_Linux_$(uname -m)_unix-build_Test_Driver"
        read -p "Change list number: " changelist
        path="$path/SW_$changelist.0_*"
        paths="$path/NVIDIA-Linux-$(uname -m)-DVS-internal.run"
        path=${path//x86_64/AMD64}
        path=${path//aarch64_unix-build_Test_Driver/aarch64_unix-build_Driver}
    else
        return -1
    fi

    if [[ -e $(realpath $path) ]]; then
        zhu-install-nvidia-driver-localbuild "$(realpath $path)" || return -1
        if [[ $(uname -m) == aarch64 && -d ~/.fex-emu/RootFS ]]; then
            echo 
            driver="$(realpath $path)"
            driver="${driver//aarch64/x86_64}"
            echo "$driver"
            read -e -i yes -p "Install this x86_64 build into FEX rootfs? (yes/no): " ans
            if [[ $ans == yes ]]; then
                mkdir -p $HOME/Downloads
                timestamp=$(date +%s)
                mkdir -p /tmp/$timestamp
                rsync -ah --progress $driver /tmp/$timestamp/$(basename $driver) || return -1
                zhu-install-nvidia-driver-in-fex /tmp/$timestamp/$(basename $driver)
            fi
        fi
    else
        echo "$path not found!"
        return -1
    fi  
}

function zhu-build-nvidia-driver {
    pushd . >/dev/null

    sudo apt install -y libelf-dev &>/dev/null 
    if [[ ! -e ./makefile.nvmk ]]; then
        read -e -i yes -p "Change workdir to $P4ROOT? (yes/no): " cdroot
        if [[ $cdroot == yes ]]; then
            cd $P4ROOT
        fi 
    fi

    if [[ -z "$1" ]]; then
        nvmake_args="drivers dist linux amd64 release -j$(nproc)"
        echo "$nvmake_args"
        read -p "Press [ENTER] to continue: " _
    else
        nvmake_args="$@"
    fi 

    if [[ "$1" == sweep ]]; then
        $P4ROOT_BFM/misc/linux/unix-build \
            --tools  $P4ROOT_BFM/tools \
            --devrel $P4ROOT_BFM/devrel/SDK/inc/GL \
            --unshare-namespaces \
            nvmake sweep 
        return 
    fi

    time $P4ROOT_BFM/misc/linux/unix-build \
        --tools  $P4ROOT_BFM/tools \
        --devrel $P4ROOT_BFM/devrel/SDK/inc/GL \
        --unshare-namespaces \
        nvmake \
        NV_COLOR_OUTPUT=1 \
        NV_GUARDWORD= \
        NV_COMPRESS_THREADS=$(nproc) \
        NV_FAST_PACKAGE_COMPRESSION=zstd       $nvmake_args \
        && echo "[$(date)] Nvmake succeeded -- $nvmake_args" | tee -a /tmp/nvmake.log \
        || echo "[$(date)] Nvmake failed    -- $nvmake_args" | tee -a /tmp/nvmake.log

    popd >/dev/null
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
    echo "[Action Required] Reboot system to activate changes!"
}

function zhu-enable-nvidia-gsp {
    sudo rm -rf /etc/modprobe.d/nvidia-disable-gsp.conf
    sudo update-initramfs -u 
    echo "[Action Required] Reboot system to activate changes!"
}

function zhu-gpufps {
    if [[ ! -d ~/zhutest ]]; then
        git clone https://github.com/wanlizhu/zhutest ~/zhutest || return -1
    fi

    rm -rf /tmp/zhutest-gpufps.so
    gcc -c ~/zhutest/src/zhutest-gpufps/glad.c -fPIC -o /tmp/glad.a &&
    g++ -shared -fPIC -o /tmp/zhutest-gpufps.so ~/zhutest/src/zhutest-gpufps/dsomain.cpp -ldl -lGL -lX11 /tmp/glad.a &&
    echo "Generated /tmp/zhutest-gpufps.so" || return -1

    if [[ ! -z $1 ]]; then
        __GL_SYNC_TO_VBLANK=0 vblank_mode=0 LD_PRELOAD=/tmp/zhutest-gpufps.so "$@"
    fi 
}

function zhu-encrypt {
    read -s -p "Base64 Password: " passwd 
    echo -n "$1" | openssl enc -aes-256-cbc -pbkdf2 -iter 10000 -salt -base64 -A -pass "pass:${passwd}" 
}

function zhu-decrypt {
    if [[ ! -e ~/.zhurc.base64passwd ]]; then
        read -s -p "Base64 Password: " passwd 
        echo $passwd > ~/.zhurc.base64passwd
    fi 
    passwd=$(cat ~/.zhurc.base64passwd)
    echo -n "$1" | openssl enc -d -aes-256-cbc -pbkdf2 -iter 10000 -salt -base64 -A -pass "pass:${passwd}" 
}

function zhu-install-nsight-graphics {
    sudo apt install -y cifs-utils || return -1
    sudo mkdir -p /mnt/NomadBuilds
    if ! mountpoint -q /mnt/NomadBuilds; then
        sudo mount -t cifs -o username='wanliz@nvidia.com' //devrel/share/Devtools/NomadBuilds /mnt/NomadBuilds || return -1
    fi 
    file=$(ls /mnt/NomadBuilds/latest/Internal/linux/*.tar.gz)
    version=$(basename -s '-internal.tar.gz' $file)
    version=${version/#NVIDIA_Nsight_Graphics_}
    rsync -ah --progress $file ~/Downloads
    mkdir -p ~/nsight-graphics-internal/$version 
    pushd ~/nsight-graphics-internal/$version >/dev/null 
        tar -zxvf $file 
        mv ./nvidia-nomad-internal-Linux.linux/* .
        rm -rf ./nvidia-nomad-internal-Linux.linux
    popd >/dev/null 
    pushd ~/nsight-graphics-internal >/dev/null 
        ln -sf $version current 
    popd >/dev/null 
}

function zhu-install-nsight-systems {
    if [[ ! -e ~/.zhutest.artifactory.apikey ]]; then
        echo $(zhu-decrypt 'U2FsdGVkX18elI7G2zmszU2FUxbRUHvvE8I+ZRUBdyZVdczSVW59b/Klyq8fgihi2oIXR6P1zDVjptpwVemHV71PgHm6exawmqpqxpS6UuJfBTxiW60s4VR6JJVlWYVt') > ~/.zhutest.artifactory.apikey
    fi  

    if [[ -z $(which curl) ]]; then
        sudo apt install -y curl
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

    if [[ -z $latest_subver ]]; then    
        echo "Failed to find the latest subversion!"
        return -1
    fi
    
    read -e -i yes -p "Upgrade to $latest_subver? " upgrade_nsys 
    if [[ $upgrade_nsys == yes ]]; then
        pushd ~/Downloads >/dev/null
            arch=$(uname -m)
            arch=${arch/aarch64/arm64}
            wget --no-check-certificate --header="X-JFrog-Art-Api: $ARTIFACTORY_API_KEY" https://urm.nvidia.com/artifactory/swdt-nsys-generic/ctk/$latest_version/$latest_subver/nsight_systems-linux-$arch-$latest_subver.tar.gz || return -1
            tar -zxvf nsight_systems-linux-$arch-$latest_subver.tar.gz
            mkdir -p ~/nsight-systems-internal 
            mv nsight_systems ~/nsight-systems-internal/$latest_subver 
            pushd ~/nsight-systems-internal >/dev/null 
                ln -sf $latest_subver current 
            popd >/dev/null 
            sudo apt install -y libxcb-cursor-dev
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

function zhu-find-debug-symbols {
    if ! zhu-is-installed debian-goodies; then
        sudo apt install -y debian-goodies || return -1
    fi

    find /usr/lib -type f -name $1* | tee /tmp/so.list
    while IFS= read -r line; do
        find-dbgsym-packages $(realpath $line)
    done < /tmp/so.list
}

function zhu-install-debug-symbols {
    if [[ $(ulimit -c) == 0 ]]; then
        ulimit -c unlimited
    fi
    sudo apt install -y debian-goodies || return -1
    sudo apt install -y debuginfod || return -1
    sudo apt install -y elfutils || return -1
    if [[ -z "$DEBUGINFOD_URLS" ]]; then
        export DEBUGINFOD_URLS="https://debuginfod.ubuntu.com/"
    fi 
    
    if [[ ! -e /etc/apt/sources.list.d/ddebs.list ]]; then
        mkdir -p /etc/apt/sources.list.d
        sudo tee /etc/apt/sources.list.d/ddebs.list << EOF
deb http://ddebs.ubuntu.com/ $(lsb_release -cs) main restricted universe multiverse
deb http://ddebs.ubuntu.com/ $(lsb_release -cs)-updates main restricted universe multiverse
EOF
        sudo apt install -y ubuntu-dbgsym-keyring || return -1  # Import the debug symbol archive key
        sudo apt update
    fi
    sudo apt install -y linux-image-$(uname -r)-dbgsym || return -1
    sudo apt install -y libc6-dbg || return -1
    sudo apt install -y gdb  || return -1
}

function zhu-install-amd-driver-with-debug-symbols {
    zhu-install-debug-symbols || return -1 # AMD driver is part of Linux kernel
    sudo apt install -y libdrm2-dbgsym libdrm-amdgpu1-dbgsym || return -1 #mesa-dbgsym
    sudo apt install -y mesa-opencl-icd-dbgsym libgl1-mesa-dri-dbgsym libglapi-mesa-dbgsym || return -1  # Install debug symbols for OpenGL/OpenCL
    sudo apt install -y mesa-vulkan-drivers-dbgsym || return -1  # Install debug symbols for Mesa and Vulkan drivers
    sudo apt install -y xserver-xorg-video-amdgpu-dbgsym || return -1 # Install the Xorg AMDGPU display driver
    sudo apt install -y libglx-mesa0-dbgsym || return -1 # Install debug symbols for libGLX_mesa.so
    sudo apt install -y mesa-libgallium-dbgsym || return -1 # Install debug symbols for mesa-libgallium
    #sudo apt install -y mesa-va-drivers-dbgsym mesa-vdpau-drivers-dbgsym  # Install debug symbols for video decode/encode
    
    if [[ ! -e /usr/lib/debug/lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amd/amdgpu/amdgpu.ko && ! -e /usr/lib/debug/lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amd/amdgpu/amdgpu.ko.zst ]]; then
        echo "Debug symbols for the AMDGPU kernel driver are missing: /usr/lib/debug/lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amd/amdgpu/amdgpu.ko"
        return -1
    fi

    echo "Debug symbols for AMD GPU driver are installed!"
}

function zhu-show-cpu-utilization {
    if [[ -z $1 ]]; then
        echo "Usage 1: xxx <PID>"
        echo "Usage 2: xxx <program> [args...]"
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
        sudo apt install -y bc  || return -1
    fi

    file="/tmp/cpu-utilization.log"
    rm -rf $file 
    echo "Recording cpu utilization data to $file every second..."
    pidstat -t -u -p $target --human 1 | tee $file 
}

function zhu-show-gpu-utilization {
    if [[ -z $1 ]]; then
        echo "Manual termination mode is ON"
    else
        target=$1 
    fi

    if [[ -z $(which bc) ]]; then
        sudo apt install -y bc || return -1
    fi

    freq=20  # Can be less than 1
    file="/tmp/nvidia-gpu-utilization.csv"
    rm -rf $file 
    echo "Recording gpu utilization data to $file at ${freq} Hz..."
    nvidia-smi --query-gpu=power.draw,temperature.gpu,utilization.gpu,utilization.memory,clocks.gr,clocks.mem --format=csv -lms $(bc -l <<< "x=1000/$freq; scale=0; x/1") > $file & 
    smipid=$!

    if [[ ! -z $1 ]]; then
        while [[ -d /proc/$target ]]; do 
            sleep 1
        done
    else
        read -p "Press [ENTER] to stop recording: " _
    fi

    kill -SIGINT $smipid 
}

function zhu-disable-nvidia-gpu {
    if [[ $XDG_SESSION_TYPE != tty ]]; then
        echo "Please run via tty session!"
        return -1
    fi

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
    sudo udevadm control --reload-rules
    sudo udevadm trigger --action=add
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
    lscpu -e=cpu,core,maxmhz,mhz,online
}

function zhu-show-xorg {
    ps -ef | grep '[X]org'
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
    if [[ ! -z $(which FEXInterpreter) ]]; then
        return
    fi

    sudo apt update
    sudo apt install -y cmake python3 python3-venv python3-pip \
        libepoxy-dev libstdc++-12-dev libsdl2-dev libssl-dev libglib2.0-dev \
        libpixman-1-dev libslirp-dev debootstrap git nasm \
        ninja-build build-essential clang lld \
        xxhash libxxhash-dev patchelf\
        qtbase5-dev qt5-qmake qml-module-qtquick-controls \
        qml-module-qtquick-controls2 qml-module-qtquick-dialogs \
        qml-module-qtquick-layouts qtdeclarative5-dev qtquickcontrols2-5-dev || return -1
    git clone --recursive https://github.com/FEX-Emu/FEX.git ~/FEX.git || return -1
    #~/FEX.git/Scripts/InstallFEX.py 

    # Has more control over FEX with local build
    mkdir ~/FEX.git/build 
    pushd ~/FEX.git/build >/dev/null 
    cmake -GNinja -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release .. &&
    ninja -j$(nproc) &&
    sudo ninja install &&
    FEXRootFSFetcher &&
    popd >/dev/null 
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

function zhu-install-3dmark-atten-wildlife {
    zhu-validate-display || return -1

    if [[ ! -d ~/zhutest-workload.d/3dmark-attan-wildlife.$(uname -m) ]]; then
        which rsync >/dev/null || sudo apt install -y rsync
        which unzip >/dev/null || sudo apt install -y unzip 
        mkdir -p ~/zhutest-workload.d/3dmark-attan-wildlife.$(uname -m)
        pushd ~/zhutest-workload.d/3dmark-attan-wildlife.$(uname -m) >/dev/null  
        if [[ $(uname -m) == x86_64 ]]; then
            unzip /mnt/linuxqa/nvtest/pynv_files/3DMark/3DMark_Attan_Wild_Life/3dmark-attan-extreme-1.1.2.1-workload-bin.zip || return -1
        elif [[ $(uname -m) == aarch64 ]]; then 
            if ! mountpoint -q /mnt/d3d_benchmarks; then
                sudo apt install -y cifs-utils || return -1
                sudo mkdir -p /mnt/d3d_benchmarks
                sudo mount -t cifs -o username=wanliz,workgroup=NVIDIA.COM //netapp-hq/d3d_benchmarks /mnt/d3d_benchmarks || return -1
            fi 
            unzip /mnt/d3d_benchmarks/3DMark/3dmark-linux-arm64/3dmark-attan-extreme-999.999.197601.547-bin.zip || return -1
        fi 
        sudo apt install -y libc++-dev 
        popd >/dev/null 
    fi
}

function zhu-test-3dmark-atten-wildlife {
    zhu-install-3dmark-atten-wildlife || return -1

    pushd ~/zhutest-workload.d/3dmark-attan-wildlife.$(uname -m) || return -1
        rm -rf result.json
        chmod +x bin/linux/$(zhu-uname-m2)/dev_player
        ./bin/linux/$(zhu-uname-m2)/dev_player --out=result.json --asset_root=assets_desktop --timeline=timelines_heavy/attan_gt1_heavy_timeline.txt || return -1

        which jq >/dev/null || sudo apt install -y jq 
        result=$(jq -r '.outputs[] | select(.outputType == "TYPED_RESULT") | .value' result.json)
        echo "3DMark - Wildlife - Vulkan rasterization"
        echo "Typed result: $result FPS"
    popd >/dev/null 
}

function zhu-install-3dmark-disco-steelnomad {
    zhu-validate-display || return -1

    if [[ ! -d ~/zhutest-workload.d/3dmark-disco-steelnomad.$(uname -m) ]]; then
        which rsync >/dev/null || sudo apt install -y rsync
        which unzip >/dev/null || sudo apt install -y unzip 
        mkdir -p ~/zhutest-workload.d/3dmark-disco-steelnomad.$(uname -m)
        pushd ~/zhutest-workload.d/3dmark-disco-steelnomad.$(uname -m) >/dev/null  
        if [[ $(uname -m) == x86_64 ]]; then
            unzip /mnt/linuxqa/nvtest/pynv_files/3DMark/3DMark_Disco_Steel_Nomad/3dmark-disco-1.0.0-bin.zip || return -1
        elif [[ $(uname -m) == aarch64 ]]; then
            if ! mountpoint -q /mnt/d3d_benchmarks; then
                sudo apt install -y cifs-utils || return -1
                sudo mkdir -p /mnt/d3d_benchmarks
                sudo mount -t cifs -o username=wanliz,workgroup=NVIDIA.COM //netapp-hq/d3d_benchmarks /mnt/d3d_benchmarks || return -1
            fi 
            unzip /mnt/d3d_benchmarks/3DMark/3dmark-linux-arm64/3dmark-disco-999.999.196988.1915-bin.zip || return -1
        fi 
        sudo apt install -y libc++-dev 
        popd >/dev/null 
    fi
}

function zhu-test-3dmark-disco-steelnomad {
    zhu-install-3dmark-disco-steelnomad || return -1

    pushd ~/zhutest-workload.d/3dmark-disco-steelnomad.$(uname -m) || return -1
        rm -rf result_vulkan.json
        chmod +x ./bin/linux/$(zhu-uname-m2)/release_workload
        ./bin/linux/$(zhu-uname-m2)/release_workload --in=settings/gt1_desktop_vulkan.json --out=result_vulkan.json || return -1
        
        which jq >/dev/null || sudo apt install -y jq 
        result=$(jq -r '.outputs[] | select(.outputType == "TYPED_RESULT") | .value' result_vulkan.json)
        echo "3DMark - Steel Nomad - Modern Vulkan rasterization"
        echo "Typed result: $result FPS"
    popd >/dev/null 
}

function zhu-install-3dmark-pogo-solarbay {
    zhu-validate-display || return -1

    if [[ ! -d ~/zhutest-workload.d/3dmark-pogo-solarbay.$(uname -m) ]]; then
        which rsync >/dev/null || sudo apt install -y rsync
        which unzip >/dev/null || sudo apt install -y unzip 
        mkdir -p ~/zhutest-workload.d/3dmark-pogo-solarbay.$(uname -m) 
        pushd ~/zhutest-workload.d/3dmark-pogo-solarbay.$(uname -m) >/dev/null  
        if [[ $(uname -m) == x86_64 ]]; then
            unzip /mnt/linuxqa/nvtest/pynv_files/3DMark/3DMark_Pogo_Solar_Bay/3dmark-pogo-1.0.5.3-bin.zip || return -1 || return -1
        elif [[ $(uname -m) == aarch64 ]]; then 
            if ! mountpoint -q /mnt/d3d_benchmarks; then
                sudo apt install -y cifs-utils || return -1
                sudo mkdir -p /mnt/d3d_benchmarks
                sudo mount -t cifs -o username=wanliz,workgroup=NVIDIA.COM //netapp-hq/d3d_benchmarks /mnt/d3d_benchmarks || return -1
            fi 
            unzip /mnt/d3d_benchmarks/3DMark/3dmark-linux-arm64/3dmark-pogo-1.0.15.2-bin.zip || return -1
        fi 
        sudo apt install -y libc++-dev 
        popd >/dev/null 
    fi
}

function zhu-test-3dmark-pogo-solarbay {
    zhu-install-3dmark-pogo-solarbay || return -1

    pushd ~/zhutest-workload.d/3dmark-pogo-solarbay.$(uname -m) || return -1
        rm -rf result.json
        chmod +x bin/linux/$(zhu-uname-m2)/dev_player
        ./bin/linux/$(zhu-uname-m2)/dev_player --out=result.json --asset_root=assets_desktop --timeline=timelines/pogo_timeline.txt || return -1

        which jq >/dev/null || sudo apt install -y jq 
        result=$(jq -r '.outputs[] | select(.outputType == "TYPED_RESULT" and .resultType == "") | .value' result.json)
        echo "3DMark - Solar Bay - Vulkan raytracing"
        echo "Typed result: $result FPS"
    popd >/dev/null 
}

function zhu-install-vscode {
    if [[ ! -z $(which code) ]]; then
        which code
        echo "vscode has already installed!"
        return -1
    fi

    if [[ ! -e /etc/apt/sources.list.d/vscode.list ]]; then 
        sudo apt-get install wget gpg
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        rm -f /tmp/packages.microsoft.gpg
    fi 

    sudo apt install apt-transport-https  || return -1
    sudo apt update
    sudo apt install code || return -1 # or code-insiders
}

function zhu-rebuild-dpkg-database {
    sudo rm -rf /var/lib/dpkg/*
    sudo rm /usr/share/python3/runtime.d/*.rtupdate
    sudo dpkg --configure -a
    sudo apt --fix-broken install
    sudo apt install --reinstall -y dpkg  
    sudo apt update && sudo apt upgrade -y
}

function zhu-bypass-steam-client-checks {
   # TODO https://gitlab.com/Mr_Goldberg/goldberg_emulator
   echo "https://gitlab.com/Mr_Goldberg/goldberg_emulator"
}

function zhu-install-nvidia-driver-in-fex {
    if [[ -z $(which jq) ]]; then
        sudo apt install -y jq 
    fi 

    pushd . >/dev/null 
    ubuntu=$(jq -r '.Config.RootFS' $HOME/.fex-emu/Config.json)
    rootfs="$HOME/.fex-emu/RootFS/$ubuntu"
    version=$(ls /usr/lib/aarch64-linux-gnu/libnvidia-glcore.so.*  | awk -F '.so.' '{print $2}')

    read -e -i yes -p "Install nvidia *.so.$version into $rootfs? (yes/no): " ans
    if [[ $ans != yes ]]; then
        return -1
    fi  

    cd $(dirname $1) 
    driver=$(realpath $1)
    if [[ -d $(basename $driver) ]]; then
        sudo rm -rf $(basename $driver)
    fi

    chmod +x $driver 
    $driver -x || return -1

    cd ${driver%.run}
    mkdir -p $rootfs/etc/vulkan/icd.d
    cp -vf ./nvidia_icd.json $rootfs/etc/vulkan/icd.d/nvidia_icd.json || return -1

    for dso in *.so.$version; do 
        cp -vf ./$dso $rootfs/lib/x86_64-linux-gnu/$dso 
        pushd $rootfs/lib/x86_64-linux-gnu >/dev/null 
        ln -sf $dso $(echo $dso | cut -d'.' -f1-2).0
        ln -sf $dso $(echo $dso | cut -d'.' -f1-2).1
        ln -sf $dso $(echo $dso | cut -d'.' -f1-2).2
        popd >/dev/null 
    done

    cd 32 
    for dso in *.so.$version; do 
        cp -vf ./$dso $rootfs/lib/i386-linux-gnu/$dso 
        pushd $rootfs/lib/i386-linux-gnu >/dev/null 
        ln -sf $dso $(echo $dso | cut -d'.' -f1-2).0
        ln -sf $dso $(echo $dso | cut -d'.' -f1-2).1
        ln -sf $dso $(echo $dso | cut -d'.' -f1-2).2
        popd >/dev/null 
    done
    popd >/dev/null 
}

function zhu-fix-snap-readonly-filesystem-issue {
    mount | grep snap
    echo
    echo "unmount all snap filesystem from the list above using e.g. 'umount -lf /var/snap/***'" 
}

function zhu-fex-emu {
    which jq >/dev/null || sudo apt install -y jq 
    which patchelf >/dev/null || sudo apt install -y patchelf
    ubuntu=$(jq -r '.Config.RootFS' $HOME/.fex-emu/Config.json)
    rootfs="$HOME/.fex-emu/RootFS/$ubuntu"

    if [[ ! -e $rootfs/zhu-fex-emu-config.sh ]]; then 
        cat <<EOML > $rootfs/zhu-fex-emu-config.sh 
apt update
apt reinstall passwd -y
apt reinstall util-linux -y
apt install vim -y
apt install bsdutils -y
apt install steam -y
EOML
        echo "Generated: $rootfs/zhu-fex-emu-config.sh"
    else
        echo "Existing: $rootfs/zhu-fex-emu-config.sh"
    fi
    chmod +x $rootfs/zhu-fex-emu-config.sh
    
    if [[ ! -e $rootfs/chroot.py ]]; then 
        wget  -O $rootfs/chroot.py https://raw.githubusercontent.com/FEX-Emu/RootFS/refs/heads/main/Scripts/chroot.py 
        chmod +x $rootfs/chroot.py 
    fi 

    if [[ -z $(grep "native arm64 host" $rootfs/usr/lib/systemd/resolv.conf) ]]; then 
        echo "# Inherit nameserver list from native arm64 host" >> $rootfs/usr/lib/systemd/resolv.conf
        cat /etc/resolv.conf >> $rootfs/usr/lib/systemd/resolv.conf
    fi

    if [[ -z $(grep "native arm64 host" $rootfs/chroot/run/systemd/resolve/stub-resolv.conf) ]]; then 
        echo "# Inherit nameserver list from native arm64 host" >> $rootfs/chroot/run/systemd/resolve/stub-resolv.conf
        cat /etc/resolv.conf >> $rootfs/chroot/run/systemd/resolve/stub-resolv.conf
    fi

    if [[ -z $(grep "native arm64 host" $rootfs/etc/apt/sources.list.d/ubuntu.sources) ]]; then
        echo "# Inherit apt sources from native arm64 host" >> $rootfs/etc/apt/sources.list.d/ubuntu.sources
        cat /etc/apt/sources.list.d/ubuntu.sources >> $rootfs/etc/apt/sources.list.d/ubuntu.sources
    fi

    pushd $rootfs || return -1
    ./chroot.py chroot 
    popd 
}

function zhu-apt-remove-arch-i386-and-amd64 {
    for xx in `dpkg --get-selections | grep ":i386" | awk '{print $1}'` ; do 
        sudo dpkg --purge --force-all $xx
    done
    sudo dpkg --remove-architecture i386
    for xx in `dpkg --get-selections | grep ":amd64" | awk '{print $1}'` ; do 
        sudo dpkg --purge --force-all $xx
    done
    sudo dpkg --remove-architecture amd64
}

function zhu-change-linux-kernel {
    if [[ ! -e /etc/default/grub ]]; then
        if [[ $(uname -m) == x86_64 ]]; then
            sudo apt install --reinstall grub-efi grub-efi-amd64 grub-efi-amd64-bin
        elif [[ $(uname -m) == aarch64 ]]; then 
            sudo apt install --reinstall grub-efi grub-efi-arm64 grub-efi-arm64-bin
        fi
        sudo update-grub
    fi

    echo "All installed kernels: "
    cat /boot/grub/grub.cfg | grep "menuentry '" | grep -v "'Ubuntu'" | grep -v "'UEFI Firmware Settings'" | grep -v "recovery mode" | awk -F"'" '{print $2}'
    echo 
    echo "The current kernel:"
    uname -r 
    echo 
    echo "Todo: change GRUB_DEFAULT in /etc/default/grub (e.g. 'Advanced options for Ubuntu>Ubuntu, with xxx')"
    read -p "Press [ENTER] to continue: " _
    sudo vim /etc/default/grub
    sudo update-grub 
    sudo update-initramfs -u
    read -p "Press [ENTER] to reboot: " _
    sudo reboot 
}

function zhu-disable-apparmor {
    if [[ $USER == wanliz ]]; then
        sudo aa-teardown
        sudo systemctl stop apparmor
        sudo systemctl disable apparmor 
        sudo systemctl mask apparmor
        echo; echo "Todo: append 'apparmor=0' to GRUB_CMDLINE_LINUX_DEFAULT"
        read -p "Press [ENTER] to continue: " _
        sudo vim /etc/default/grub 
        sudo update-grub 
        sudo update-initramfs -u
        read -p "Press [ENTER] to reboot: " _
        sudo reboot 
    elif [[ -d /boot/loader/entries ]]; then
        for entryfile in $(ls /boot/loader/entries/*); do 
            if [[ -z $(grep "apparmor=0" $entryfile) ]]; then
                sudo sed -i 's/console=ttyS0/console=ttyS0 apparmor=0/g' $entryfile
            fi
        done 
    fi
}

function zhu-enable-apparmor {
    if [[ $USER == wanliz ]]; then
        sudo systemctl enable apparmor 
        sudo systemctl unmask apparmor
        echo; echo "Todo: remove 'apparmor=0' from GRUB_CMDLINE_LINUX_DEFAULT"
        read -p "Press [ENTER] to continue: " _
        sudo vim /etc/default/grub 
        sudo update-grub 
        sudo update-initramfs -u
        read -p "Press [ENTER] to reboot: " _
        sudo reboot 
    fi 
}

function zhu-check-apparmor {
    cat /sys/module/apparmor/parameters/enabled 
    echo 
    sudo aa-status
}

#function zhu-config-in-fex {
#    uname -m >/dev/null 2>&1
#    if [[ $(uname -m) != "x86_64" ]]; then
#        echo "Run this function in FEX started by chroot!"
#        return -1
#    fi
#    if [[ $UID != 0 ]]; then
#        echo "Must run as root!"
#        return -1
#    fi
#
#    apt install -y sudo
#    apt install -y bsdutils
#    apt install -y dbus-x11
#    apt install -y vim 
#    apt install -y libprotobuf-dev 
#    apt install -y nfs-common 
#
#    apt reinstall -y passwd
#    apt reinstall -y util-linux
#    apt reinstall -y mount
#    apt reinstall -y bubblewrap
#
#    if [[ ! -d /home/wanliz ]]; then 
#        echo "Add new user: wanliz in FEX"
#        adduser wanliz
#    fi 
#}

#function zhu-sudo-in-fex {
#    if [[ -z $(which jq) ]]; then
#        sudo apt install -y jq || return -1
#    fi 
#
#    ubuntu=$(jq -r '.Config.RootFS' $HOME/.fex-emu/Config.json)
#    rootfs="$HOME/.fex-emu/RootFS/$ubuntu"
#
#    if [[ -z $1 ]]; then
#        read -p "chroot to $rootfs? (yes/no): " ans
#        if [[ $ans == yes ]]; then
#            zhu-chroot-in-fex
#        fi
#    else
#        program=$1
#        shift  
#        if [[ ! -z $program && -e $rootfs$program ]]; then
#            program=$rootfs$program
#        elif [[ ! -z $program && ! "$program" =~ "/" ]]; then
#            program=$(find $rootfs/usr/bin -type f -executable -name $program)
#        else
#            program=''
#        fi
#
#        if [[ -e $program ]]; then
#            echo "FEX_ROOTFS=$rootfs FEXInterpreter $program $@"
#            read -p "Press [ENTER] to continue: " _
#            sudo FEX_ROOTFS=$rootfs FEXInterpreter $program "$@"
#        else
#            echo "$program doesn't exist in $rootfs"
#            return -1
#        fi
#    fi
#}

#function zhu-fetch-packages-in-fex {
#    [[ -z $(which jq) ]] && sudo apt install -y jq 
#    rootfs="~/.fex-emu/$(jq -r '.Config.RootFS' ~/.fex-emu/Config.json)"
#
#    if [[ ! -e ~/.zhurc.data.server ]]; then
#        read -p "Data server IP: " ip
#        read -e -i wanliz -p "Data server username: " user
#        read -s -p "Data server password: " passwd
#        echo "$user@$ip $passwd" > ~/.zhurc.data.server
#    fi
#
#    remote=$(cat ~/.zhurc.data.server | awk '{print $1}')
#    passwd=$(cat ~/.zhurc.data.server | awk '{print $2}')
#
#    sshpass -p "$passwd" ssh $remote "dpkg -L $1" >/tmp/dpkg.log || return -1
#    count=0
#    while IFS= read -r line; do
#        if [[ ! -d $line ]]; then
#            echo "$line"
#            $((count++))
#        fi 
#    done < /tmp/dpkg.log
#    read -e -i yes -p "Fetch these $count files into $rootfs? (yes/no): " ans
#    if [[ $ans != yes ]]; then
#        return -1
#    fi 
#
#    while IFS= read -r line; do
#        if [[ ! -d $line ]]; then
#            sshpass -p "$passwd" rsync -ah --progress $remote:$line $rootfs$line 
#        fi 
#    done < /tmp/dpkg.log 
#}

function zhu-install-unigine-heaven {
    zhu-validate-display || return -1

    if [[ ! -e ~/zhutest-workload.d/unigine-heaven-1.6.5 ]]; then
        phoronix-test-suite install pts/unigine-heaven-1.6.5 
        pushd ~/.phoronix-test-suite/installed-tests/pts/unigine-heaven-1.6.5 >/dev/null && {
            mkdir -p ~/zhutest-workload.d/unigine-heaven-1.6.5
            rsync -ah --progress ./Unigine_Heaven-4.0/ ~/zhutest-workload.d/unigine-heaven-1.6.5 || return -1
            popd >/dev/null
        } || {
            read -p "Rsync workload from host: " host
            read -e -i wanliz -p "username: " user
            rsync -ah --progress $user@$host:/home/$user/zhutest-workload.d/unigine-heaven-1.6.5/ ~/zhutest-workload.d/unigine-heaven-1.6.5/ || return -1
        }
    fi

    if [[ $(uname -m) == "aarch64" ]]; then
        zhu-install-fex || return -1
    fi
}

function zhu-test-unigine-heaven {
    zhu-install-unigine-heaven || return -1

    pushd ~/zhutest-workload.d/unigine-heaven-1.6.5 >/dev/null 
    LD_LIBRARY_PATH=bin/:bin/x64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH} ./bin/heaven_x64 -data_path ../ -sound_app null -engine_config ../data/heaven_4.0.cfg -system_script heaven/unigine.cpp -video_mode -1 -extern_define PHORONIX,RELEASE -video_width 1920 -video_height 1080 -video_fullscreen 1 -video_app opengl > /tmp/unigine-heaven.log  || return -1
    cat /tmp/unigine-heaven.log | grep "FPS:"
    popd >/dev/null 
}

function zhu-install-unigine-valley {
    zhu-validate-display || return -1

    if [[ ! -e ~/zhutest-workload.d/unigine-valley-1.1.8 ]]; then
        phoronix-test-suite install pts/unigine-valley-1.1.8
        pushd ~/.phoronix-test-suite/installed-tests/pts/unigine-valley-1.1.8 >/dev/null && { 
            mkdir -p ~/zhutest-workload.d/unigine-valley-1.1.8
            rsync -ah --progress ./Unigine_Valley-1.0/ ~/zhutest-workload.d/unigine-valley-1.1.8 || return -1
            popd >/dev/null
        } || {
            read -p "Rsync workload from host: " host
            read -e -i wanliz -p "username: " user
            rsync -ah --progress $user@$host:/home/$user/zhutest-workload.d/unigine-valley-1.1.8/ ~/zhutest-workload.d/unigine-valley-1.1.8/ || return -1
        }
    fi 

    if [[ $(uname -m) == "aarch64" ]]; then
        zhu-install-fex || return -1
    fi
}

function zhu-test-unigine-valley {
    zhu-install-unigine-valley || return -1

    pushd ~/zhutest-workload.d/unigine-valley-1.1.8  >/dev/null 
    LD_LIBRARY_PATH=bin/:bin/x64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH} ./bin/valley_x64 -data_path ../ -sound_app null -engine_config ../data/valley_1.0.cfg -system_script valley/unigine.cpp -video_mode -1 -extern_define PHORONIX,RELEASE -video_width 1920 -video_height 1080 -video_fullscreen 1 -video_app opengl > /tmp/unigine-valley.log 
    cat /tmp/unigine-valley.log | grep "FPS:"  || return -1
    popd >/dev/null 
}

function zhu-install-unigine-superposition {
    zhu-validate-display || return -1

    if [[ ! -e ~/zhutest-workload.d/unigine-super-1.0.7 ]]; then
        phoronix-test-suite install pts/unigine-super-1.0.7 
        pushd ~/.phoronix-test-suite/installed-tests/pts/unigine-super-1.0.7 >/dev/null && { 
            mkdir -p ~/zhutest-workload.d/unigine-super-1.0.7
            rsync -ah --progress ./Unigine_Superposition-1.0/ ~/zhutest-workload.d/unigine-super-1.0.7 || return -1
            popd >/dev/null
        } || {
            read -p "Rsync workload from host: " host
            read -e -i wanliz -p "username: " user
            rsync -ah --progress $user@$host:/home/$user/zhutest-workload.d/unigine-super-1.0.7/ ~/zhutest-workload.d/unigine-super-1.0.7/ || return -1
        }
    fi 

    if [[ $(uname -m) == "aarch64" ]]; then
        zhu-install-fex || return -1
    fi
}

function zhu-test-unigine-superposition {
    zhu-install-unigine-superposition || return -1

    rm -rf ~/.Superposition/automation/log*.txt 
    pushd ~/zhutest-workload.d/unigine-super-1.0.7  >/dev/null 
    ./bin/superposition -sound_app openal  -system_script superposition/system_script.cpp  -data_path ../ -engine_config ../data/superposition/unigine.cfg  -video_mode -1 -project_name Superposition  -video_resizable 1  -console_command "config_readonly 1 && world_load superposition/superposition" -mode 2 -preset 0 -video_width 1920 -video_height 1080 -video_fullscreen 1 -shaders_quality 2 -textures_quality 2 -video_app opengl 
    popd >/dev/null 
    cat ~/.Superposition/automation/log*.txt 
}

function zhu-install-viewperf {
    if [[ ! -e ~/zhutest-workload.d/viewperf2020.$(uname -m)/viewperf/bin/viewperf ]]; then
        if [[ $(uname -m) == "x86_64" ]]; then
            mkdir -p ~/zhutest-workload.d
            cd ~/zhutest-workload.d
            tar -zxvf /mnt/linuxqa/nvtest/pynv_files/viewperf2020v3/viewperf2020v3.tar.gz
            mv viewperf2020 viewperf2020.x86_64
        elif [[ $(uname -m) == "aarch64" ]]; then
            mkdir -p ~/zhutest-workload.d/viewperf2020.aarch64
            cd ~/zhutest-workload.d/viewperf2020.aarch64
            tar -zxvf /mnt/linuxqa/nvtest/pynv_files/viewperf2020v3/viewperf2020v3-aarch64-rev2.tar.gz
        fi

        sudo apt install -y libxml2 libxml2-utils
    fi
}

function zhu-test-viewperf {
    echo "" > /tmp/viewperf.scores
    zhu-test-viewperf-catia "$@"
    zhu-test-viewperf-creo "$@"
    zhu-test-viewperf-energy "$@" 
    zhu-test-viewperf-maya "$@" 
    zhu-test-viewperf-medical "$@" 
    zhu-test-viewperf-snx "$@" 
    zhu-test-viewperf-sw "$@" 
    cat /tmp/viewperf.scores
}

function zhu-test-viewperf-catia {
    zhu-validate-display || return -1
    zhu-install-viewperf || return -1 

    pushd ~/zhutest-workload.d/viewperf2020.$(uname -m) || return -1
    mkdir -p results/catia-06 
    rm -rf results/catia-06/results.xml

    ./viewperf/bin/viewperf viewsets/catia/config/catia.xml -resolution 1920x1080 && {
        cat results/catia-06/results.xml
        fps=$(cat results/catia-06/results.xml | grep "Composite Score" | awk -F'"' '{print $2}')
        echo "FPS of catia-06: $fps" | tee -a /tmp/viewperf.scores
    } || echo "Failed to run viewsets/catia"
    popd >/dev/null 
}

function zhu-test-viewperf-creo {
    zhu-validate-display || return -1
    zhu-install-viewperf || return -1 

    pushd ~/zhutest-workload.d/viewperf2020.$(uname -m) || return -1
    mkdir -p results/creo-03 
    rm -rf results/creo-03/results.xml

    ./viewperf/bin/viewperf viewsets/creo/config/creo.xml -resolution 1920x1080 && {
        cat results/creo-03/results.xml
        fps=$(cat results/creo-03/results.xml | grep "Composite Score" | awk -F'"' '{print $2}')
        echo "FPS of creo-03: $fps" | tee -a /tmp/viewperf.scores
    } || echo "Failed to run viewsets/creo"

    popd >/dev/null 
}

function zhu-test-viewperf-energy {
    zhu-validate-display || return -1
    zhu-install-viewperf || return -1 

    pushd ~/zhutest-workload.d/viewperf2020.$(uname -m) || return -1
    mkdir -p results/energy-03 
    rm -rf results/energy-03/results.xml

    ./viewperf/bin/viewperf viewsets/energy/config/energy.xml -resolution 1920x1080 && {
        cat results/energy-03/results.xml
        fps=$(cat results/energy-03/results.xml | grep "Composite Score" | awk -F'"' '{print $2}')
        echo "FPS of energy-03: $fps" | tee -a /tmp/viewperf.scores
    } || echo "Failed to run viewsets/energy"
    popd >/dev/null 
}

function zhu-test-viewperf-maya {
    zhu-validate-display || return -1
    zhu-install-viewperf || return -1 

    pushd ~/zhutest-workload.d/viewperf2020.$(uname -m) || return -1
    mkdir -p results/maya-06 
    rm -rf results/maya-06/results.xml
    
    ./viewperf/bin/viewperf viewsets/maya/config/maya.xml -resolution 1920x1080 && {
        cat results/maya-06/results.xml
        fps=$(cat results/maya-06/results.xml | grep "Composite Score" | awk -F'"' '{print $2}')
        echo "FPS of maya-06: $fps" | tee -a /tmp/viewperf.scores
    } || echo "Failed to run viewsets/maya"
    popd >/dev/null 
}

function zhu-test-viewperf-medical {
    zhu-validate-display || return -1
    zhu-install-viewperf || return -1 

    pushd ~/zhutest-workload.d/viewperf2020.$(uname -m) || return -1
    mkdir -p results/medical-03 
    rm -rf results/medical-03/results.xml

    ./viewperf/bin/viewperf viewsets/medical/config/medical.xml -resolution 1920x1080 && {
        cat results/medical-03/results.xml
        fps=$(cat results/medical-03/results.xml | grep "Composite Score" | awk -F'"' '{print $2}')
        echo "FPS of medical-03: $fps" | tee -a /tmp/viewperf.scores
    } || echo "Failed to run viewsets/medical"
    popd >/dev/null 
}

function zhu-test-viewperf-snx {
    zhu-validate-display || return -1
    zhu-install-viewperf || return -1 

    pushd ~/zhutest-workload.d/viewperf2020.$(uname -m) || return -1
    mkdir -p results/snx-04 
    rm -rf results/snx-04/results.xml

    ./viewperf/bin/viewperf viewsets/snx/config/snx.xml -resolution 1920x1080 && {
        cat results/snx-04/results.xml
        fps=$(cat results/snx-04/results.xml | grep "Composite Score" | awk -F'"' '{print $2}')
        echo "FPS of snx-04: $fps" | tee -a /tmp/viewperf.scores
    } || echo "Failed to run viewsets/snx"
    popd >/dev/null 
}

function zhu-test-viewperf-sw {
    zhu-validate-display || return -1
    zhu-install-viewperf || return -1 

    pushd ~/zhutest-workload.d/viewperf2020.$(uname -m) || return -1
    mkdir -p results/solidworks-07
    rm -rf results/solidworks-07/results.xml

    ./viewperf/bin/viewperf viewsets/sw/config/sw.xml -resolution 1920x1080 && {
        cat results/solidworks-07/results.xml
        fps=$(cat results/solidworks-04/results.xml | grep "Composite Score" | awk -F'"' '{print $2}')
        echo "FPS of solidworks-04: $fps" | tee -a /tmp/viewperf.scores
    } || echo "Failed to run viewsets/sw"
    popd >/dev/null 
}

function zhu-test-viewperf-in-gui {
    zhu-validate-display || return -1
    zhu-install-viewperf || return -1 

    # Start all viewsets in viewperf GUI
    ~/zhutest-workload.d/viewperf2020.$(uname -m)/RunViewperf 

    #zhu-cursor-click-on-window "SPECviewperf 2020 v3.0" 441 550
    #window_id=$(cat /tmp/zhu-activate-window)

    # Wait all viewsets to complete
    #while [[ ! -z $(pidof viewperf) ]]; do
    #    sleep 5
    #done 

    # Close the configuration window
    #xdotool mousemove --window $window_id 620 21 click 1

    # Find the result directory 
    #result_dir=$(find ~/Documents/SPECresults/SPECviewperf2020 -mindepth 1 -maxdepth 1 -type d -printf "%T@ %p\n" | sort -n | tail -n 1 | awk '{print $2}')
    #sed -i '1s/^.*$/Compositor,FPS/' "$result_dir/resultCSV.csv"
    #mapfile -d '' csv_parts < <(awk 'BEGIN {RS="(\n\n|\n[[:space:]]*\n)"; ORS="\0"} {print}' "$result_dir/resultCSV.csv")
    #for i in "${!csv_parts[@]}"; do 
    #    echo "${csv_parts[i]}" | column -s, -t
    #    echo 
    #done
}

function zhu-test-viewperf-catia-subtest1 {
    zhu-validate-display || return -1
    zhu-install-viewperf || return -1 

    pushd ~/zhutest-workload.d/viewperf2020.$(uname -m) || return -1
    mkdir -p results/catia-06

    if [[ ! -e viewsets/catia/config/subtest1.xml ]]; then
        cat <<EOF > viewsets/catia/config/subtest1.xml
<?xml version="1.0" standalone="yes"?>
<!DOCTYPE SPECGWPG>
<SPECGWPG Name="SPECviewperf" Version="v2.0" AppName="Dassault Syst&#xE8;mes CATIA V5 and 3DExperience" Results="results.xml" Log="log.txt">
    <Viewset Name="catia-06" Library="catia" Directory="catia" Threads="-1" Options="" Version="2.0">
        <Window Resolution="3840x2160" Height="2120" Width="3800" X="10" Y="20" Suffix="-4k"/>
        <Window Resolution="1920x1080" Height="1060" Width="1900" X="10" Y="20"/>
        <Test Name="catiav5test1" Index="1" Weight="14.28" Seconds="15.0" Description='Catia V5 loft jet - shaded with edges'>
            <Grab Name="CATIA_V5_loft_jet1.png" Frames="1" X="0" Y="0"/>
        </Test>
    </Viewset>
</SPECGWPG>
EOF
    fi

    ./viewperf/bin/viewperf viewsets/catia/config/subtest1.xml -resolution 1920x1080 && {
        cat results/catia-06/results.xml | grep FPS | xmllint --xpath 'string(//Test/@FPS)' - >> /tmp/fps.log 
        echo "Viewperf Catia-06:subtest1 result FPS: $(cat /tmp/fps.log | tail -1)"
    }

    popd >/dev/null
}

function zhu-test-viewperf-maya-subtest5 {
    zhu-validate-display || return -1
    zhu-install-viewperf || return -1 

    pushd ~/zhutest-workload.d/viewperf2020.$(uname -m) || return -1
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
        echo "Viewperf Maya-06:subtest5 result FPS: $(cat /tmp/fps.log | tail -1)"
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

function zhu-check-xauthority {
    if [[ -z $(pidof Xorg) ]]; then
        echo "Xorg is not running"
        return -1
    fi

    if [[ -z $(which glxgears) ]]; then
        sudo apt install -y mesa-utils || return -1
    fi

    if [[ -n $XDG_SESSION_TYPE && $XDG_SESSION_TYPE != tty && $XDG_SESSION_TYPE != x11 ]]; then
        echo "XDG_SESSION_TYPE is \"$XDG_SESSION_TYPE\" which is not supported!"
        return -1
    fi

    echo "Checking Xauthority..."
    
    echo "XDG_SESSION_TYPE is $([[ -z $XDG_SESSION_TYPE ]] && echo null || echo $XDG_SESSION_TYPE)"
    if [[ $DISPLAY == *"localhost"* ]]; then
        echo "X11 forwarding is enabled"
        export XAUTHORITY=~/.Xauthority
        chmod 600 ~/.Xauthority
        echo "Export XAUTHORITY=~/.Xauthority"
        return 
    fi 

    active_auth=$(ps aux | grep '[X]org' | grep -oP '(?<=-auth )[^ ]+')

    if [[ -z $active_auth ]]; then
        rm -rf ~/.Xauthority
        export XAUTHORITY=""
        echo "Delete ~/.Xauthority and reset"
    else
        sudo cp $active_auth ~/.Xauthority
        sudo chown $USER:$(id -gn) ~/.Xauthority
        chmod 600 ~/.Xauthority
        export XAUTHORITY=$HOME/.Xauthority
        echo "Copy $active_auth to ~/.Xauthority and export"
    fi 

    glxgears & 
    sleep 1
    success=no
    if [[ -z $(pidof glxgears) ]]; then
        echo "XAUTHORITY(\"$XAUTHORITY\") is invalid!"
        if [[ $this_is_retry == yes ]]; then
            return -1
        else
            this_is_retry=yes 
            echo "Delete ~/.Xauthority and retry"
            rm -rf ~/.Xauthority
            zhu-check-xauthority
            this_is_retry=
            return 
        fi
    else
        success=yes
    fi

    kill -INT $(pidof glxgears)
    if [[ $success == yes ]]; then 
        if [[ $this_is_retry != yes ]]; then 
            echo "XAUTHORITY is $XAUTHORITY"
            echo "Xauthority verification succeeded!"
        fi 
    else
        echo "XAUTHORITY is $XAUTHORITY"
        echo "Xauthority verification failed!"
    fi 
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

    sudo apt install -y xorg openbox || return -1
    if [[ -z $(which screen) ]]; then
        sudo apt install -y screen  || return -1
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

#function zhu-vnc-server-for-headless-system-as-autostart {
#    zhu-vnc-server-for-headless-system --dont-start || return -1
#    if [[ -z "$vncserver_args" ]]; then
#        return -1
#    fi
#
#    echo "[Unit]
#Description=TigerVNC server
#After=syslog.target network.target
#
#[Service]
#Type=forking
#User=$USER
#WorkingDirectory=$HOME
#ExecStartPre=-/usr/bin/tigervncserver -kill :%i > /dev/null 2>&1
#ExecStart=/usr/bin/tigervncserver $vncserver_args :%i
#ExecStop=/usr/bin/tigervncserver -kill :%i
#
#[Install]
#WantedBy=multi-user.target
#" > /etc/systemd/system/tigervncserver@.service
#    sudo systemctl daemon-reload
#    sudo systemctl enable tigervncserver@${DISPLAY/:/}.service
#    sudo systemctl start tigervncserver@${DISPLAY/:/}.service
#}

function zhu-vnc-server-for-headless-system {
    if [[ -z $DISPLAY ]]; then
        echo "DISPLAY is null!"
        return -1
    fi

    if [[ ! -z $(zhu-check-vncserver) ]]; then
        zhu-check-vncserver
        echo "A valid VNC server is already running..."
        read -p "Press [ENTER] to continue: " _
    fi  

    if [[ -z $(which screen) ]]; then
        sudo apt install -y screen || return -1
    fi

    if [[ -z $(which tigervncserver) ]]; then
        sudo apt install -y tigervnc-standalone-server || return -1
        sudo apt install -y tigervnc-common || return -1
    fi 

    desktop_session=/usr/bin/xfce4-session
    sudo apt install -y xfce4-session || return -1

    if [[ ! -f ~/.vnc/passwd ]]; then 
        mkdir -p ~/.vnc
        tigervncpasswd
    fi 
    
    echo "#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec $desktop_session
" > ~/.vnc/xstartup
    chmod +x ~/.vnc/xstartup

    vncserver_args="-localhost no $DISPLAY -geometry 1920x1080 -depth 16 +iglx"

    /usr/bin/tigervncserver -kill $DISPLAY >/dev/null 2>&1
    screen -dmS tigervnc bash -c "/usr/bin/tigervncserver $vncserver_args $DISPLAY 2>&1 | tee /tmp/tigervnc.log"
    sleep 1
    /usr/bin/tigervncserver -list 
}

#function zhu-vnc-server-for-physical-display-as-autostart {
#    zhu-vnc-server-for-physical-display --dont-start || return -1
#    if [[ -z "$x11vnc_args" ]]; then
#        return -1
#    fi
#
#    echo "[Unit]
#Description=x11vnc service
#After=display-manager.service
#
#[Service]
#ExecStart=/usr/bin/x11vnc $x11vnc_args 
#User=$USER
#Restart=on-failure
#RestartSec=2
#
#[Install]
#WantedBy=multi-user.target
#" | sudo tee /etc/systemd/system/x11vnc.service
#    sudo systemctl enable x11vnc.service 
#    sudo systemctl start x11vnc.service 
#    echo "x11vnc.service is running and scheduled as auto-start!"
#}

function zhu-grub-default-saved {
    echo "Todo: add or edit: GRUB_DEFAULT=saved"
    echo "Todo: add or edit: GRUB_SAVEDEFAULT=true"
    read -p "Press [ENTER] to continue: " _
    sudo vim /etc/default/grub
    sudo update-grub
}

function zhu-vnc-server-for-physical-display {
    if [[ -z $DISPLAY ]]; then
        echo "DISPLAY is null!"
        return -1
    fi

    if [[ ! -z $(zhu-check-vncserver) ]]; then
        zhu-check-vncserver
        echo "A valid VNC server is already running..."
        read -p "Press [ENTER] to continue: " _
    fi  

    if [[ -z $(pidof Xorg) && "$1" != "--dont-start" ]]; then
        echo "Xorg is not running!"
        return -1
    fi

    if [[ -z $(dpkg -l | grep x11vnc) ]]; then
        sudo apt install -y x11vnc || return -1
    fi 

    zhu-check-xauthority || return -1
    if [[ -z $XAUTHORITY ]]; then
        auth_args="" 
        auth_path=$(ps aux | grep '[X]org' | grep -oP '(?<=-auth )[^ ]+')
        if [[ ! -z $auth_path ]]; then
            auth_args="-auth $auth_path"
            echo "Pass Xorg's -auth($auth_path) to -auth of x11vnc"
        else
            echo "Remove -auth of x11vnc"
        fi 
    else
        auth_args="-auth $XAUTHORITY"
        echo "Pass XAUTHORITY($XAUTHORITY) to -auth of x11vnc"
    fi

    if [[ ! -e $HOME/.vnc/passwd ]]; then
        x11vnc -storepasswd
    fi 

    x11vnc_args="$auth_args -forever --loop -noxdamage -repeat -rfbauth $HOME/.vnc/passwd -rfbport 5900 -display :0 -shared"
    xorg_user=$(ps -o user -p $(pidof Xorg) | tail -1)
    if [[ $xorg_user == root ]]; then
        SUDO="sudo"
    else
        SUDO=""
    fi

    if [[ $1 == "--debug" ]]; then
        /usr/bin/x11vnc $x11vnc_args
    else
        $SUDO screen -dmS x11vnc bash -c "/usr/bin/x11vnc $x11vnc_args 2>&1 | tee /tmp/x11vnc.log"
        sleep 1
        dimension=$(xrandr | grep current | awk '{print $8 "x" $10}')
        if [[ $dimension == "640x480" ]]; then
            echo " - 1920x1080 (default)"
            echo " - 2560x1440"
            echo " - 3840x2160"
            read -e -i "1920x1080" -p "Resize framebuffer: " fbsize
            xrandr --fb $fbsize
        fi
    fi 
}

function zhu-vnc-server {
    if [[ -z $DISPLAY ]]; then
        read -e -i yes -p "Set DISPLAY to :0? (yes/no): " ans
        if [[ $ans == yes ]]; then
            export DISPLAY=:0
        fi
    fi

    echo "[1] Tiger VNC (virtual desktop for headless system, rendering in llvmpipe, not using GPU, not running Xorg)"
    echo "[2] X11 VNC (mirrors physical display)"
    read -p "Which VNC server to start? : " selection

    if [[ $selection == 1 ]]; then
        zhu-vnc-server-for-headless-system
    elif [[ $selection == 2 ]]; then
        zhu-vnc-server-for-physical-display
    fi
}

function zhu-enable-x11-forwarding {
    if sudo grep -Eq "^X11Forwarding\s+yes" /etc/ssh/sshd_config; then
        if sudo grep -Eq "^ForwardX11\s+yes" /etc/ssh/sshd_config; then
            if sudo grep -Eq "^ForwardX11Trusted\s+yes" /etc/ssh/sshd_config; then
                echo "X11 forwarding is already enabled!"
                return
            fi 
        fi 
    fi

    if ! dpkg -l | grep -q xauth; then
        sudo apt install -y xauth || return -1
    fi

    sudo sed -i '/^#*X11Forwarding[[:space:]]/cX11Forwarding yes' /etc/ssh/sshd_config
    sudo sed -i '/^#*ForwardX11[[:space:]]/cForwardX11 yes' /etc/ssh/sshd_config
    sudo sed -i '/^#*ForwardX11Trusted[[:space:]]/cForwardX11Trusted yes' /etc/ssh/sshd_config
    sudo systemctl restart ssh
    echo "X11 forwarding enabled!"
}

function zhu-share-folder-via-nfs {
    if [[ ! -d "$1" ]]; then
        echo "Folder $1 doesn't exist!"
        return -1
    fi

    if [[ -z $(dpkg -l | grep "^ii  openbox ") ]]; then
        sudo apt install -y nfs-kernel-server || return -1
    fi

    if [[ -e /etc/exports ]]; then 
        if sudo grep -q "$1" /etc/exports; then
            echo "Found \"$1\" in /etc/exports"
            echo "Aborting!"
            return 
        else
            echo "$1 *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
        fi
    else
        echo "$1 *(rw,sync,no_subtree_check)" | sudo tee /etc/exports
    fi

    sudo cat /etc/exportfs
    read -p "Press [ENTER] to continue: " _

    sudo exportfs -a
    sudo systemctl restart nfs-kernel-server
    sudo systemctl enable nfs-kernel-server 
    sudo exportfs -v
}

function zhu-install-gtlfs {
    if [[ -z $(which gtlfs) ]]; then
        if [[ $(uname -s) == Linux ]]; then
            if [[ $(uname -m) == x86_64 ]]; then 
                sudo wget --no-check-certificate -O /usr/local/bin/gtlfs https://gtlfs.nvidia.com/client/linux
            elif [[ $(uname -m) == aarch64 ]]; then
                sudo wget --no-check-certificate -O /usr/local/bin/gtlfs https://gtlfs.nvidia.com/client/gtlfs.arm64
            fi  
            sudo chown $USER:$(id -gn) /usr/local/bin/gtlfs
            chmod +x /usr/local/bin/gtlfs
        else
            return -1
        fi
    fi
}

function zhu-gtlfs-upload {
    zhu-install-gtlfs || return -1
    gtlfs push --username=wanliz "$1"
}

function zhu-gtlfs-download {
    install-gtlfs || return -1
    pushd ~/Downloads >/dev/null 
    gtlfs pull "$1"
    popd >/dev/null 
}

function zhu-vulkan-api-capture {
    if [[ ! -e ~/gfxreconstruct.git/build/linux/x64/output/bin/gfxrecon-capture-vulkan.py ]]; then
        if [[ ! -d ~/gfxreconstruct.git ]]; then
            git clone --recursive https://github.com/LunarG/gfxreconstruct.git ~/gfxreconstruct.git 
        fi

        sudo apt install -y git cmake build-essential libx11-xcb-dev \
            libxcb-keysyms1-dev libwayland-dev libxrandr-dev \
            zlib1g-dev liblz4-dev libzstd-dev || return -1
        sudo apt install -y g++-multilib libx11-xcb-dev:i386 \
            libxcb-keysyms1-dev:i386 libwayland-dev:i386 libxrandr-dev:i386 \
            zlib1g-dev:i386 liblz4-dev:i386 libzstd-dev:i386 || return -1
        if [[ $(uname -m) == aarch64 ]]; then
            sudo apt install -y g++-aarch64-linux-gnu || return -1
            arch=arm64
        else
            arch=x64
        fi

        pushd . >/dev/null 
        cd ~/gfxreconstruct.git || return -1
        git submodule update --init
        python3 scripts/build.py --arch $arch --config release --parallel $(nproc) --skip-check-code-style --skip-tests --skip-d3d12-support 
        echo "gfxreconstruct is compiled!"
        popd >/dev/null
    fi 

    if [[ $(uname -m) == aarch64 ]]; then
        arch=arm64
    else
        arch=x64
    fi

    echo "Output directory is $HOME/Documents/"
    mkdir -p $HOME/Documents 

    read -p "Output name: " name
    read -e -i yes -p "Is capture triggered by hotkey (F10)? (yes/no): " hotkey
    if [[ $hotkey == yes ]]; then
        read -e -i 100 -p "Number of frames to capture via hotkey: " num_frames 
    else
        read -e -i '500-600' -p "Index of frames to capture: " idx_frames
    fi
    read -e -i yes -p "Log messages to file? (yes/no): " logfile

    cmdline="VK_INSTANCE_LAYERS=VK_LAYER_LUNARG_gfxreconstruct${VK_INSTANCE_LAYERS:+:$VK_INSTANCE_LAYERS} VK_LAYER_PATH=$HOME/gfxreconstruct.git/build/linux/$arch/output/share/vulkan/explicit_layer.d${VK_LAYER_PATH:+:$VK_LAYER_PATH}"
    cmdline="$cmdline LD_LIBRARY_PATH=$HOME/gfxreconstruct.git/build/linux/$arch/output/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    cmdline="$cmdline GFXRECON_CAPTURE_FILE=$HOME/Documents/$name.gfxr"
    cmdline="$cmdline GFXRECON_CAPTURE_FILE_TIMESTAMP=false"
    if [[ $hotkey == yes ]]; then
        cmdline="$cmdline GFXRECON_CAPTURE_TRIGGER=F10"
        cmdline="$cmdline GFXRECON_CAPTURE_TRIGGER_FRAMES=$num_frames"
    else
        cmdline="$cmdline GFXRECON_CAPTURE_FRAMES=$idx_frames"
    fi 
    if [[ $logfile == yes ]]; then
        cmdline="$cmdline GFXRECON_LOG_DETAILED=true"
        cmdline="$cmdline GFXRECON_LOG_ALLOW_INDENTS=true"
        cmdline="$cmdline GFXRECON_LOG_FILE=$HOME/Documents/$name.gfxr.log.txt"
    fi
    
    echo 
    echo "$cmdline"
}

function zhu-install-quake2rtx {
    if [[ ! -d ~/zhutest-workload.d/quake2rtx-1.6.0.$(uname -m) ]]; then
        pushd ~/Downloads >/dev/null 
        if [[ $(uname -m) == "x86_64" ]]; then
            tar -zxvf /mnt/linuxqa/nvtest/pynv_files/q2rtx/builds/1.6.0-701cf31/q2rtx-1.6.0.tar.gz 
            mkdir -p ~/zhutest-workload.d
            mv q2rtx ~/zhutest-workload.d/quake2rtx-1.6.0.x86_64
        elif [[ $(uname -m) == "aarch64" ]]; then
            tar -zxvf /mnt/linuxqa/nvtest/pynv_files/q2rtx/builds/1.6.0-701cf31/q2rtx-1.6.0-aarch64.tar.gz 
            mkdir -p ~/zhutest-workload.d
            mv q2rtx ~/zhutest-workload.d/quake2rtx-1.6.0.aarch64
        fi
        popd >/dev/null 
    fi
}

function zhu-test-quake2rtx {
    zhu-install-quake2rtx || return -1
    rm -rf ~/.quake2rtx
    pushd ~/zhutest-workload.d/quake2rtx-1.6.0.$(uname -m) || return -1
    echo "Enter \"demo q2demo1\" in the in-game console" 
    chmod +x q2rtx.sh
    ./q2rtx.sh
    popd >/dev/null 
}

function zhu-install-shadow-of-the-tomb-raider {
    zhu-mount-linuxqa || return -1

    if [[ ! -d $HOME/zhutest-workload.d/nvtest-sottr ]]; then
        read -p "Rsync workload from host: " host
        read -e -i wanliz -p "As user: " user
        rsync -ah --progress $user@$host:/home/$user/zhutest-workload.d/nvtest-sottr/ $HOME/zhutest-workload.d/nvtest-sottr/ || return -1
    fi
}

function zhu-nvtest-shadow-of-the-tomb-raider {
    zhu-install-shadow-of-the-tomb-raider || return -1

    pushd . >/dev/null 
    rm -rf /tmp/nvtest-sottr.log; \
    cd $HOME/zhutest-workload.d/nvtest-sottr/dxvk/run_dir; \
    DISPLAY=:0.0 \
    DXVK_ENABLE_NVAPI=1 \
    DXVK_HUD=full \
    DXVK_LOG_LEVEL=none \
    DXVK_STATE_CACHE=0 \
    LD_LIBRARY_PATH=$HOME/zhutest-workload.d/nvtest-sottr/dxvk/proton-9.0-3e/files/lib64:$HOME/zhutest-workload.d/nvtest-sottr/dxvk/proton-9.0-3e/files/lib:/mnt/linuxqa/nvtest/pynv_files/vulkan_loader/sdk-1.2.162.0/Linux_amd64:/mnt/linuxqa/nvtest/pynv_files/vkdevicechooser/Linux_amd64 \
    LIBC_FATAL_STDERR_=1 \
    NODEVICE_SELECT=1 \
    PATH=$HOME/zhutest-workload.d/nvtest-sottr/dxvk/proton-9.0-3e/files/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin \
    PROTON_VR_RUNTIME=1 \
    STEAM_COMPAT_DATA_PATH=$HOME/zhutest-workload.d/nvtest-sottr/dxvk/proton-9.0-3e/prefix \
    VKD3D_CONFIG=dxr \
    VKD3D_DEBUG=none \
    VKD3D_FEATURE_LEVEL=12_2 \
    VK_ICD_FILENAMES=/etc/vulkan/icd.d/nvidia_icd.json \
    VK_INSTANCE_LAYERS=VK_LAYER_AEJS_DeviceChooserLayer \
    VK_LAYER_PATH=/mnt/linuxqa/nvtest/pynv_files/vulkan_loader/sdk-1.2.162.0/Linux_amd64/explicit_layer.d:/mnt/linuxqa/nvtest/pynv_files/vkdevicechooser \
    VR_OVERRIDE=1 \
    VULKAN_DEVICE_INDEX=0 \
    WINEDEBUG=-all \
    WINEDLLOVERRIDES='steam.exe=b;d3d11=n;d3d10core=n;dxgi=n;d3d11x_42=n;d3d11x_43=n;d3d9=n;nvcuda=b;d3d12=n;d3d12core=n;' \
    WINEDLLPATH=$HOME/zhutest-workload.d/nvtest-sottr/dxvk/proton-9.0-3e/files/lib64/wine:$HOME/zhutest-workload.d/nvtest-sottr/dxvk/proton-9.0-3e/files/lib/wine \
    WINEESYNC=1 \
    WINEPREFIX=$HOME/zhutest-workload.d/nvtest-sottr/dxvk/proton-9.0-3e/prefix/pfx \
    WINE_DISABLE_FULLSCREEN_HACK=1 \
    WINE_MONO_OVERRIDES='Microsoft.Xna.Framework.*,Gac=n' \
    __GL_0x301fd6=0x00000005 \
    __GL_0xcfcfa1=0x00000008 \
    __GL_0xfcd802=0x00000001 \
    __GL_4718b=0x00000008 \
    __GL_61807119=$HOME/zhutest-workload.d/nvtest-sottr/log/loadmonitor/00096_run-in-sniper \
    __GL_SHADER_DISK_CACHE=0 \
    __GL_SYNC_TO_VBLANK=0 \
    $HOME/zhutest-workload.d/nvtest-sottr/dxvk/steam-linux-runtime-12249908/run-in-sniper -- \
    $HOME/zhutest-workload.d/nvtest-sottr/dxvk/proton-9.0-3e/files/bin/wine \
    $HOME/zhutest-workload.d/nvtest-sottr/dxvk/run_dir/SOTTR.exe 99999999 0 fps_log | tee /tmp/nvtest-sottr.log &
    
    echo "Recording FPS for 30 seconds..."
    sleep 30
    
    if [[ ! -z $(nvidia-smi) ]]; then
        kill -INT $(nvidia-smi | grep SOTTR.exe | awk '{print $5}')
    else
        echo TODO
    fi 
    sleep 3

    if [[ -e /tmp/nvtest-sottr.log ]]; then 
        cat /tmp/nvtest-sottr.log | tail -n 100 >/tmp/nvtest-sottr-tail-100.log
        echo "Generated /tmp/nvtest-sottr.log"
        echo "Total Average FPS: $(awk '{ total += $1; count++ } END { print total/count }' /tmp/nvtest-sottr.log)"
        echo "Stablized Avg FPS: $(awk '{ total += $1; count++ } END { print total/count }' /tmp/nvtest-sottr-tail-100.log)"
    fi 

    popd >/dev/null 
}

function zhu-install-grand-theft-auto-v {
    zhu-mount-linuxqa || return -1
    if [[ ! -d $HOME/zhutest-workload.d/nvtest-gtav ]]; then
        read -p "Rsync workload from host: " host
        read -e -i wanliz -p "As user: " user
        rsync -ah --progress $user@$host:/home/$user/zhutest-workload.d/nvtest-gtav/ $HOME/zhutest-workload.d/nvtest-gtav/ || return -1
    fi
}

function zhu-nvtest-grand-theft-auto-v {
    zhu-install-grand-theft-auto-v || return -1

    pushd . >/dev/null 
    rm -rf /tmp/nvtest-gtav.log; \
    cd $HOME/zhutest-workload.d/nvtest-gtav/dxvk/run_dir; \
    DISPLAY=:0.0 \
    DXVK_ENABLE_NVAPI=1 \
    DXVK_HUD=full \
    DXVK_LOG_LEVEL=none \
    DXVK_STATE_CACHE=0 \
    LD_LIBRARY_PATH=$HOME/zhutest-workload.d/nvtest-gtav/dxvk/proton-9.0-3e/files/lib64:$HOME/zhutest-workload.d/nvtest-gtav/dxvk/proton-9.0-3e/files/lib:/mnt/linuxqa/nvtest/pynv_files/vulkan_loader/sdk-1.1.92.1/Linux_amd64:/mnt/linuxqa/nvtest/pynv_files/vkdevicechooser/Linux_amd64 \
    LIBC_FATAL_STDERR_=1 \
    NODEVICE_SELECT=1 \
    PATH=$HOME/zhutest-workload.d/nvtest-gtav/dxvk/proton-9.0-3e/files/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin \
    PROTON_VR_RUNTIME=1 \
    STEAM_COMPAT_DATA_PATH=$HOME/zhutest-workload.d/nvtest-gtav/dxvk/proton-9.0-3e/prefix \
    VK_ICD_FILENAMES=/etc/vulkan/icd.d/nvidia_icd.json \
    VK_INSTANCE_LAYERS=VK_LAYER_AEJS_DeviceChooserLayer \
    VK_LAYER_PATH=/dev/null/explicit_layer.d:/mnt/linuxqa/nvtest/pynv_files/vkdevicechooser \
    VR_OVERRIDE=1 \
    VULKAN_DEVICE_INDEX=0 \
    WINEDEBUG=-all \
    WINEDLLOVERRIDES='steam.exe=b;d3d11=n;d3d10core=n;dxgi=n;d3d11x_42=n;d3d11x_43=n;d3d9=n;nvcuda=b;' \
    WINEDLLPATH=$HOME/zhutest-workload.d/nvtest-gtav/dxvk/proton-9.0-3e/files/lib64/wine:$HOME/zhutest-workload.d/nvtest-gtav/dxvk/proton-9.0-3e/files/lib/wine \
    WINEESYNC=1 \
    WINEPREFIX=$HOME/zhutest-workload.d/nvtest-gtav/dxvk/proton-9.0-3e/prefix/pfx \
    WINE_DISABLE_FULLSCREEN_HACK=1 \
    WINE_MONO_OVERRIDES='Microsoft.Xna.Framework.*,Gac=n' \
    __GL_0x301fd6=0x00000005 \
    __GL_0xcfcfa1=0x00000008 \
    __GL_0xfcd802=0x00000001 \
    __GL_4718b=0x00000008 \
    __GL_61807119=$HOME/zhutest-workload.d/nvtest-gtav/log/loadmonitor/00071_run-in-sniper \
    __GL_SHADER_DISK_CACHE=0 \
    __GL_SYNC_TO_VBLANK=0 \
    $HOME/zhutest-workload.d/nvtest-gtav/dxvk/steam-linux-runtime-12249908/run-in-sniper -- \
    $HOME/zhutest-workload.d/nvtest-gtav/dxvk/proton-9.0-3e/files/bin/wine \
    $HOME/zhutest-workload.d/nvtest-gtav/dxvk/run_dir/GTA5.exe 99999999 0 fps_log | tee /tmp/nvtest-gtav.log &
    
    echo "Recording FPS for 30 seconds..."
    sleep 30
    
    if [[ ! -z $(nvidia-smi) ]]; then
        kill -INT $(nvidia-smi | grep GTAV.exe | awk '{print $5}')
    else
        echo TODO
    fi 
    sleep 3

    if [[ -e /tmp/nvtest-gtav.log ]]; then 
        cat /tmp/nvtest-gtav.log | tail -n 100 >/tmp/nvtest-gtav-tail-100.log
        echo "Generated /tmp/nvtest-gtav.log"
        echo "Total Average FPS: $(awk '{ total += $1; count++ } END { print total/count }' /tmp/nvtest-gtav.log)"
        echo "Stablized Avg FPS: $(awk '{ total += $1; count++ } END { print total/count }' /tmp/nvtest-gtav-tail-100.log)"
    fi 

    popd >/dev/null 
}

function zhu-install-cyberpunk2077 {
    zhu-mount-linuxqa || return -1
    if [[ ! -d $HOME/zhutest-workload.d/nvtest-cyberpunk2077 ]]; then
        read -p "Rsync workload from host: " host
        read -e -i wanliz -p "As user: " user
        rsync -ah --progress $user@$host:/home/$user/zhutest-workload.d/nvtest-cyberpunk2077/ $HOME/zhutest-workload.d/nvtest-cyberpunk2077/ || return -1
    fi
}

function zhu-nvtest-cyberpunk2077 {
    zhu-install-cyberpunk2077 || return -1

    pushd . >/dev/null 
    rm -rf /tmp/nvtest-cyberpunk2077.log; \
    cd $HOME/zhutest-workload.d/nvtest-cyberpunk2077/dxvk/run_dir; \
    DISPLAY=:0.0 \
    DXVK_ENABLE_NVAPI=1 \
    DXVK_HUD=full \
    DXVK_LOG_LEVEL=none \
    DXVK_STATE_CACHE=0 \
    LD_LIBRARY_PATH=$HOME/zhutest-workload.d/nvtest-cyberpunk2077/dxvk/proton-9.0-3e/files/lib64:$HOME/zhutest-workload.d/nvtest-cyberpunk2077/dxvk/proton-9.0-3e/files/lib:/mnt/linuxqa/nvtest/pynv_files/vulkan_loader/sdk-1.2.162.0/Linux_amd64:/mnt/linuxqa/nvtest/pynv_files/vkdevicechooser/Linux_amd64 \
    LIBC_FATAL_STDERR_=1 \
    NODEVICE_SELECT=1 \
    PATH=$HOME/zhutest-workload.d/nvtest-cyberpunk2077/dxvk/proton-9.0-3e/files/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin \
    PROTON_VR_RUNTIME=1 \
    STEAM_COMPAT_DATA_PATH=$HOME/zhutest-workload.d/nvtest-cyberpunk2077/dxvk/proton-9.0-3e/prefix \
    VKD3D_CONFIG=dxr \
    VKD3D_DEBUG=none \
    VKD3D_FEATURE_LEVEL=12_2 \
    VK_ICD_FILENAMES=/etc/vulkan/icd.d/nvidia_icd.json \
    VK_INSTANCE_LAYERS=VK_LAYER_AEJS_DeviceChooserLayer \
    VK_LAYER_PATH=/mnt/linuxqa/nvtest/pynv_files/vulkan_loader/sdk-1.2.162.0/Linux_amd64/explicit_layer.d:/mnt/linuxqa/nvtest/pynv_files/vkdevicechooser \
    VR_OVERRIDE=1 \
    VULKAN_DEVICE_INDEX=0 \
    WINEDEBUG=-all \
    WINEDLLOVERRIDES='steam.exe=b;d3d11=n;d3d10core=n;dxgi=n;d3d11x_42=n;d3d11x_43=n;d3d9=n;nvcuda=b;d3d12=n;d3d12core=n;' \
    WINEDLLPATH=$HOME/zhutest-workload.d/nvtest-cyberpunk2077/dxvk/proton-9.0-3e/files/lib64/wine:$HOME/zhutest-workload.d/nvtest-cyberpunk2077/dxvk/proton-9.0-3e/files/lib/wine \
    WINEESYNC=1 \
    WINEPREFIX=$HOME/zhutest-workload.d/nvtest-cyberpunk2077/dxvk/proton-9.0-3e/prefix/pfx \
    WINE_DISABLE_FULLSCREEN_HACK=1 \
    WINE_MONO_OVERRIDES='Microsoft.Xna.Framework.*,Gac=n' \
    __GL_0x301fd6=0x00000005 \
    __GL_0xcfcfa1=0x00000008 \
    __GL_0xfcd802=0x00000001 \
    __GL_4718b=0x00000008 \
    __GL_61807119=$HOME/zhutest-workload.d/nvtest-cyberpunk2077/log/loadmonitor/00072_run-in-sniper \
    __GL_SHADER_DISK_CACHE=0 \
    __GL_SYNC_TO_VBLANK=0 \
    $HOME/zhutest-workload.d/nvtest-cyberpunk2077/dxvk/steam-linux-runtime-12249908/run-in-sniper -- \
    $HOME/zhutest-workload.d/nvtest-cyberpunk2077/dxvk/proton-9.0-3e/files/bin/wine \
    $HOME/zhutest-workload.d/nvtest-cyberpunk2077/dxvk/run_dir/cpLauncher.exe 99999999 0 fps_log | tee /tmp/nvtest-cyberpunk2077.log &
    
    echo "Recording FPS for 30 seconds..."
    sleep 30
    
    if [[ ! -z $(nvidia-smi) ]]; then
        kill -INT $(nvidia-smi | grep cpLauncher.exe | awk '{print $5}')
    else
        echo TODO
    fi 
    sleep 3

    if [[ -e /tmp/nvtest-cyberpunk2077.log ]]; then 
        cat /tmp/nvtest-cyberpunk2077.log | tail -n 100 >/tmp/nvtest-cyberpunk2077-tail-100.log
        echo "Generated /tmp/nvtest-cyberpunk2077.log"
        echo "Total Average FPS: $(awk '{ total += $1; count++ } END { print total/count }' /tmp/nvtest-cyberpunk2077.log)"
        echo "Stablized Avg FPS: $(awk '{ total += $1; count++ } END { print total/count }' /tmp/nvtest-cyberpunk2077-tail-100.log)"
    fi 

    popd >/dev/null 
}

function zhu-install-ngfxcpp-sottr {
    if [[ ! -d ~/zhutest-workload.d/ngfxcpp-sottr ]]; then
        read -p "Rsync workload from host: " host
        read -e -i wanliz -p "As user: " user
        rsync -ah --progress $user@$host:/home/$user/zhutest-workload.d/ngfxcpp-sottr/ ~/zhutest-workload.d/ngfxcpp-sottr || return -1
    fi
}

function zhu-test-ngfxcpp-sottr {
    zhu-install-ngfxcpp-sottr || return -1
    pushd ~/zhutest-workload.d/ngfxcpp-sottr || return -1

    read -e -i 100 -p "Number of frames to repeat: " frames
    chmod +x ./ShadowOfTheTombRaider
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH: ./ShadowOfTheTombRaider -automated -noreset -fps -mincpu -repeat $frames   

    popd >/dev/null 
}

function zhu-install-ngfxcpp-viewperf2020-maya {
    if [[ ! -d ~/zhutest-workload.d/ngfxcpp-viewperf2020-maya ]]; then
        read -p "Rsync workload from host: " host
        read -e -i wanliz -p "As user: " user
        rsync -ah --progress $user@$host:/home/$user/zhutest-workload.d/ngfxcpp-viewperf2020-maya/ ~/zhutest-workload.d/ngfxcpp-viewperf2020-maya || return -1
    fi
}

function zhu-test-ngfxcpp-viewperf2020-maya {
    zhu-install-ngfxcpp-viewperf2020-maya || return -1
    pushd ~/zhutest-workload.d/ngfxcpp-viewperf2020-maya || return -1

    read -e -i 100 -p "Number of frames to repeat: " frames
    chmod +x ./viewperf
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH: ./viewperf -automated -noreset -fps -mincpu -repeat $frames   

    popd >/dev/null 
}

function zhu-install-ngfxcpp-deus-ex-md {
    if [[ ! -d ~/zhutest-workload.d/ngfxcpp-deus-ex-md ]]; then
        read -p "Rsync workload from host: " host
        read -e -i wanliz -p "As user: " user
        rsync -ah --progress $user@$host:/home/$user/zhutest-workload.d/ngfxcpp-deus-ex-md/ ~/zhutest-workload.d/ngfxcpp-deus-ex-md || return -1
    fi
}

function zhu-test-ngfxcpp-deus-ex-md {
    zhu-install-ngfxcpp-deus-ex-md || return -1
    pushd ~/zhutest-workload.d/ngfxcpp-deus-ex-md || return -1

    read -e -i 100 -p "Number of frames to repeat: " frames
    chmod +x ./DeusExMD
    ./DeusExMD -automated -noreset -fps -mincpu -repeat $frames

    popd >/dev/null
}

function zhu-data-visualize {
    if [[ "$1" != *".csv" ]]; then
        read -p "Please confirm the data is in csv format! " _
    fi

    if ! python3 -c "import pandas" &>/dev/null; then
        python3 -m pip install pandas matplotlib numpy 
    fi

    if [[ ! -e /$HOME/zhutest/data-visualize.py ]]; then
        git clone https://github.com/wanlizhu/zhutest $HOME/zhutest || return -1
    fi

    python3 $HOME/zhutest/data-visualize.py "$1"
}

function zhu-nsight-graphics-gpu-trace {
    exe="$1"; shift 
    args="$@"
    dir="$(pwd)"
    architecture="Ampere GA10x"
    metric_set_name="Throughput Metrics"
    start_after_frames=500

    read -e -i "$exe"  -p "--exe: "  exe
    read -e -i "$args" -p "--args: " args
    read -e -i "$dir"  -p "--dir: " dir
    read -e -i "$architecture" -p "--architecture: " architecture
    read -e -i "$metric_set_name" -p "--metric_set_name: " metric_set_name
    read -e -i "$start_after_frames" -p "--start_after_frames: " start_after_frames

    ngfx --activity "GPU Trace Profiler" --exe "$exe" --args "$args" --dir "$dir" --start-after-frames $start_after_frames --limit-to-frames 1 --auto-export --architecture "$architecture" --metric-set-name "$metric_set_name" --multi-pass-metrics --set-gpu-clocks base --disable-nvtx-ranges 1
}

# $1: gpu vendor name to filter
# $2 (optional): target pid to wait
function zhu-stat-ftrace-interrupts {
    if [[ -z $1 ]]; then
        echo "Error:gpu vendor name is required!"
        return -1
    fi

    gpu_irq=$(grep $1 /proc/interrupts | awk '{print $1}' | cut -d: -f1 | head -n 1)
    if [[ -z $gpu_irq ]]; then
        echo "Failed to find IRQ associated with $1"
        return -1
    fi

    sudo rm -rf /tmp/trace.dat
    echo "irq == $gpu_irq" | sudo tee /sys/kernel/tracing/events/irq/irq_handler_entry/filter >/dev/null
    echo "irq == $gpu_irq" | sudo tee /sys/kernel/tracing/events/irq/irq_handler_exit/filter >/dev/null
    
    if [[ -z $2 ]]; then
        sudo trace-cmd record -e irq_handler_entry -e irq_handler_exit -o /tmp/trace.dat 2>/dev/null
    else
        sudo trace-cmd record -e irq_handler_entry -e irq_handler_exit -o /tmp/trace.dat 2>/dev/null &
        ftrace_pid=$!
        while [[ -d /proc/$2 ]]; do 
            sleep 1 
        done 
        sudo kill -INT $ftrace_pid 
        while [[ -d /proc/$ftrace_pid ]]; do 
            sleep 1; 
        done 
    fi 
    
    echo 0 | sudo tee /sys/kernel/tracing/events/irq/irq_handler_entry/filter >/dev/null 
    echo 0 | sudo tee /sys/kernel/tracing/events/irq/irq_handler_exit/filter >/dev/null 

    [[ -z $(which gawk) ]] && sudo apt install -y gawk

    count=$(trace-cmd report -i /tmp/trace.dat | grep "irq=$gpu_irq" | grep irq_handler_exit | grep ret=handled | wc -l)
    factor_us=1000000
    total_time=$(trace-cmd report -i /tmp/trace.dat | gawk -v target="$gpu_irq" -v factor="$factor_us" '
        /irq_handler_entry/ {
            if ($0 ~ ("irq=" target)) {
                # Extract timestamp from field 3 by removing the trailing colon.
                ts = substr($3, 1, length($3)-1) * 1.0;
                entry[$2] = ts;
                next;
            }
        }
        /irq_handler_exit/ {
            if ($0 ~ ("irq=" target) && ($2 in entry)) {
                ts = substr($3, 1, length($3)-1) * 1.0;
                total += (ts - entry[$2]);
                delete entry[$2];
            }
        }
        END { printf "%.03f", total * factor }
    ')
    avg_time=$(echo "scale=3; $total_time / $count" | bc)

    echo "Interrupts count: $count (Avg-time: $avg_time us)"
}

function zhu-stat-interrupts-snapshot {
    if [[ -z $1 ]]; then
        return -1
    fi

    sum=0
    for i in $(seq $(nproc)); do 
        num=$(grep "$1" /proc/interrupts | awk "{print \$$(($i + 1))}")
        sum=$((sum + num))
    done
    echo $sum
}

# $1: target pid to wait
function zhu-stat-gpu-interrupts {
    if [[ -z $1 ]]; then
        echo "Error: target pid is required!"
        return -1
    fi

    if lsmod | grep -q nvidia; then
        vendor="nvidia"
    else
        vendor="amdgpu"
    fi

    count_snapshot_begin=$(zhu-stat-interrupts-snapshot $vendor)
    count_ftrace_and_time=$(zhu-stat-ftrace-interrupts $vendor $1 | grep "Interrupts count:" | awk '{print $3, $4, $5, $6}')
    count_snapshot_end=$(zhu-stat-interrupts-snapshot $vendor)
    count_snapshot=$((count_snapshot_end - count_snapshot_begin))
    
    echo "Interrupts #1 (/proc/interrupts): $count_snapshot"
    echo "Interrupts #2 (ftrace): $count_ftrace_and_time"
}

function zhu-p4git-reset-hard {
    echo "P4CLIENT=$P4CLIENT"
    echo "P4ROOT=$P4ROOT"
    read -p  "Please confirm the p4 client is correct! " _

    pushd "$P4ROOT" >/dev/null 
        p4 reconcile -w
        p4 revert //...
    popd >/dev/null 
}

# Doesn't work
# glxgears is not using those fake api
function zhu-null-driver {
    if [[ ! -d ~/zhutest/src/zhutest-null-driver ]]; then
        git clone https://github.com/wanlizhu/zhutest ~/zhutest || return -1
    fi
    
    rootdir=~/zhutest/src/zhutest-null-driver
    cat $rootdir/glad.h | $rootdir/glad-api-conv.py > /tmp/glad-exports.h || return -1

    rm -rf /tmp/zhutest-null-driver.so
    gcc -c ~/zhutest/src/zhutest-null-driver/glad.c -fPIC -o /tmp/glad.a &&
    g++ -shared -fPIC -I$rootdir -o /tmp/zhutest-null-driver.so $rootdir/dsomain.cpp -ldl -lGL -lX11 /tmp/glad.a &&
    echo "Generated /tmp/zhutest-null-driver.so" || return -1

    if [[ ! -z $1 ]]; then
        __GL_SYNC_TO_VBLANK=0 vblank_mode=0 LD_PRELOAD=/tmp/zhutest-null-driver.so "$@"
    fi 
}

function zhu-uniq {
    awk '!seen[$0]++'
}

function zhu-apitrace-list-api {
    apitrace dump $1 | awk '{print $2}' | awk -F'(' '{print $1}' | awk '!seen[$0]++'
}

function zhu-run-in-proton {
    if [[ ! -d ~/.steam/steam/steamapps/common/'Proton 9.0 (Beta)' ]]; then
        read -e -i 172.16.179.143 -p "Rsync 'Proton 9.0 (Beta)' from: " host_ip
        read -e -i wanliz -p "As user: " user
        mkdir -p ~/.steam/steam/steamapps/common/'Proton 9.0 (Beta)'
        rsync -ah --progress $user@$host_ip:/home/$user/.steam/steam/steamapps/common/'Proton 9.0 (Beta)'/ ~/.steam/steam/steamapps/common/'Proton 9.0 (Beta)'/ || return -1
    fi 

    ln -sf ~/.steam/steam/steamapps/common/'Proton 9.0 (Beta)' ~/.steam/steam/steamapps/common/proton_9.0_beta

    export proton_dir=$HOME/.steam/steam/steamapps/common/proton_9.0_beta
    export PATH="$proton_dir/files/bin:$PATH"
    export LD_LIBRARY_PATH="$proton_dir/files/lib64:$proton_dir/files/lib64/wine/x86_64-unix:$proton_dir/files/lib:$proton_dir/files/lib/wine/i386-unix:$LD_LIBRARY_PATH"
    export STEAM_COMPAT_DATA_PATH="$proton_dir/prefix"
    export PROTON_VR_RUNTIME=0
    export WINEDLLPATH="$proton_dir/files/lib64/wine:$proton_dir/files/lib64/wine/x86_64-windows:$proton_dir/files/lib/wine:$proton_dir/files/lib/wine/i386-windows"
    export WINEPREFIX="$proton_dir/prefix"
    export WINE_DISABLE_FULLSCREEN_HACK=1
    export __GL_SHADER_DISK_CACHE=0
    export __GL_SYNC_TO_VBLANK=0

    #for dlldir in "vkd3d wine/dxvk wine/nvapi wine/vkd3d-proton"

    $proton_dir/files/bin/wine "$@"
}

function zhu-ssh-test-machine {
    ssh -o StrictHostKeyChecking=no wanliz@wanliz-test.client.nvidia.com
}

function zhu-rsync-zhutest-workload {
    read -e -i wanliz-test.client.nvidia.com -p "Rsync from remote host: " host_ip
    read -e -i wanliz -p "As user: " user
    time rsync -ah --progress $user@$host_ip:/home/$user/zhutest-workload.d/ $HOME/zhutest-workload.d 
}

function zhu-rsync-p4sw-bugfix_main {
    read -e -i wanliz-test.client.nvidia.com -p "Rsync from remote host: " host_ip
    read -e -i wanliz -p "As user: " user
    time rsync -ah --progress --exclude="_out/" --exclude=".git/" --exclude=".vscode/" $user@$host_ip:/home/$user/wanliz-p4sw-bugfix_main/ $HOME/wanliz-p4sw-bugfix_main 
}

function zhu-rsync-linux-kernel {
    if [[ $EUID != 0 ]]; then
        echo "Please run as sudo!"
        return -1
    fi

    read -e -i wanliz-test.client.nvidia.com -p "Rsync from remote host: " host_ip
    read -e -i wanliz  -p "As user: " user
    ssh -o StrictHostKeyChecking=no $user@$host_ip "ls -al /boot"
    read -p "Linux kernel: " kernel
    read -s -p "Password: " passwd

    sshpass -p "$passwd" rsync -ah --progress $user@$host_ip:/boot/vmlinuz-$kernel /boot/vmlinuz-$kernel
    sshpass -p "$passwd" rsync -ah --progress $user@$host_ip:/boot/config-$kernel /boot/config-$kernel
    sshpass -p "$passwd" rsync -ah --progress $user@$host_ip:/boot/System.map-$kernel /boot/System.map-$kernel
    sshpass -p "$passwd" rsync -ah --progress $user@$host_ip:/lib/modules/$kernel/ /lib/modules/$kernel/
    sshpass -p "$passwd" rsync -ah --progress $user@$host_ip:/usr/src/linux-headers-$kernel/ /usr/src/linux-headers-$kernel/
    update-initramfs -c -k $kernel
    update-grub
}

function zhu-rsync-firmware {
    read -e -i wanliz-test.client.nvidia.com -p "Rsync from remote host: " host_ip
    read -e -i wanliz  -p "As user: " user
    ssh -o StrictHostKeyChecking=no $user@$host_ip "ls -al /boot/efi/firmware"
    read -p "Firmware: " firmware

    sudo mkdir -p /boot/efi/firmware
    sudo rsync -ah --progress $user@$host_ip:/boot/efi/firmware/$firmware /boot/efi/firmware/$firmware 
}

function zhu-rsync-steam {
    read -e -i wanliz-test.client.nvidia.com -p "Rsync from remote host: " host_ip
    read -e -i wanliz  -p "As user: " user
    
    if [[ -d ~/.steam && ! -d ~/.steam.backup ]]; then
        mv ~/.steam ~/.steam.backup
    fi

    # ssh_dispatch_run_fatal: Connection to 10.31.40.190 port 22: message authentication code incorrect
    rsync -ah --progress -e "ssh -o StrictHostKeyChecking=no -m hmac-sha2-512" $user@$host_ip:/home/$user/.steam/ ~/.steam/
}

function zhu-digits-max-clocks {
    if [[ ! -d ~/iGPU_vfmax_scripts ]]; then
        rsync -ah --progress /mnt/linuxqa/wlueking/n1x-bringup/iGPU_vfmax_scripts $HOME 
    fi

    if [[ ! -d ~/CPU_fmax_scripts ]]; then
        rsync -ah --progress /mnt/linuxqa/wlueking/n1x-bringup/CPU_fmax_scripts $HOME 
    fi

    if [[ ! -e /etc/modprobe.d/nvidia-power-feature.conf ]]; then
        echo "options nvidia NVreg_RegistryDwords=\"RmPowerFeature=0x55455555; RmPowerFeature2=0x55555550;\"" | sudo tee /etc/modprobe.d/nvidia-power-feature.conf
        echo "Reboot to apply changes!"
    else
        cat /proc/driver/nvidia/params | grep RmPowerFeature=
        cat /proc/driver/nvidia/params | grep RmPowerFeature2=
    fi

    sudo nvidia-smi -pm 1
    sudo $HOME/CPU_fmax_scripts/CPU_fmax_recipe.sh
    sudo $HOME/iGPU_vfmax_scripts/igpu_vf_unlock.sh
    sudo $HOME/iGPU_vfmax_scripts/igpu_vfmax_lock_recipe.sh
}

function zhu-digits-connect {
    zhu-connect 
}

function zhu-connect {
    if [[ $1 == 6 ]]; then 
        if [[ $2 == h* ]]; then 
            sshpass -p root ssh -o StrictHostKeyChecking=no root@linux-bringup6.client.nvidia.com
        else 
            sshpass -p nvidia ssh -o StrictHostKeyChecking=no nvidia@10.31.40.169
        fi 
    elif [[ $1 == 7 ]]; then
        if [[ $2 == h* ]]; then 
            sshpass -p root ssh -o StrictHostKeyChecking=no root@linux-bringup7.client.nvidia.com
        else 
            sshpass -p nvidia ssh -o StrictHostKeyChecking=no nvidia@10.31.40.190
        fi 
    fi 
}

function zhu-sshkey {
    if [[ -z $1 ]]; then
        echo "Usage: zhu-sshkey user@host"
        return -1
    fi

    if [[ ! -e ~/.ssh/id_ed25519 ]]; then
        ssh-keygen -t ed25519 
    fi 
    ssh-copy-id $1
}

function zhu-check-desktop {
    if [[ -z $(pidof Xorg) ]]; then
        echo "No X server!"
    else
        ps aux | grep [X]org
        echo  
    fi
    zhu-check-vncserver
}

function zhu-open-and-share-desktop {
    if [[ ! -z $(pidof Xorg) ]]; then
        if [[ ! -z $(zhu-check-vncserver) ]]; then
            echo "X server is running and sharing already!"
            return 
        fi
    fi

    if [[ -z $DISPLAY ]]; then
        export DISPLAY=:0
    fi
    
    if [[ ! -z $(sudo ls /root/nvt 2>/dev/null) ]]; then
        zhu-setup-nopasswd-sudo
        zhu-mount-linuxqa 
        echo "NVTEST_NO_SMI=1 NVTEST_NO_RMMOD=1 NVTEST_NO_MODPROBE=1 /mnt/linuxqa/nvt.sh 3840x2160__runcmd --cmd 'sleep 2147483647' 2>&1 | tee /tmp/nvtest-xorg.log" > /tmp/nvtest-xorg.sh
        chmod +x /tmp/nvtest-xorg.sh
        echo "Password of root will be asked for"
        su - root -c "screen -dmS nvtest-xorg bash /tmp/nvtest-xorg.sh"
        echo "Wait for X server to start up"
        while [[ -z $(pidof Xorg) ]]; do 
            sleep 3
        done
    fi

    zhu-xserver-with-vnc
}

function zhu-steam {
    FEXInterpreter ~/.fex-emu/RootFS/Ubuntu_24_04/usr/games/steam
}

function zhu-install-picx {
    echo 
}
