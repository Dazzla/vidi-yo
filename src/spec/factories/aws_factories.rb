FactoryGirl.define do
  factory :aws, class: AWS do
    access_key 'abc'
    secret_key '123'
    region 'eu-west-1'
    vpc_name 'test'
    role_name 'deployer'
    cluster_name 'test01'

    initialize_with { new(access_key, secret_key, region, vpc_name, role_name, cluster_name) }
  end
end
