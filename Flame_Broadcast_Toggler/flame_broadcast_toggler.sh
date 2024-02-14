#!/bin/bash
#
# 12/18/23
#
# Name: The Flame Broadcast Toggler
#
# USAGE: ./flame_broadcast_toggler.sh
# REQUIRED: sudo credentials will be required after launching the script, however, please avoid executing it as sudo or root.
#
# See README.md for description, disclaimer, testing environments, and caveats.
#
# Always Current Version: https://github.com/flamescripts/Flame_Scripts


# FUNCTION TO CHECK CURRENT NODE
function check_current_mode() {
	local initconfig_file=$1
	local possible_modes=("${@:2}")

	for mode in "${possible_modes[@]}"; do
		video_line=$(awk -v mode=$mode '!/^[#]/ && /Video .*Serial1/ {print $0}' "$initconfig_file")
		audio_line=$(awk -v mode=$mode '!/^[#]/ && /Audiodevice/ {print $0}' "$initconfig_file")
		video_mode=$(echo $video_line | cut -d' ' -f2 | tr -d ',')
		audio_mode=$(echo $audio_line | cut -d' ' -f2 | tr -d ',')

		if grep -q "${mode}" <<< "${video_line}" && grep -q "${mode}" <<< "${audio_line}"; then
			current_mode=$mode
			 break
		elif [ "$mode" == "NONE" ] && [ -z "$video_line" ] && [ -z "$audio_line" ]; then
			current_mode=$mode
			break
		elif [[ "$audio_mode" == "CoreAudio" && "$video_mode" == "" ]]; then
			current_mode=$audio_mode
			break
		elif [[ "$video_mode" != "$audio_mode" ]] && [[ "$audio_mode" != "CoreAudio" || "$video_mode" != "" ]]; then
			current_mode="MISMATCHED KEYWORDS"
			break
		fi
	done

	echo
	echo "The current selected mode is: $current_mode"
	echo "- V: $video_line"
	echo "- A: $audio_line"
	echo
}

# FUNCTION TO MODIFY VIDEO DEVICE IN INIT.CFG
function modify_video_device_line() {
    local mode=$1
    if [ "$mode" == "NONE" ] || [ "$mode" == "CoreAudio" ]; then
        sudo sed -i -e "/^Video .*, Serial1/ d" "$initconfig_file"
    else
        video_line_exists=$(grep -c "^Video .*, Serial1" "$initconfig_file")
        if [ $video_line_exists -gt 0 ]; then
            sudo perl -pi -e "s|.*Video.*, Serial1.*|Video ${mode}, Serial1|g" "$initconfig_file"
        else
            echo "Video ${mode}, Serial1" | sudo tee -a "$initconfig_file"
        fi
    fi
}

# FUNCTION TO MODIFY AUDIO DEVICE IN INIT.CFG
function modify_audio_device_line() {
    local mode=$1
    audio_line_exists=$(grep -c "^Audiodevice .*" "$initconfig_file")
    if [ "$mode" == "NONE" ]; then
        sudo sed -i -e "/^Audiodevice .*/ d" "$initconfig_file"
    elif [ "$mode" == "CoreAudio" ]; then
        sudo sed -i -e "/^Audiodevice .*/ d" "$initconfig_file"
        echo "Audiodevice CoreAudio" | sudo tee -a "$initconfig_file"
    elif [ $audio_line_exists -gt 0 ]; then
        sudo perl -pi -e "s|.*Audiodevice.*|Audiodevice ${mode}|g" "$initconfig_file"
    else
        echo "Audiodevice ${mode}" | sudo tee -a "$initconfig_file"
    fi
}

