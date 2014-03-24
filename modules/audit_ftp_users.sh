# audit_ftp_users
#
# If FTP is permitted to be used on the system, the file /etc/ftpd/ftpusers is
# used to specify a list of users who are not allowed to access the system via
# FTP.
# FTP is an old and insecure protocol that transfers files and credentials in
# clear text and is better replaced by using sftp instead. However, if it is
# permitted for use in your environment, it is important to ensure that the
# default "system" accounts are not permitted to transfer files via FTP,
# especially the root account. Consider also adding the names of other
# privileged or shared accounts that may exist on your system such as user
# oracle and the account which your Web server process runs under.
#.

audit_ftp_users () {
  if [ "$os_name" = "SunOS" ]; then
    check_file=$1
    total=`expr $total + 1`
    for user_name in adm bin daemon gdm listen lp noaccess \
      nobody nobody4 nuucp postgres root smmsp svctag \
      sys uucp webserverd; do
      user_check=`cat /etc/passwd |cut -f1 -d":" |grep "^$user_name$"`
      if [ `expr "$user_check" : "[A-z]"` = 1 ]; then
        ftpuser_check=`cat $check_file |grep -v '^#' |grep "^$user_name$"`
        if [ `expr "$ftpuser_check" : "[A-z]"` != 1 ]; then
          if [ "$audit_mode" = 1 ]; then
            score=`expr $score - 1`
            echo "Warning:   User $user_name not in $check_file [$score]"
          fi
          if [ "$audit_mode" = 0 ]; then
            funct_backup_file $check_file
            echo "Setting:   User $user_name to not be allowed ftp access"
            funct_append_file $check_file $user_name hash
          fi
        else
          if [ "$audit_mode" = 1 ]; then
            score=`expr $score + 1`
            echo "Secure:    User $user_name in $check_file [$score]"
          fi
        fi
      fi
    done
    if [ "$audit_mode" = 2 ]; then
      funct_restore_file $check_file $restore_dir
    fi
  fi
  if [ "$os_name" = "Linux" ]; then
    check_file=$1
    total=`expr $total + 1`
    for user_name in root bin daemon adm lp sync shutdown halt mail \
    news uucp operator games nobody; do
      user_check=`cat /etc/passwd |cut -f1 -d":" |grep "^$user_name$"`
      if [ `expr "$user_check" : "[A-z]"` = 1 ]; then
        ftpuser_check=`cat $check_file |grep -v '^#' |grep "^$user_name$"`
        if [ `expr "$ftpuser_check" : "[A-z]"` != 1 ]; then
          if [ "$audit_mode" = 1 ]; then
            score=`expr $score - 1`
            echo "Warning:   User $user_name not in $check_file [$score]"
          fi
          if [ "$audit_mode" = 0 ]; then
            funct_backup_file $check_file
            echo "Setting:   User $user_name to not be allowed ftp access"
            funct_append_file $check_file $user_name hash
          fi
        else
          if [ "$audit_mode" = 1 ]; then
            score=`expr $score + 1`
            echo "Secure:    User $user_name in $check_file [$score]"
          fi
        fi
      fi
    done
    if [ "$audit_mode" = 2 ]; then
      funct_restore_file $check_file $restore_dir
    fi
  fi
}