#!/bin/bash
# Définition des variables
SRV01='srv-lin1-01'
DOMAIN='lin1.local'
OU='lin1'
LDAPPWD='Pa$$w0rd'
LdapAdminCNString='cn=admin,dc=lin1,dc=local'
LdapDCString='dc=lin1,dc=local'
# Configuration de debconf pour l'installation de slapd
debconf-set-selections <<< "slapd slapd/password2 password $LDAPPWD"
debconf-set-selections <<< "slapd slapd/password1 password $LDAPPWD"
debconf-set-selections <<< "slapd slapd/move_old_database boolean true"
debconf-set-selections <<< "slapd shared/organization string $OU"
debconf-set-selections <<< "slapd slapd/no_configuration boolean false"
debconf-set-selections <<< "slapd slapd/purge_database boolean false"
debconf-set-selections <<< "slapd slapd/domain string $DOMAIN"
# Définir l'interface utilisateur Debian en mode non interactif
export DEBIAN_FRONTEND=noninteractive
# Installation de slapd et ldap-utils
echo "Installation de slapd et ldap-utils..."
sudo apt-get install -y slapd ldap-utils
# Configuration du fichier ldap.conf
LDAP_FILE_CONF="/etc/ldap/ldap.conf"
sudo bash -c "cat > $LDAP_FILE_CONF" <<EOM
BASE    dc=lin1,dc=local
URI     ldap://$SRV01.$DOMAIN
EOM
# Modification du mot de passe admin
echo "Modification du mot de passe admin..."
LDAP_SERVER="ldap://$SRV01.$DOMAIN"
LDIF_FILE="modify_root_password.ldif"
cat > $LDIF_FILE <<EOM
dn: $LdapAdminCNString
changetype: modify
replace: userPassword
userPassword: $LDAPPWD
EOM
# Modifier le mot de passe root en utilisant le fichier LDIF
ldapmodify -x -H "$LDAP_SERVER" -D "$LdapAdminCNString" -w "$LDAPPWD" -f $LDIF_FILE
# Nettoyer le fichier LDIF
rm $LDIF_FILE
echo "Le script a terminé avec succès."
