require 'spec_helper'

shared_examples 'kv_with_a_value' do
  it 'correctly sets the value' do
    expect(kv.value).to eql '123.123.123.123:8080'
  end
end

describe 'Consul::KV' do

  context 'when creating a flex enterprise key value pair' do
    let (:kv){ build(:enterprise_kv) }
    it_behaves_like 'kv_with_a_value'

    it 'sets the correct key' do
      expect(kv.key).to eql 'flex/enterprise/masterIPs'
    end
  end

  context 'when creating a flex shared key value pair' do
    let (:kv){ build(:shared_kv) }
    it_behaves_like 'kv_with_a_value'

    it 'sets the correct key' do
      expect(kv.key).to eql 'flex/shared/literally/anything/else'
    end
  end

end


describe 'Consul' do
  let(:kvs){ [build(:enterprise_kv), build(:shared_kv)] }
  let(:cluster_id) {'rspec'}
  let(:url) {'http://localhost:8500'}

  let(:consul) { Consul.new{|c| c.cluster_id = cluster_id; c.key_values = kvs; c.url = url} }
  context 'when initialised' do
    [:cluster_id, :cluster_id=, :key_values, :key_values=, :url, :url=].each do |a|
      it "accepts the accessor #{a.to_s}" do
        expect(consul).to respond_to(a)
      end
    end

    [:update].each do |m|
      it { expect(consul).to respond_to(m) }
    end

    [:put, :auth, :domain_names, :push_key_values].each do |m|
      it { expect(consul).not_to respond_to(m) }
    end

    it 'creates the relevant key pairs' do
      expect( consul.update ).not_to be(nil)
    end
  end

end
