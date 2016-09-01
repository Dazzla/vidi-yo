require 'spec_helper'

describe 'AWS' do
  let(:aws_connection) { build(:aws) }

  context 'when initializing' do
    [:security_group_lookup, :vpc_public_subnets, :vpc_private_subnets,
     :cluster_host_lookup, :infra_host_lookup, :role_lookup, :database_url].each do |m|
      it { expect(aws_connection).to respond_to(m) }
    end

    [:vpc_subnets, :vpc_lookup].each do |m|
      it { expect(aws_connection).not_to respond_to(m) }
    end

  end

end
