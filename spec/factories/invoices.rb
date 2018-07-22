FactoryBot.define do
  factory :invoice do
    user
    amount 1
    status "unpaid"

    trait :unpaid do
      status "unpaid"
    end

    trait :expired do
      after(:create) do |record, evaluator|
        record.status = "expired"
        record.save!
      end
    end

    trait :paid do
      after(:create) do |record, evaluator|
        record.paid_at = record.created_at
        record.status = 'paid'
        record.save!
      end
    end
  end
end
