require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "users@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  test "email validation should accept valid addresses" do
    valid_addresses = %w[users@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[users@example,com user_at_foo.org users.name@example.
foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember,'')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user"do
    dixon = users(:dixon)
    ajay = users(:ajay)
    assert_not dixon.following?(ajay)
    dixon.follow(ajay)
    assert dixon.following?(ajay)
    assert ajay.followers.include?(dixon)
    dixon.unfollow(ajay)
    assert_not dixon.following?(ajay)
  end

  test "feed should have the right posts" do
    dixon = users(:dixon)
    ajay = users(:ajay)
    mani = users(:mani)
    #Posts from followed user
    mani.microposts.each do |post_following|
      assert dixon.feed.include?(post_following)
    end
    #Post from self
    dixon.microposts.each do |post_self|
      assert dixon.feed.include?(post_self)
    end
    #Post from unfollow users
    ajay.microposts.each do |post_unfollowed|
      assert_not dixon.feed.include?(post_unfollowed)
    end
  end
end
