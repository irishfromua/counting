User.create(username: "abc", email: "abc@abc.com", password: "abc")
User.create(username: "def", email: "def@def.com", password: "def")

Thing.create(user_id: "1", title: "abc_thing1", count: "0")
Thing.create(user_id: "1", title: "abc_thing2", count: "0")
Thing.create(user_id: "2", title: "def_thing1", count: "0")
Thing.create(user_id: "2", title: "def_thing2", count: "0")
Thing.create(user_id: "2", title: "def_thing3", count: "0")
Thing.create(user_id: "1", title: "abc_thing3", count: "0")
Thing.create(user_id: "2", title: "def_thing4", count: "0")

puts "Done."