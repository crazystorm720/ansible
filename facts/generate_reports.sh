#!/bin/bash

# Directory containing JSON files
json_dir="/home/medusa/ansible/facts"

# Function to extract and format information
extract_info() {
    local file=$1
    local md_file=$2
    local label=$3
    local query=$4
    local info=$(jq -r "$query" "$file")
    echo "### $label" >> "$md_file"
    if [ "$info" != "" ]; then
        echo "\`\`\`" >> "$md_file"
        echo "$info" >> "$md_file"
        echo "\`\`\`" >> "$md_file"
    else
        echo "Information not available" >> "$md_file"
    fi
    echo "" >> "$md_file"
}

# Process each JSON file
for json_file in "$json_dir"/*.json; do
    # Skip if not a file
    [ -f "$json_file" ] || continue

    # Extract hostname from the filename
    hostname=$(basename "$json_file" .json)

    # Markdown file for each system
    md_file="$json_dir/${hostname}-report.md"

    # Start writing to markdown file
    echo "# System Information Report for $hostname" > "$md_file"
    echo "Report generated on $(date)" >> "$md_file"
    echo "" >> "$md_file"

    # Add sections
    extract_info "$json_file" "$md_file" "BIOS and Board Information" '.bios_vendor, .bios_version, .bios_date, .board_name, .board_vendor'
    extract_info "$json_file" "$md_file" "Processor Information" '.processor[]'
    extract_info "$json_file" "$md_file" "Memory Information" '.memtotal_mb, .memfree_mb'
    extract_info "$json_file" "$md_file" "Network Configuration" '.interfaces[], .default_ipv4, .dns'
    extract_info "$json_file" "$md_file" "Storage Information" '.mounts[] | {mount: .mount, device: .device, fstype: .fstype, size_total: .size_total, size_available: .size_available}'
    extract_info "$json_file" "$md_file" "SSH Public Keys" '.ssh_host_key_rsa_public, .ssh_host_key_ecdsa_public, .ssh_host_key_ed25519_public'

    # Display enhanced message
    echo "Generated report for $hostname at $md_file"
done

echo "All reports generated successfully."