# FUNCTION TO MODIFY PREVIEW DEVICE IN INIT.CFG
function modify_preview_device_lines() {
    local new_mode=$1
    local display_mode=$new_mode

    clear
    if [[ "$new_mode" == "CoreAudio" || "$new_mode" == "NONE" ]]; then
        echo "Switching to $display_mode."
        echo "- Modifying Audio/Video Device keywords and broadcast selection."
        return
    elif [[ "$new_mode" == "AJA" ]]; then
        new_mode=$(echo "$new_mode" | tr '[:upper:]' '[:lower:]')
    fi

    local temp_file=$(mktemp) || { echo "Unable to create temporary file"; exit 1; }
    sed -E "s/^(VideoPreviewDevice.*)(NDI|BMD|AJA|aja)(,.*)$/\1$new_mode\3/g" "$initconfig_file" > "$temp_file"
    sudo install -m 666 -o "$(id -u)" -g "$(id -g)" "$temp_file" "$initconfig_file"
    rm "$temp_file"
    echo "Switching to $display_mode."
        echo "- Modifying Audio/Video Device keywords, broadcast selection, and active Preview Device."
}

# FUNCTION TO TOGGLE BROADCAST PREFERENCES IN BROADCASTCURRENT.PREF
function toggle_broadcast() {
    local search=$1
    local replace=$2
    printf "%s\n" "g/$search/s/.*/$replace/" w | ed -s "$broadcast_pref_file"
}


