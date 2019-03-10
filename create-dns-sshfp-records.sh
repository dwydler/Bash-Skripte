# Autor: 	Daniel Wydler
# Datum: 	10.03.2019, 11:30 Uhr
# Umgebung:	Ubuntu 18.04


FQDN="$(hostname)"
SSHCONF="/etc/ssh"

CIPHERS=([1]='rsa' 'dsa' 'ecdsa' 'ed25519')
HASHALGOS=([1]='sha1' 'sha256')


for (( hashvalue = 1 ; hashvalue <= ${#HASHALGOS[@]} ; hashvalue++ )); do
	#echo ${HASHALGOS[$hashvalue]} 

	for (( ciphervalue = 1 ; ciphervalue <= ${#CIPHERS[@]} ; ciphervalue++ )); do 
		#echo ${CIPHERS[$ciphervalue]} 

		# Check if a host key of the cipher exist, otherwise skip 
		if [ -e ${SSHCONF}/ssh_host_${CIPHERS[$ciphervalue]}_key.pub ]; then 

			# dns comment line 
			echo "; ${CIPHERS[$ciphervalue]} key hashed by ${HASHALGOS[$hashvalue]}" 

			# generates hash 
			HASH="$(awk '{print $2}' ${SSHCONF}/ssh_host_${CIPHERS[$ciphervalue]}_key.pub | openssl base64 -d -A | openssl ${HASHALGOS[$hashvalue]} | awk '{print $2}')" 

			# sshfp line format 
			echo "${FQDN}.      IN      SSHFP $ciphervalue $hashvalue $HASH" 
		else 
			echo "${CIPHERS[$ciphervalue]} not found." 
		fi 
	done 
done