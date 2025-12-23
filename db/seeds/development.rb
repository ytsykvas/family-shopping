# frozen_string_literal: true

puts "Creating test users..."

users = []
(1..10).each do |i|
  username = i == 1 ? "tsykvas" : "tsykvas#{i}"

  user = User.find_or_initialize_by(email: "#{username}@gmail.com")

  user.name = username
  user.nickname = username
  user.password = "blink182"
  user.password_confirmation = "blink182"

  if user.save
    if user.previously_new_record?
      puts "✓ Created user: #{username}"
    else
      puts "✓ Updated user: #{username}"
    end
    users << user
  else
    puts "✗ Failed to save user #{username}: #{user.errors.full_messages.join(', ')}"
  end
end

puts "\nCreating friendships..."

users.each_with_index do |user, _index|
  other_users = users.reject { |u| u.id == user.id }

  # Create outgoing pending requests (user is requester)
  outgoing_count = [ 2, 3 ].sample
  outgoing_targets = other_users.sample(outgoing_count)

  outgoing_targets.each do |target|
    next if Friendship.between_users(user, target).exists?

    friendship = Friendship.create(
      requester: user,
      accepter: target,
      status: :pending
    )

    puts "  ✓ #{user.nickname} → #{target.nickname} (pending)" if friendship.persisted?
  end

  # Create incoming pending requests (user is accepter)
  incoming_count = [ 2, 3 ].sample
  incoming_requesters = other_users.reject { |u| outgoing_targets.include?(u) }.sample(incoming_count)

  incoming_requesters.each do |requester|
    next if Friendship.between_users(user, requester).exists?

    friendship = Friendship.create(
      requester: requester,
      accepter: user,
      status: :pending
    )

    puts "  ✓ #{requester.nickname} → #{user.nickname} (pending)" if friendship.persisted?
  end

  # Create accepted friendships (friends)
  friends_count = [ 2, 3 ].sample
  available_for_friends = other_users.reject do |u|
    outgoing_targets.include?(u) || incoming_requesters.include?(u) ||
      Friendship.between_users(user, u).exists?
  end

  friends_targets = available_for_friends.sample(friends_count)

  friends_targets.each do |friend|
    # Create bidirectional accepted friendship
    friendship = Friendship.create(
      requester: user,
      accepter: friend,
      status: :accepted
    )

    puts "  ✓ #{user.nickname} ↔ #{friend.nickname} (accepted)" if friendship.persisted?
  end
end

puts "\nDone!"
puts "  Users: #{User.count}"
puts "  Friendships: #{Friendship.count}"
puts "  Pending: #{Friendship.pending.count}"
puts "  Accepted: #{Friendship.accepted.count}"
