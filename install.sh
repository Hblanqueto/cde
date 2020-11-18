#!/bin/bash
cp cdesktopenv-code/cde/contrib/rc/linux/dtlogin /etc/rc.d/.
chmod +x /etc/rc.d/dtlogin
cd cdesktopenv-code/cde/admin/IntegTools/dbTools || die

S=/root/cdesktopenv-code/cde
D=/
T=/tmp

DATABASE_FILES="CDE-RUN CDE-MIN CDE-TT CDE-MAN CDE-HELP-RUN CDE-C \
     CDE-MSG-C CDE-HELP-C CDE-SHLIBS CDE-HELP-PRG \
     CDE-PRG CDE-INC CDE-DEMOS CDE-MAN-DEV CDE-ICONS \
     CDE-FONTS CDE-INFO CDE-INFOLIB-C"

DATABASE_DIR="${S}"/databases
 
for db in ${DATABASE_FILES}; do
  echo "Fileset ${db}"
  echo "    ${DATABASE_DIR}/${db}.udb -> ${T}/${db}.lst"
  /bin/ksh ./udbToAny.ksh -toLst -ReleaseStream linux \
  "${DATABASE_DIR}"/"${db}".udb > "${T}"/"${db}".lst
  echo "    ${T}/${db}.lst -> ${D}"
  /bin/ksh ./mkProd -D "${D}" -S "${S}" "${T}"/"${db}".lst
done

mkdir -p /var/dt
chmod -R a+rwx /var/dt
mkdir -p /usr/spool/calendar
echo "/usr/dt/lib" >> /etc/ld.so.conf
$(which ldconfig)

cat << 'EOF' > /etc/profile.d/cde
LDPATH="$LDPATH:/usr/dt/lib"
PATH="$PATH:/usr/dt/bin"
MANPATH="$MANPATH:/usr/dt/man"
EOF

#Ensure permissions
chmod 1777 /tmp
mkdir -p /tmp/.X11-unix && chmod 1777 -R /tmp/.X11-unix
mkdir -p /tmp/.ICE-unix && chmod 1777 -R /tmp/.ICE-unix
mkdir -p /tmp/.X0-unix && chmod 1777 -R /tmp/.X0-unix
mkdir -p /tmp/.XIM-unix && chmod 1777 -R /tmp/.XIM-unix
