#!/usr/bin/env bash
turbo_file="/sys/devices/system/cpu/intel_pstate/no_turbo"

# Check if driver file exists
if [ ! -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver ]; then
    echo "Driver file not found"
    exit 1
fi

# Read the driver for the first available CPU
driver=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver)

if [[ $driver == "intel_pstate" ]]; then
    echo "Intel CPU frequency scaling driver (intel_pstate) is active."
    echo "Continuing..."
else
    echo "Intel CPU frequency scaling driver (intel_pstate) is not active."
    echo "Current driver: $driver"
    exit 1
fi

# Check if turbo file exists
if [ ! -f "$turbo_file" ]; then
    echo "Turbo file not found: $turbo_file"
    echo "Creating turbo file..."
    echo "" | sudo tee "$turbo_file" > /dev/null
    echo "Done!"
else
    echo "Turbo file exists."
    echo "Continuing..."
fi
# Check if turbo boost is enabled or disabled
clear
turbo_val=$(cat /sys/devices/system/cpu/intel_pstate/no_turbo)
case "$turbo_val" in
    0)
        turbo_boost="enabled"
        ;;
    1)
        turbo_boost="disabled"
        ;;
    *)
        turbo_boost="unknown"
        exit 1
        ;;
esac

echo "Turbo boost is $turbo_boost."

case "$turbo_boost" in 
    "enabled")
        read -r -p "Do you want to disable turbo boost? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
            echo "Disabling turbo boost..."
            echo 1 | sudo tee "$turbo_file" > /dev/null
            echo "Turbo boost disabled."
            exit 1
        fi
        ;;
    "disabled")
        read -r -p "Do you want to enable turbo boost? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
            echo "Enabling turbo boost..."
            echo 0 | sudo tee "$turbo_file" > /dev/null
            echo "Turbo boost enabled."
            exit 1
        fi
        ;;
    *)
        echo "Unknown turbo boost status."
        exit 1
        ;;
esac