# FUNCTION TO GET CURRENT PROJECT AND LIST ALL PROJECTS
function get_project() {
    # GET MOST RECENTLY OPENED FLAME PROJECT NAME AND CREATE AN ARRAY OF ALL AVAILABLE PROJECTS
    current_project_name=$(awk -F"[{}]" '/ProjectGroupStatus/ {print $2}' /opt/Autodesk/project/project.db | tr -d '\n';)
    project_listing=$(/opt/Autodesk/wiretap/tools/current/wiretap_get_children -n /projects -N)
    IFS=$'\n' read -rd '' -a project_listing_array <<<"$project_listing"

    echo "Please enter an index number to select a project or press [enter] to continue using $current_project_name: "
    # PRINT PROJECT LIST AND INDICATE CURRENT PROJECT
    echo
    for index in "${!project_listing_array[@]}"; do
        if [ "${project_listing_array[$index]}" = "$current_project_name" ]; then
            echo "$index: ${project_listing_array[$index]} <-- (Current Project)"
        else
            echo "$index: ${project_listing_array[$index]}"
        fi
    done

    # PROMPT ARTIST FOR DESIRED PROJECT AND VALIDATE INPUT
    echo
    read -p "Project selection: " project_index

    if [ -z "$project_index" ] ;then
        clear
        echo "$current_project_name project will continue be used."
        echo
    elif [[ $project_index =~ ^[0-9]+$ ]] && (( project_index >= 0 && project_index < ${#project_listing_array[@]} )); then
        clear
        current_project_name="${project_listing_array[$project_index]}"
        echo "$current_project_name project will be used."
        echo
    else
        clear
        echo "Invalid project index. Exiting..."
        exit 2
    fi
}

# MAIN PROGRAM

# GREETINGS PROGRAMS - LOGIN HERE INSTEAD OF RUNNING SCRIPT AS SUDO 
clear
echo "Welcome to the Flame Broadcast Toggler"
echo
echo "Please enter your sudo credentials to continue"
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi
clear

# GET CURRENT PROJECT AND LIST ALL PROJECTS
get_project

# GET PROJECT NAME, VERSION, PREFERENCE, SET BACKUP FILES AND VARIABLES
current_project_stats="/opt/Autodesk/project/${current_project_name}/status/project.status"
current_flame_family=$(awk '/# Status/ {print $(NF-1)"_"$NF}' "$current_project_stats")
current_version=$(awk '/^# Status/ {print $NF}' "$current_project_stats")
possible_modes=("NDI" "AJA" "BMD" "CoreAudio" "NONE")
initconfig_file="/opt/Autodesk/${current_flame_family}/cfg/init.cfg"
flame_binary="/opt/Autodesk/${current_flame_family}/bin/startApplication --start-project=$current_project_name"
broadcast_pref_file="/opt/Autodesk/project/$current_project_name/status/broadcastCurrent.pref"
initconfig_backups=("$initconfig_file".bak_*)
broadcast_pref_backups=("$broadcast_pref_file".bak_*)
max_backup_files=5
mode=""

# CHECK IF NECESSARY FILES ARE PRESENT
if [[ ! -f "$current_project_stats" || ! -f "$initconfig_file" || ! -f "$broadcast_pref_file" ]]; then
    echo "At least one of these files is missing, you should look into this before proceeding";echo
    echo "Broadcast preference file:"
    echo "- $broadcast_pref_file";echo
    echo "Project Status file:"
    echo "- $current_project_stats";echo
    echo "$current_flame_family Init configuration file:"
    echo "- $initconfig_file";echo
    exit 3
else
    # IF PRESENT, BACKUP THE CONFIG FILES
    echo "Backing up the Flame Family $current_version init.cfg:"
    sudo tar -czpPf $initconfig_file.bak_$(date +%m%d%Y_%H%M).tar.gz $initconfig_file
    echo "$initconfig_file.bak_$(date +%m%d%Y_%H%M).tar.gz"
    echo
    echo "Backing up current '$current_project_name' project broadcast preferences:"
    echo "$broadcast_pref_file.bak_$(date +%m%d%Y_%H%M).tar.gz"
    sudo tar -czpPf $broadcast_pref_file.bak_$(date +%m%d%Y_%H%M).tar.gz $broadcast_pref_file

    # CHECK MAXIMUM NUMBER OF BACKUP FILES ALLOWED AND REMOVE EXCESS BACKUP FILES
    echo
    num_initconfig_backups=${#initconfig_backups[@]}
    num_broadcast_pref_backups=${#broadcast_pref_backups[@]}
    if (( num_initconfig_backups > max_backup_files )); then
        excess_initconfig_backups=$(( num_initconfig_backups - max_backup_files ))
        oldest_initconfig_backups=("${initconfig_backups[@]:0:$excess_initconfig_backups}")
        echo "The following older '$current_project_name' init.cfg backups will be removed:"
        sudo rm -v "${oldest_initconfig_backups[@]}"
        echo
    fi
    if (( num_broadcast_pref_backups > max_backup_files )); then
        excess_broadcast_pref_backups=$(( num_broadcast_pref_backups - max_backup_files ))
        oldest_broadcast_pref_backups=("${broadcast_pref_backups[@]:0:$excess_broadcast_pref_backups}")
        echo "The following older '$current_project_name' broadcast preferences backups will be removed:"
        sudo rm -v "${oldest_broadcast_pref_backups[@]}"
        echo
    fi
fi


## CHECK FOR INITIAL MODE
current_mode=""
check_current_mode "$initconfig_file" "${possible_modes[@]}"

## PROMPT FOR A NEW MODE SELECTION
while true; do
    read -p $'Please enter the new mode to switch from the following options:\n- NDI, AJA, BMD, CoreAudio, NONE: ' new_mode
	[[ "${new_mode}" != "CoreAudio" ]] && new_mode=$(echo "${new_mode}" | tr '[:lower:]' '[:upper:]')
	echo "${new_mode}"

    # CHECK IF FLAME ARTIST SELECTED THE SAME MODE AS THE CURRENT MODE
    if [ "$new_mode" == "$current_mode" ]; then
        clear
        echo "Already in $current_mode mode."
        continue
    fi

    # CHECK IF NEW_MODE SELECTION IS VALID
    if [[ ! " ${possible_modes[@]} " =~ " ${new_mode} " ]]; then
        clear
        echo "Invalid mode: $new_mode"
        continue
    fi
    break
done

# UPDATE CONFIG FILES BASED ON ARTIST SELECTION
modify_video_device_line "$new_mode"
modify_audio_device_line "$new_mode"
modify_preview_device_lines "$new_mode"

case "$new_mode" in
    "NDI")
        toggle_broadcast "11 PreviewMode" "11 PreviewMode, 3"
        toggle_broadcast "11 PreviewTiming" "11 PreviewTiming, 7"
        toggle_broadcast "11 PreviewDataFormat" "11 PreviewDataFormat, 1"
        toggle_broadcast "11 PreviewTransport4K" "11 PreviewTransport4K, 1"
        toggle_broadcast "11 PreviewVideoRange" "11 PreviewVideoRange, 0"
        toggle_broadcast "11 PreviewDevice" "11 PreviewDevice, 1"
        toggle_broadcast "10 PreviewEnabled" "10 PreviewEnabled, 0"
        ;;
    "AJA")
        toggle_broadcast "11 PreviewMode" "11 PreviewMode, 0"
        toggle_broadcast "11 PreviewTiming" "11 PreviewTiming, -1"
        toggle_broadcast "11 PreviewDataFormat" "11 PreviewDataFormat, 6"
        toggle_broadcast "11 PreviewTransport4K" "11 PreviewTransport4K, 2"
        toggle_broadcast "11 PreviewVideoRange" "11 PreviewVideoRange, 0"
        toggle_broadcast "11 PreviewDevice" "11 PreviewDevice, 0"
        toggle_broadcast "10 PreviewEnabled" "10 PreviewEnabled, 0"
        ;;
    "BMD")
        toggle_broadcast "11 PreviewMode" "11 PreviewMode, 3"
        toggle_broadcast "11 PreviewTiming" "11 PreviewTiming, 46"
        toggle_broadcast "11 PreviewDataFormat" "11 PreviewDataFormat, 1"
        toggle_broadcast "11 PreviewTransport4K" "11 PreviewTransport4K, 1"
        toggle_broadcast "11 PreviewVideoRange" "11 PreviewVideoRange, 1"
        toggle_broadcast "11 PreviewDevice" "11 PreviewDevice, 1"
        toggle_broadcast "10 PreviewEnabled" "10 PreviewEnabled, 0"
        ;;
    "CoreAudio")
        toggle_broadcast "11 PreviewMode" "11 PreviewMode, 3"
        toggle_broadcast "11 PreviewTiming" "11 PreviewTiming, 62"
        toggle_broadcast "11 PreviewDataFormat" "11 PreviewDataFormat, 1"
        toggle_broadcast "11 PreviewTransport4K" "11 PreviewTransport4K, 1"
        toggle_broadcast "11 PreviewVideoRange" "11 PreviewVideoRange, 0"
        toggle_broadcast "11 PreviewDevice" "11 PreviewDevice, 2"
        toggle_broadcast "10 PreviewEnabled" "10 PreviewEnabled, 1"
        ;;
    "NONE")  
        toggle_broadcast "11 PreviewMode" "11 PreviewMode, 3"
        toggle_broadcast "11 PreviewTiming" "11 PreviewTiming, 62"
        toggle_broadcast "11 PreviewDataFormat" "11 PreviewDataFormat, 1"
        toggle_broadcast "11 PreviewTransport4K" "11 PreviewTransport4K, 1"
        toggle_broadcast "11 PreviewVideoRange" "11 PreviewVideoRange, 0"
        toggle_broadcast "11 PreviewDevice" "11 PreviewDevice, 2"
        toggle_broadcast "10 PreviewEnabled" "10 PreviewEnabled, 1"
        ;;
    *)
        echo "Invalid mode: $new_mode"
        exit 4
        ;;
esac

# RECHECK SELECTED MODE FOR AUDIO AND VIDEO DEVICES AND PRESENT RESULTS TO ARTIST
current_mode=""
check_current_mode "$initconfig_file" "${possible_modes[@]}"

## FLAME ON
echo "Would you like to launch $current_flame_family?" | sed -e 's,_, ,g'
read -n 1 -r -p "Press Y for Yes or press any key to exit: " launch_flame
if [[ $launch_flame =~ ^[Yy]$ ]]; then
	clear
	echo "Launching $current_flame_family in $new_mode mode using project $current_project_name as the $SUDO_USER user"
	sleep 2
	sudo -u $SUDO_USER bash -c "$flame_binary"
	exit 0
fi
