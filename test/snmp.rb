require 'snmp'
include SNMP

HOSTNAME = '172.16.1.1'
Manager.open(:host => HOSTNAME) do |manager|
  response = manager.get(["sysDescr.0", "sysName.0" ])
  response.each_varbind do |vb|
     puts "#{vb.name.to_s}  #{vb.value.to_s}  #{vb.value.asn1_type}"
  end
end

puts ""

manager = Manager.new(:Host => HOSTNAME, :Port => 161)
# start_oid = ObjectId.new("1.3.6.1.2")
start_oid = ObjectId.new("1.3.6.1.2.1.4.20.1.2")

while (1)
  puts "Enter path: "
  start_oid = ObjectId.new(gets)

  next_oid = start_oid
  while next_oid.subtree_of?(start_oid)
    response = manager.get_next(next_oid)
    varbind = response.varbind_list.first
    break if EndOfMibView == varbind.value
    next_oid = varbind.name
    puts "#{varbind.name.to_s}  #{varbind.value.to_s}  #{varbind.value.asn1_type}"
  end
end
# SNMP::Manager.open(:Host => HOSTNAME) do |manager|
#   manager.walk("ifTable") { |vb| puts vb }
# end
# 
# 
# SNMP::Manager.open(:Host => HOSTNAME) do |manager|
#   manager.walk(["ifIndex", "ifDescr"]) do |ifIndex, ifDescr|
#     puts "#{ifIndex} #{ifDescr}"
#   end
# end

# puts "---"
# 
# ifTable_columns = ["ifIndex", "ifDescr", "ifInOctets", "ifOutOctets"]
# SNMP::Manager.open(:host => HOSTNAME) do |manager|
#   manager.walk(ifTable_columns) do |row|
#     row.each { |vb| print "\t#{vb.value}" }
#     puts
#   end
# end
# 
# puts "---"

# include SNMP
# 
#  Manager.open(:host => HOSTNAME) do |manager|
#      ifTable = ObjectId.new("1.3.6.1.2.1.2.2")
#      next_oid = ifTable
#      while next_oid.subtree_of?(ifTable)
#          response = manager.get_next(next_oid)
#          varbind = response.varbind_list.first
#          next_oid = varbind.name
#          puts varbind.to_s
#      end
#  end

 