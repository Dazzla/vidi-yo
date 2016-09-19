require 'diplomat'
require 'securerandom'

class Consul
  class KV
    ENTERPRISE = %w(masterIPs jobIPs mysql/database api/username)
    PREFIX = 'flex'

    def initialize
      @opts = OpenStruct.new
      yield @opts
    end

    def key
      k = @opts['key']
      if ENTERPRISE.include?(k)
        p = "#{PREFIX}/enterprise"
      else
        p = "#{PREFIX}/shared"
      end
      "#{p}/#{k}"
    end

    def value
      @opts['value']
    end
  end

  attr_accessor :cluster_id,
                :hosts,
                :key_values,
                :url

  def initialize
    yield self if block_given?

    @url = 'localhost:8050' if @url.nil?
    Diplomat.configure do |c|
      c.url = @url
    end
  end

  def update
    auth
    domain_names
    push_key_values
    hosts
  end

  private
  def put k, v
    print "Key: #{k} - "
    begin
      current = Diplomat::Kv.get(k)
      if current == v
        puts "already up to date"
        return
      else
        puts "updating to #{v}"
      end
    rescue Diplomat::KeyNotFound
      puts "initialising with value #{v}"
    end

    Diplomat::Kv.put(k,v)
  end

  def auth
    # Override the above, don't want to keep replacing this,
    # Nor do I want to keep outputting session token secrets
    put('annihilator/haproxy/username', 'haproxy')

    ['flex/flex-authentication-service/tokenSecret', 'annihilator/haproxy/password'].each do |k|
      begin
        Diplomat::Kv.get(k)
      rescue Diplomat::KeyNotFound
        put(k, SecureRandom.uuid)
      end
    end

  end

  def domain_names
    # This is hack city
    base = "flex-#{@cluster_id}.ft.com"
    master = "master-#{base}"
    fqdn = "https://#{master}"
    api = "#{fqdn}/api"

    metadata = "metadata-#{base}"
    workflow = "workflow-#{base}"

    put('flex/enterprise/domainName', master)
    put('flex/flex-metadatadesigner-app/url', "https://#{metadata}/metadata/a/%account")
    put('flex/flex-workflowdesigner-app/url', "https://#{workflow}/workflow/a/%account")
    put('flex/enterprise/api/url', api)
    put('flex/shared/flex-enterprise/api/url', api)
    put('flex/shared/flex-enterprise/consoleUrl', api)
    put('flex/enterprise/consoleUrl', fqdn)

    put('annihilator/flex/metadata_domain', metadata)
    put('annihilator/flex/workflow_domain', workflow)
  end

  def hosts
    put("annihilator/haproxy/all_hosts", @hosts)
  end

  def push_key_values
    key_values.each do |kv|
      put(kv.key, kv.value)
    end
  end
end
