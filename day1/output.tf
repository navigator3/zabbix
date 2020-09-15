output "Resalt" {
  value = <<EOF

  ################################################################
  #   Zabbix server and client with preset autoregistration agent!
  #                         Task - Day1
  #   !!! Zabbix server autoregistration settings must be
  #       add in UI: Configuration>Actions. Client is ready!
  #
  #               -----S.Shevtsov,2020---
  ###############################################################
!!!! Atantion: you must wait some minutes before click the link!!!
Zabbix here: http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}/zabbix
interntal Zabbix serv ip: ${google_compute_instance.default.network_interface.0.network_ip}

EOF

}
