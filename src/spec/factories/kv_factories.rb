FactoryGirl.define do
  trait :enterprise_key do
    key 'masterIPs'
  end

  trait :shared_key do
    key 'literally/anything/else'
  end

  trait :value do
    value '123.123.123.123:8080'
  end

  factory :enterprise_kv, class: Consul::KV, traits: [:enterprise_key, :value] do
    initialize_with { new{|c| c.key = key; c.value = value} }
  end
  factory :shared_kv, class: Consul::KV, traits: [:shared_key, :value] do
    initialize_with { new{|c| c.key = key; c.value = value} }
  end
end
