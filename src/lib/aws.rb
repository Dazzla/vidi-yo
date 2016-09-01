require 'fog/aws'

class AWS
  attr_accessor :cluster_name
  def initialize access_key, secret_key, region, vpc_name, role_name, env='t', cluster_name=nil
    @compute = Fog::Compute.new(
      provider: 'AWS',
      aws_access_key_id: access_key,
      aws_secret_access_key: secret_key,
      region: region
    )

    @iam = Fog::AWS::IAM.new(
      aws_access_key_id: access_key,
      aws_secret_access_key: secret_key
    )

    @rds = Fog::AWS::RDS.new(
      aws_access_key_id: access_key,
      aws_secret_access_key: secret_key,
      region: region
    )

    @env = env

    @role_name = role_name
    @vpc = vpc_lookup vpc_name
    @cluster_name = cluster_name
  end

  def security_group_lookup security_group
    @compute.security_groups.find{|s| s.vpc_id == @vpc and s.tags['Name'] =~ /#{security_group}/ }
  end

  def vpc_public_subnets
    vpc_subnets 'Public'
  end

  def vpc_private_subnets
    vpc_subnets 'Private'
  end

  def cluster_host_lookup type
    @compute.servers.map{|s| s.private_ip_address if s.tags['cluster'] == @cluster_name and s.tags['flex_usage'] == type}.compact
  end

  def infra_host_lookup type, cluster='infra'
    @compute.servers.map{|s| s.private_ip_address if s.tags['cluster'] == cluster and s.tags['flex_usage'] == type}.compact
  end

  def role_lookup
    @iam.get_role(@role_name).data[:body]['Role']['Arn']
  end

  def database_url cluster='infra'
    databases = @rds.describe_db_instances.data[:body]['DescribeDBInstancesResult']['DBInstances']
    databases.find{|d| d['DBClusterIdentifier'] == "flex-db-#{cluster}-#{@env}-cluster"}['Endpoint']['Address']
  end

  private
  def vpc_subnets desc_string
    subnets = @compute.subnets.select{|s| s.vpc_id == @vpc and s.tag_set['Description'] =~ /#{desc_string}/ }.map( &:subnet_id )
    until subnets.size >= 2
      subnets << subnets.sample
    end
    subnets
  end

  def vpc_lookup vpc_name
    @compute.vpcs.find{|v| v.tags['Name'] == vpc_name}.id
  end
end
