require 'ostruct'

vpcs = [
  OpenStruct.new({id: '12345',
   tags: {'Name' => 'test'}
  })
]

RSpec.configure do |c|
  c.before do
    Fog.mock!
    Fog::Mock.reset
    Fog::Mock.delay = 0

    Fog::Compute::AWS::Mock.any_instance.stub(:vpcs).and_return(vpcs)
  end

end
