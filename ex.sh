#!/bin/bash
# Set the interface and duration
interface="wlan0"
duration=5


# Prompt for username and password using Zenity
username=$(zenity --entry --title="Authentication" --text="Enter your username:")
password=$(zenity --entry --title="Authentication" --text="Enter your password:" --hide-text)

# Authenticate the user with the su command
echo $password | su -c "whoami" - $username

# Check if the authentication was successful
if [ $? -eq 0 ]; then
zenity --info --title="Hello" --text="Hello, welcome : $username!"
items=("Calcul a traffic" "1" "Cancel" "2")

# Display the list of items using Zenity
selected_item=$(zenity --list --title="Select an item" --column="Item" --column="Value" "${items[@]}" --print-column=2)

	# Check if an item was selected
	if [ $selected_item -eq "1" ]; then
    	# Display the selected item's value in a dialog box
  	 # zenity --info --title="Selected item" --text="You selected: $selected_item"
       	# Show the available interfaces
		interfaces=$(ip a | awk '/^[0-9]:/ {print $2}' | cut -d: -f1)
		echo "Network interfaces on this system:"
		echo $interfaces
	
	
		# Select the interface to monitor
		read -p "Enter the name of the interface to monitor: " interface
		#Rendre un fichier en mode temporaire .
		rd= $(rm dd.dat)
		#echo "Supprimer le fichier "+rd
		ad= $(touch dd.dat)
		#echo "Ajouter le fichier "+ad
		#
		# Une boucle pour faire des capture et les calcules 5 fois dans 5 seconde
		for i in {1..5};do
		# Get the initial network traffic values
		initial_rx=$(cat /sys/class/net/$interface/statistics/rx_bytes)
		initial_tx=$(cat /sys/class/net/$interface/statistics/tx_bytes)

		# Wait for the specified duration
		sleep $duration

		# Get the final network traffic values
		final_rx=$(cat /sys/class/net/$interface/statistics/rx_bytes)
		final_tx=$(cat /sys/class/net/$interface/statistics/tx_bytes)

		# Calculate the traffic (received and transmitted)
		rx_traffic=$((final_rx - initial_rx))
		tx_traffic=$((final_tx - initial_tx))


		echo "Network traffic for $interface over $duration seconds:"
		# Print the results
		if (($rx_traffic > $tx_traffic)); then
		echo "Total: $((rx_traffic - tx_traffic ))  bytes"
		echo  $((rx_traffic - tx_traffic ))  >> dd.dat
		elif (($rx_traffic < $tx_traffic)); then
		echo "Total: $((rx_traffic - tx_traffic ))  bytes"
		echo  $(($tx_traffic - $rx_traffic)) >> dd.dat
		else
		echo "Total: $tx_traffic  bytes"
                fi
		done 

        

	else 
   	 	# Display an error message if no item was selected
	result=$(zenity --question --text "Are you sure you want to quit?" --ok-button "Yes")
  		echo "User pressed in cancel button"
  	fi

else
    zenity --error --title="Authentication" --text="Authentication failed."
fi

