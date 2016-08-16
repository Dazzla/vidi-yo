require 'diplomat'
require 'securerandom'

class Consul
  class KV
    ENTERPRISE = %w(masterIPs jobIPs mysql/database)
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
    k = 'flex/mio-auth-service/tokenSecret'

    # Override the above, don't want to keep replacing this,
    # Nor do I want to keep outputting session token secrets
    begin
      Diplomat::Kv.get(k)
    rescue Diplomat::KeyNotFound
      Diplomat::Kv.put(k, SecureRandom.uuid)
    end
  end

  def domain_names
    # This is hack city
    base = "flex-#{@cluster_id}.ft.com"

    put('flex/enterprise/domainName', "master.#{base}")
    put('flex/flex-matadatadesigner-app/url', "https://metadata.#{base}/metadata/a/%account")
    put('flex/enterprise/api/url', "https://master.#{base}/api")
    put('flex/enterprise/consoleUrl', "https://master.#{base}/")
  end

  def push_key_values
    key_values.each do |kv|
      put(kv.key, kv.value)
    end
  end
end
