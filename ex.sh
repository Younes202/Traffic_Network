#!/bin/bash
# Set the interface and duration
interface="wlan0"
duration=5

rx_traffic=0
tx_traffic=0
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
       	# L'affichage des interfaces qui existe dans votre réseau
		interfaces=$(ip a | awk '/^[0-9]:/ {print $2}' | cut -d: -f1)
		echo "Network interfaces on this system:"
		echo $interfaces
	
	
		# Selectioner une interface 
		read -p "Enter the name of the interface to monitor: " interface
		#Rendre un fichier en mode temporaire via une methode que j'ai le fait , c'est quoi à chaque compilation du code les anciens données ils ont supprimer 

		$(rm data.txt)
				# par la suite on crée un autre  vierge pour le remplie 
		$(touch  data.txt && chmod +777 data.txt)
		
	

		# Une boucle pour faire des capture et les calcules 4 fois dans 5 seconde
		for i in {2..5};do
		# capture (Etat initial de signale ) 
		initial_rx=$(cat /sys/class/net/$interface/statistics/rx_bytes)
		initial_tx=$(cat /sys/class/net/$interface/statistics/tx_bytes)

		# Wait for
	        # le temps restant entre les les deux tests
		sleep $duration

		# capture (Etat final de signale ) 
		final_rx=$(cat /sys/class/net/$interface/statistics/rx_bytes)
		final_tx=$(cat /sys/class/net/$interface/statistics/tx_bytes)

		# (received and transmitted) de Signale 
		rx_traffic=$((final_rx - initial_rx))
		tx_traffic=$((final_tx - initial_tx))
		rx_traffic=$((rx_traffic / 1024))
		tx_traffic=$(($tx_traffic / 1024))


		echo "Network traffic for $interface over $duration seconds:"
		# Print the results
		if (($rx_traffic > $tx_traffic)); then
		echo "Total: $((rx_traffic - tx_traffic ))  Kbytes"
			
		  tr=$((rx_traffic - tx_traffic ))

		  
		echo   $tr"	5"  >> data.txt
		elif (($rx_traffic < $tx_traffic)); then

		
		echo "Total:  $((tx_traffic - $tx_traffic ))  Kbytes"
		  			  tr=$((tx_traffic - rx_traffic ))
		echo   $tr"	5"  >> data.txt
		else
		echo "Total: $tx_traffic  Kbytes"
		     echo   $tx_traffic"	5" >> data.txt
                fi
		done 
		# Laison avec gnuplot  
		$(gnuplot  plot.plt)
		   # Laison avec HTml dashb
		$(xdg-open  dashb.html)
		

	else 
   	 	# Afficher une erreur si y acune selection 
	result=$(zenity --question --text "Are you sure you want to quit?" --ok-button "Yes")
  		echo "User pressed in cancel button"
  	fi

else
    zenity --error --title="Authentication" --text="Authentication failed."
fi





