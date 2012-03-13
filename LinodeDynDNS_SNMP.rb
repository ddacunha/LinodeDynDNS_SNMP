require 'linode'
require 'snmp'
require 'highline/import'
include SNMP

APIKEY = 'abcdefghijklmnopqrstuvwxyz' # API Key can be generated from Linode.com
SNMPHOSTNAME = '172.16.1.1' # ip address of the SNMP enabled router (e.g.: Airport Express)
DOMAIN = 'mydomain.com' # domain name as per Linode record
RESOURCE = 'home' # resource to update (e.g.: home for 'home.mydomain.com')


IPFILTEROUT = [  "10",  "127",  "169",  "172",  "192"]

l = Linode.new api_key: APIKEY

begin 
  puts "Testing connection (test.echo)"
  result = l.test.echo(foo:'bar')
rescue => ex
  puts "#{ex.class}: #{ex.message}"
end

# puts "Install Airport Utility 5.6 http://support.apple.com/kb/DL1482?viewlocale=en_US&locale=en_US"

puts "Retrieving ip address via SNMP"
manager = Manager.new(:Host => SNMPHOSTNAME, :Port => 161)
# start_oid = ObjectId.new("1.3.6.1.2")
start_oid = ObjectId.new("1.3.6.1.2.1.4.20.1.1")
next_oid = start_oid
ip_list = []
while next_oid.subtree_of?(start_oid)
  response = manager.get_next(next_oid)
  varbind = response.varbind_list.first
  break if EndOfMibView == varbind.value
  next_oid = varbind.name
  ip = varbind.value.to_s
  if ( (IPFILTEROUT.index(ip[0,3]).nil? == true)  && ( /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/ =~ ip))
    ip_list << ip
  end
end

raise "Unable to get ip address from SNMP" if ip_list.count == 0

puts "Updating Linode DNS records with ip: #{ip_list.first}"
domain = l.domain.list.select {|d| d.domain == DOMAIN}.first
resource_list = l.domain.resource.list domainid: domain.domainid
resource = resource_list.select {|r| r.name == RESOURCE}.first

l.domain.resource.update domainid: domain.domainid, resourceid: resource.resourceid, target: ip_list.first
puts "Linode updated"

