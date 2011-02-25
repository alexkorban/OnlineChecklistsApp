require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  def make_account
    acc = Account.make
    acc.users << User.make
    acc.save!
    acc
  end

  def create_subscriber(acc, plan_name)
    acc.create_subscriber(plan_name)
    s = Spreedly::Subscriber.find(acc.id)
    assert s
  end

  test "db is empty" do
    assert Account.count == 0
    assert User.count == 0
  end

  test "trial subscriber creation" do
    acc = make_account
    create_subscriber(acc, "trial")
    assert s.subscription_plan_name =~ /trial/i
  end

  test "regular subscriber creation" do
    acc = make_account
    create_subscriber(acc)
    assert acc.plan = "professional"
  end

  test "update subscriber name" do
    acc = make_account
    acc.create_subscriber("trial")
    acc.users.first.update_attributes(:name => "Updated", :email => "updated@example.com")
    acc.update_subscriber
    s = Spreedly::Subscriber.find(acc.id)
    assert s.screen_name == "Updated"
    assert s.email == "updated@example.com"
  end

  test "subscriber auto renewal stops with account cancellation" do
    assert true
  end


end